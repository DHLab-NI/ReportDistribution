page 50306 "Report Distribution Rule Card"
{
    Caption = 'Report Distribution Rule 50186';
    PageType = Card;
    SourceTable = "Report Distribution Rule";
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique code for this distribution rule.';
                }
                field("Inbox Code"; Rec."Inbox Code")
                {
                    ApplicationArea = All;
                    Caption = 'Inbox Code';
                    ToolTip = 'Specifies the monitored inbox this rule applies to.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description for this distribution rule.';
                }
                field("Priority"; Rec."Priority")
                {
                    ApplicationArea = All;
                    Caption = 'Priority';
                    ToolTip = 'Specifies the priority order for processing rules (lower numbers processed first).';
                }
                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether this rule is active.';
                }
            }

            group("Matching Criteria")
            {
                Caption = 'Matching Criteria';

                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    Caption = 'Report ID';
                    ToolTip = 'Specifies the specific report ID to match (blank = any).';
                }
                field("Report Name Filter"; Rec."Report Name Filter")
                {
                    ApplicationArea = All;
                    Caption = 'Report Name Filter';
                    ToolTip = 'Specifies a filter pattern for report names (supports * wildcard).';
                }
                field("Output Type"; Rec."Output Type")
                {
                    ApplicationArea = All;
                    Caption = 'Output Type';
                    ToolTip = 'Specifies the output type to match (blank = any).';
                }
                field("Stop Processing"; Rec."Stop Processing")
                {
                    ApplicationArea = All;
                    Caption = 'Stop Processing';
                    ToolTip = 'Specifies whether to stop processing further rules after this one matches.';
                }
            }

            group("Email Templates")
            {
                Caption = 'Email Templates';

                field("Subject Template"; Rec."Subject Template")
                {
                    ApplicationArea = All;
                    Caption = 'Subject Template';
                    ToolTip = 'Specifies the email subject template. Use %ReportName%, %ReportId%, %Date%, %UserId% as tokens.';
                }
                field("Body Template"; Rec."Body Template")
                {
                    ApplicationArea = All;
                    Caption = 'Body Template';
                    ToolTip = 'Specifies the email body template. Use %ReportName%, %ReportId%, %Date%, %UserId% as tokens.';
                }
                field("File Name Template"; Rec."File Name Template")
                {
                    ApplicationArea = All;
                    Caption = 'File Name Template';
                    ToolTip = 'Specifies the attachment file name template. Use %ReportName%, %ReportId%, %Date%, %UserId% as tokens.';
                }
                field("Preferred Sender Email"; Rec."Preferred Sender Email")
                {
                    ApplicationArea = All;
                    Caption = 'Preferred Sender Email';
                    ToolTip = 'Specifies a preferred sender email for this rule (overrides inbox and setup defaults).';
                }
            }
        }

        area(FactBoxes)
        {
            part("Recipients"; "Report Rule Recipients")
            {
                ApplicationArea = All;
                Caption = 'Recipients';
                SubPageLink = "Rule Code" = field("Code");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("View Rule Recipients")
            {
                ApplicationArea = All;
                Caption = 'Rule Recipients';
                Image = Email;
                RunObject = Page "Report Rule Recipients";
                RunPageLink = "Rule Code" = field("Code");
                ToolTip = 'View and manage recipients for this rule.';
            }
        }

        area(Processing)
        {
            action("Test Rule")
            {
                ApplicationArea = All;
                Caption = 'Test Rule';
                Image = TestReport;
                ToolTip = 'Test this rule against recent reports.';

                trigger OnAction()
                var
                    ReportInbox: Record "Report Inbox";
                    FoundReports: Integer;
                begin
                    if not Rec."Enabled" then
                        Error('This rule is not enabled.');

                    // Find recent reports that would match this rule
                    ReportInbox.Reset();
                    ReportInbox.SetRange("Created Date-Time", CreateDateTime(Today - 7, 0T), CreateDateTime(Today, 235959T));
                    FoundReports := 0;

                    if ReportInbox.FindSet() then
                        repeat
                            if Rec.MatchesReport(ReportInbox) then
                                FoundReports += 1;
                        until ReportInbox.Next() = 0;

                    Message('Found %1 reports in the last 7 days that match this rule.', FoundReports);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Inbox Code" = '' then
            Rec."Inbox Code" := xRec."Inbox Code";
    end;
}
