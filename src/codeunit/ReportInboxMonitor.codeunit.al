codeunit 50300 "DHLab Report Inbox Monitor"
{
    // Monitors the Report Inbox for configured users and emails reports based on distribution rules.
    // Notes:
    // - Normal codeunit with OnRun is sufficient for Job Queue.
    // - Requires Email Scenario "Default" mapped to a valid Email Account.
    // - Uses Report Inbox BLOB field "Report Output"; must CalcFields before CreateInStream.
    // - Attaches with correct content type based on Output Type / file extension.

    trigger OnRun()
    var
        Setup: Record "Report Inbox Monitor Setup";
        MonitoredInbox: Record "Monitored Report Inbox";
        TotalProcessed: Integer;
        TotalSent: Integer;
    begin
        // Check if monitoring is enabled
        Setup := Setup.GetSetup();
        if not Setup."Enabled" then begin
            Log('Report Inbox Monitor is disabled in setup.');
            exit;
        end;

        // Process each enabled monitored inbox
        MonitoredInbox.Reset();
        MonitoredInbox.SetRange("Enabled", true);

        if not MonitoredInbox.FindSet() then begin
            Log('No enabled monitored inboxes found.');
            exit;
        end;

        repeat
            if ProcessInbox(MonitoredInbox, Setup, TotalSent) then
                TotalProcessed += 1;
        until MonitoredInbox.Next() = 0;

        Log(StrSubstNo('Processed %1 inbox(es), sent %2 email(s) total.', TotalProcessed, TotalSent));
    end;

    local procedure ProcessInbox(var MonitoredInbox: Record "Monitored Report Inbox"; var Setup: Record "Report Inbox Monitor Setup"; var TotalSent: Integer): Boolean
    var
        ReportInbox: Record "Report Inbox";
        StartDT: DateTime;
        EndDT: DateTime;
        ProcessedReports: Integer;
    begin
        // Resolve date range based on setup
        if Setup."Date Range Mode" = Setup."Date Range Mode"::Today then begin
            StartDT := CreateDateTime(Today, 0T);
            EndDT := CreateDateTime(Today, 235959T);
        end else begin
            StartDT := CreateDateTime(CalcDate(Setup."From Date Formula", Today), 0T);
            EndDT := CreateDateTime(CalcDate(Setup."To Date Formula", Today), 235959T);
        end;

        // Filter reports for this inbox and date range
        ReportInbox.Reset();
        ReportInbox.SetRange("User ID", MonitoredInbox."User ID to Monitor");
        ReportInbox.SetRange("Created Date-Time", StartDT, EndDT);

        if not ReportInbox.FindSet() then begin
            Log(StrSubstNo('No reports found for inbox %1 (%2) between %3 and %4.',
                MonitoredInbox."Code", MonitoredInbox."User ID to Monitor", StartDT, EndDT));
            exit(false);
        end;

        repeat
            // Skip if already sent
            if WasAlreadySent(ReportInbox."Entry No.") then begin
                Log(StrSubstNo('Skipping report %1: already sent.', ReportInbox."Entry No."));
                // Continue to next iteration
            end else begin
                // Process this report with matching rules
                if ProcessReport(ReportInbox, MonitoredInbox, Setup) then
                    ProcessedReports += 1;
            end;

        until ReportInbox.Next() = 0;

        if ProcessedReports > 0 then begin
            TotalSent += ProcessedReports;
            Log(StrSubstNo('Processed %1 reports for inbox %2.', ProcessedReports, MonitoredInbox."Code"));
            exit(true);
        end else
            exit(false);
    end;

    local procedure ProcessReport(var ReportInbox: Record "Report Inbox"; var MonitoredInbox: Record "Monitored Report Inbox"; var Setup: Record "Report Inbox Monitor Setup"): Boolean
    var
        DistributionRule: Record "Report Distribution Rule";
        EmailMessage: Codeunit "Email Message";
        SendLog: Record "Report Inbox Send Log";
        ToList: List of [Text];
        CcList: List of [Text];
        BccList: List of [Text];
        AllRecipients: List of [Text];
        EmailSubject: Text;
        EmailBody: Text;
        FileName: Text;
        ContentType: Text;
        AttachmentStream: InStream;
        HasAttachment: Boolean;
        PreferredSenderEmail: Text;
        ReportName: Text;
        RuleMatched: Boolean;
    begin
        // Get report name - prioritise Job Queue Entry description
        ReportName := GetJobQueueDescription(ReportInbox);
        if ReportName = '' then
            ReportName := ReportInbox."Report Name";
        if ReportName = '' then
            ReportName := Format(ReportInbox."Report ID");

        // Find matching rules for this inbox (ordered by priority)
        DistributionRule.Reset();
        DistributionRule.SetRange("Inbox Code", MonitoredInbox."Code");
        DistributionRule.SetRange("Enabled", true);
        DistributionRule.SetCurrentKey("Inbox Code", "Priority", "Enabled");
        DistributionRule.SetAscending("Priority", true);

        if not DistributionRule.FindSet() then begin
            Log(StrSubstNo('No enabled rules found for inbox %1.', MonitoredInbox."Code"));
            exit(false);
        end;

        repeat
            // Check if rule matches this report
            if not DistributionRule.MatchesReport(ReportInbox) then begin
                // Continue to next rule
            end else begin
                RuleMatched := true;
                Log(StrSubstNo('Rule %1 matches report %2.', DistributionRule."Code", ReportInbox."Entry No."));

                // Build recipients for this rule
                BuildRecipients(DistributionRule, ToList, CcList, BccList);

                if (ToList.Count() = 0) and (CcList.Count() = 0) and (BccList.Count() = 0) then begin
                    Log(StrSubstNo('Rule %1 has no recipients configured.', DistributionRule."Code"));
                    // Continue to next rule
                end else begin
                    // Build email content using templates
                    EmailSubject := BuildSubject(ReportInbox, DistributionRule);
                    EmailBody := BuildBody(ReportInbox, DistributionRule);

                    // Determine preferred sender email
                    PreferredSenderEmail := DistributionRule.GetPreferredSenderEmail();

                    // Combine all recipients for email creation
                    AllRecipients.AddRange(ToList);
                    AllRecipients.AddRange(CcList);
                    AllRecipients.AddRange(BccList);

                    // Create email message
                    EmailMessage.Create(ToList, EmailSubject, EmailBody, false);

                    // Note: Cc and Bcc recipients would be added here if the Email Message codeunit supports it

                    // Create attachment
                    HasAttachment := TryGetAttachmentStream(ReportInbox, AttachmentStream, ContentType, FileName, ReportName);
                    if not HasAttachment then begin
                        Log(StrSubstNo('Skipping rule %1 for report %2: no valid Report Output to attach.', DistributionRule."Code", ReportInbox."Entry No."));
                        // Continue to next rule
                    end else begin
                        EmailMessage.AddAttachment(FileName, ContentType, AttachmentStream);

                        // Send email
                        if SendViaResolvedAccount(EmailMessage, PreferredSenderEmail) then begin
                            // Log successful send
                            SendLog.LogSuccessfulSend(ReportInbox."Entry No.", DistributionRule."Code", MonitoredInbox."Code", ReportInbox);
                            Log(StrSubstNo('Email sent successfully via rule %1 for report %2.', DistributionRule."Code", ReportInbox."Entry No."));

                            // If stop processing is enabled, break after first successful match
                            if DistributionRule."Stop Processing" then begin
                                Log(StrSubstNo('Stopping processing for report %2 after rule %1 (Stop Processing enabled).', DistributionRule."Code", ReportInbox."Entry No."));
                                exit(true);
                            end;
                        end else begin
                            // Log failed send
                            SendLog.LogFailedSend(ReportInbox."Entry No.", DistributionRule."Code", MonitoredInbox."Code", ReportInbox, 'Failed to send email');
                            Log(StrSubstNo('Failed to send email via rule %1 for report %2.', DistributionRule."Code", ReportInbox."Entry No."));
                        end;
                    end;
                end;
            end;

        until DistributionRule.Next() = 0;

        exit(RuleMatched);
    end;

    local procedure TryGetAttachmentStream(var ReportInbox: Record "Report Inbox"; var OutStream: InStream; var ContentType: Text; var FileName: Text; ReportName: Text): Boolean
    var
        Ext: Text;
        DateStamp: Text;
    begin
        // Ensure BLOB is loaded
        ReportInbox.CalcFields("Report Output");
        if not ReportInbox."Report Output".HasValue then
            exit(false);

        // Determine extension/content type from Output Type or filename
        GetExtAndContentType(ReportInbox, Ext, ContentType);

        DateStamp := Format(Today, 0, '<Year4><Month,2><Day,2>');
        if ReportName = '' then
            ReportName := 'Report';

        FileName := StrSubstNo('%1_%2%3',
            DelChr(ReportName, '=', ' /\:*?"<>|'),
            DateStamp,
            Ext);

        ReportInbox."Report Output".CreateInStream(OutStream);
        exit(true);
    end;

    local procedure GetExtAndContentType(ReportInbox: Record "Report Inbox"; var Ext: Text; var ContentType: Text)
    var
        OutputType: Enum "Report Inbox Output Type";
        LowerName: Text;
    begin
        OutputType := ReportInbox."Output Type";
        case OutputType of
            OutputType::Excel:
                begin
                    Ext := '.xlsx';
                    ContentType := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                end;
            OutputType::Word:
                begin
                    Ext := '.docx';
                    ContentType := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                end;
            OutputType::PDF:
                begin
                    Ext := '.pdf';
                    ContentType := 'application/pdf';
                end;
            else begin
                // Fall back to filename extension if available
                LowerName := LowerCase(ReportInbox.GetFileNameWithExtension());
                if EndsWith(LowerName, '.xlsx') then begin
                    Ext := '.xlsx';
                    ContentType := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                end else if EndsWith(LowerName, '.docx') then begin
                    Ext := '.docx';
                    ContentType := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                end else if EndsWith(LowerName, '.pdf') then begin
                    Ext := '.pdf';
                    ContentType := 'application/pdf';
                end else begin
                    Ext := '.bin';
                    ContentType := 'application/octet-stream';
                end;
            end;
        end;
    end;

    local procedure EndsWith(TextToCheck: Text; Suffix: Text): Boolean
    var
        startPos: Integer;
    begin
        if StrLen(Suffix) = 0 then
            exit(true);
        if StrLen(TextToCheck) < StrLen(Suffix) then
            exit(false);
        startPos := StrLen(TextToCheck) - StrLen(Suffix) + 1;
        exit(CopyStr(TextToCheck, startPos) = Suffix);
    end;

    local procedure Log(MessageText: Text)
    begin
        if GuiAllowed then
            Message(MessageText);
        // Session.LogMessage('DHLab.ReportInboxMonitor', MessageText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All);
    end;

    local procedure SendViaResolvedAccount(var EmailMessage: Codeunit "Email Message"; PreferredSenderEmail: Text): Boolean
    var
        EmailCU: Codeunit Email;
        EmailAccountCU: Codeunit "Email Account";
        TempAccounts: Record "Email Account" temporary;
    begin
        // 1) If a preferred sender is specified, find and use that account
        if PreferredSenderEmail <> '' then begin
            EmailAccountCU.GetAllAccounts(TempAccounts);
            TempAccounts.SetRange("Email Address", PreferredSenderEmail);
            if TempAccounts.FindFirst() then
                exit(EmailCU.Send(EmailMessage, TempAccounts));
            Error('Email account ''%1'' not found. Configure the account in Email Accounts or update the Preferred Sender Email.', PreferredSenderEmail);
        end;

        // 2) Fallback: use the Default email scenario
        if EmailCU.Send(EmailMessage, Enum::"Email Scenario"::Default) then
            exit(true);

        Error('No email accounts are configured. Configure Email Accounts and map the Default scenario.');
    end;

    local procedure BuildRecipients(var DistributionRule: Record "Report Distribution Rule"; var ToList: List of [Text]; var CcList: List of [Text]; var BccList: List of [Text])
    var
        RuleRecipient: Record "Report Rule Recipient";
    begin
        // Clear lists - AL doesn't have Clear() method, so we create new lists
        Clear(ToList);
        Clear(CcList);
        Clear(BccList);

        // Get recipients for this rule
        RuleRecipient.SetRange("Rule Code", DistributionRule."Code");
        if RuleRecipient.FindSet() then
            repeat
                case RuleRecipient."Type" of
                    0: // To
                        ToList.Add(RuleRecipient."Email Address");
                    1: // Cc
                        CcList.Add(RuleRecipient."Email Address");
                    2: // Bcc
                        BccList.Add(RuleRecipient."Email Address");
                end;
            until RuleRecipient.Next() = 0;
    end;

    local procedure BuildSubject(ReportInbox: Record "Report Inbox"; DistributionRule: Record "Report Distribution Rule"): Text
    var
        SubjectTemplate: Text;
    begin
        SubjectTemplate := DistributionRule."Subject Template";
        if SubjectTemplate = '' then
            SubjectTemplate := '%ReportName%';

        exit(ExpandTokens(SubjectTemplate, ReportInbox));
    end;

    local procedure BuildBody(ReportInbox: Record "Report Inbox"; DistributionRule: Record "Report Distribution Rule"): Text
    var
        BodyTemplate: Text;
    begin
        BodyTemplate := DistributionRule."Body Template";
        if BodyTemplate = '' then
            BodyTemplate := 'Please find attached today''s %ReportName% report.';

        exit(ExpandTokens(BodyTemplate, ReportInbox));
    end;

    local procedure ExpandTokens(Template: Text; ReportInbox: Record "Report Inbox"): Text
    var
        Result: Text;
        ReportName: Text;
        DateText: Text;
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        Result := Template;

        // Get report name - prioritise Job Queue Entry description, then Report Inbox name, then object caption
        ReportName := GetJobQueueDescription(ReportInbox);
        if ReportName = '' then
            ReportName := ReportInbox."Report Name";
        if ReportName = '' then begin
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportInbox."Report ID") then
                ReportName := AllObjWithCaption."Object Caption"
            else
                ReportName := StrSubstNo('Report %1', Format(ReportInbox."Report ID"));
        end;

        // Get date text
        DateText := Format(Today, 0, '<Year4><Month,2><Day,2>');

        // Replace tokens
        Result := Result.Replace('%ReportName%', ReportName);
        Result := Result.Replace('%ReportId%', Format(ReportInbox."Report ID"));
        Result := Result.Replace('%Date%', DateText);
        Result := Result.Replace('%UserId%', ReportInbox."User ID");

        exit(Result);
    end;

    local procedure GetJobQueueDescription(ReportInbox: Record "Report Inbox"): Text
    begin
        // JQ Description is populated at inbox insert time by the Report Inbox JQ Subscriber codeunit
        exit(ReportInbox."JQ Description");
    end;

    local procedure WasAlreadySent(ReportInboxEntryNo: Integer): Boolean
    var
        SendLog: Record "Report Inbox Send Log";
    begin
        exit(SendLog.WasAlreadySent(ReportInboxEntryNo));
    end;


}