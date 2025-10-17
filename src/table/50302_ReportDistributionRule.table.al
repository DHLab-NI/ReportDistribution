table 50302 "Report Distribution Rule"
{
    Caption = 'Report Distribution Rule';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(10; "Inbox Code"; Code[20])
        {
            Caption = 'Inbox Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = "Monitored Report Inbox".Code;
        }
        field(20; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(30; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(40; "Report Name Filter"; Text[250])
        {
            Caption = 'Report Name Filter';
            DataClassification = SystemMetadata;
        }
        field(50; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = SystemMetadata;
            OptionMembers = " ",Excel,Word,PDF;
            OptionCaption = 'Any,Excel,Word,PDF';
        }
        field(60; "Subject Template"; Text[250])
        {
            Caption = 'Subject Template';
            DataClassification = SystemMetadata;
            InitValue = '%ReportName%';
        }
        field(70; "Body Template"; Text[2048])
        {
            Caption = 'Body Template';
            DataClassification = SystemMetadata;
            InitValue = 'Please find attached today''s %ReportName% report.';
        }
        field(80; "File Name Template"; Text[250])
        {
            Caption = 'File Name Template';
            DataClassification = SystemMetadata;
            InitValue = '%ReportName%_%Date%';
        }
        field(90; "Preferred Sender Email"; Text[250])
        {
            Caption = 'Preferred Sender Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(100; "Stop Processing"; Boolean)
        {
            Caption = 'Stop Processing';
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(110; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(120; "Priority"; Integer)
        {
            Caption = 'Priority';
            DataClassification = SystemMetadata;
            InitValue = 100;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; "Inbox Code", "Priority", "Enabled")
        {
        }
    }

    trigger OnInsert()
    begin
        Validate("Enabled", true);
        if "Priority" = 0 then
            "Priority" := 100;
        if "Subject Template" = '' then
            "Subject Template" := '%ReportName%';
        if "Body Template" = '' then
            "Body Template" := 'Please find attached today''s %ReportName% report.';
        if "File Name Template" = '' then
            "File Name Template" := '%ReportName%_%Date%';
    end;

    procedure GetPreferredSenderEmail(): Text[250]
    var
        MonitoredInbox: Record "Monitored Report Inbox";
    begin
        if "Preferred Sender Email" <> '' then
            exit("Preferred Sender Email");

        if MonitoredInbox.Get("Inbox Code") then
            exit(MonitoredInbox.GetPreferredSenderEmail());

        exit('');
    end;

    procedure MatchesReport(ReportInbox: Record "Report Inbox"): Boolean
    var
        ReportName: Text;
    begin
        // Check Report ID match
        if ("Report ID" <> 0) and (ReportInbox."Report ID" <> "Report ID") then
            exit(false);

        // Check Report Name Filter match
        if "Report Name Filter" <> '' then begin
            ReportName := ReportInbox."Report Name";
            if not TextMatches(ReportName, "Report Name Filter") then
                exit(false);
        end;

        // Check Output Type match (blank/0 means any)
        if ("Output Type" <> 0) and (ReportInbox."Output Type" <> ConvertToEnum("Output Type")) then
            exit(false);

        exit(true);
    end;

    local procedure ConvertToEnum(OutputTypeOption: Integer): Enum "Report Inbox Output Type"
    var
        OutputTypeEnum: Enum "Report Inbox Output Type";
    begin
        case OutputTypeOption of
            1: // Excel
                exit(OutputTypeEnum::Excel);
            2: // Word
                exit(OutputTypeEnum::Word);
            3: // PDF
                exit(OutputTypeEnum::PDF);
            else
                // This should not happen since we check for 0 before calling this
                exit(OutputTypeEnum::Excel);
        end;
    end;

    local procedure TextMatches(TextToCheck: Text; Pattern: Text): Boolean
    var
        Pos: Integer;
        SearchText: Text;
        SearchPattern: Text;
    begin
        if Pattern = '' then
            exit(true);

        SearchText := UpperCase(TextToCheck);
        SearchPattern := UpperCase(Pattern);

        // Simple wildcard matching with * (any characters)
        if StrPos(SearchPattern, '*') = 0 then begin
            // No wildcards, exact match
            exit(SearchText = SearchPattern);
        end else begin
            // Handle wildcards - simplified implementation
            // Replace * with % for LIKE comparison (if supported) or implement custom logic
            // For now, basic starts/ends with * logic
            if CopyStr(SearchPattern, 1, 1) = '*' then begin
                SearchPattern := CopyStr(SearchPattern, 2);
                exit(StrPos(SearchText, SearchPattern) > 0);
            end else if CopyStr(SearchPattern, StrLen(SearchPattern)) = '*' then begin
                SearchPattern := CopyStr(SearchPattern, 1, StrLen(SearchPattern) - 1);
                exit(CopyStr(SearchText, 1, StrLen(SearchPattern)) = SearchPattern);
            end else begin
                // Contains logic for *pattern*
                SearchPattern := DelChr(SearchPattern, '=', '*');
                exit(StrPos(SearchText, SearchPattern) > 0);
            end;
        end;
    end;

}
