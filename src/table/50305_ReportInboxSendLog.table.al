table 50305 "Report Inbox Send Log"
{
    Caption = 'Report Inbox Send Log';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(10; "Report Inbox Entry No."; Integer)
        {
            Caption = 'Report Inbox Entry No.';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(20; "Sent Datetime"; DateTime)
        {
            Caption = 'Sent Datetime';
            DataClassification = SystemMetadata;
        }
        field(30; "Rule Code"; Code[20])
        {
            Caption = 'Rule Code';
            DataClassification = SystemMetadata;
            TableRelation = "Report Distribution Rule".Code;
        }
        field(40; "Inbox Code"; Code[20])
        {
            Caption = 'Inbox Code';
            DataClassification = SystemMetadata;
            TableRelation = "Monitored Report Inbox".Code;
        }
        field(50; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = SystemMetadata;
        }
        field(60; "Report Name"; Text[250])
        {
            Caption = 'Report Name';
            DataClassification = SystemMetadata;
        }
        field(70; "User ID"; Text[250])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
        }
        field(80; "Created Datetime"; DateTime)
        {
            Caption = 'Created Datetime';
            DataClassification = SystemMetadata;
        }
        field(90; "Status"; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionMembers = Success,Failed;
            OptionCaption = 'Success,Failed';
        }
        field(100; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
    }
    
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Report Inbox Entry No.")
        {
        }
        key(Key3; "Inbox Code", "Sent Datetime")
        {
        }
        key(Key4; "Rule Code", "Sent Datetime")
        {
        }
    }
    
    trigger OnInsert()
    begin
        "Sent Datetime" := CurrentDateTime;
    end;
    
    procedure WasAlreadySent(ReportInboxEntryNo: Integer): Boolean
    var
        SendLog: Record "Report Inbox Send Log";
    begin
        SendLog.SetRange("Report Inbox Entry No.", ReportInboxEntryNo);
        SendLog.SetRange("Status", SendLog."Status"::Success);
        exit(not SendLog.IsEmpty());
    end;
    
    procedure LogSuccessfulSend(ReportInboxEntryNo: Integer; RuleCode: Code[20]; InboxCode: Code[20]; ReportInbox: Record "Report Inbox")
    var
        SendLog: Record "Report Inbox Send Log";
    begin
        SendLog.Init();
        SendLog."Report Inbox Entry No." := ReportInboxEntryNo;
        SendLog."Rule Code" := RuleCode;
        SendLog."Inbox Code" := InboxCode;
        SendLog."Report ID" := ReportInbox."Report ID";
        SendLog."Report Name" := ReportInbox."Report Name";
        SendLog."User ID" := ReportInbox."User ID";
        SendLog."Created Datetime" := ReportInbox."Created Date-Time";
        SendLog."Status" := SendLog."Status"::Success;
        SendLog.Insert(true);
    end;
    
    procedure LogFailedSend(ReportInboxEntryNo: Integer; RuleCode: Code[20]; InboxCode: Code[20]; ReportInbox: Record "Report Inbox"; ErrorMessage: Text[2048])
    var
        SendLog: Record "Report Inbox Send Log";
    begin
        SendLog.Init();
        SendLog."Report Inbox Entry No." := ReportInboxEntryNo;
        SendLog."Rule Code" := RuleCode;
        SendLog."Inbox Code" := InboxCode;
        SendLog."Report ID" := ReportInbox."Report ID";
        SendLog."Report Name" := ReportInbox."Report Name";
        SendLog."User ID" := ReportInbox."User ID";
        SendLog."Created Datetime" := ReportInbox."Created Date-Time";
        SendLog."Status" := SendLog."Status"::Failed;
        SendLog."Error Message" := ErrorMessage;
        SendLog.Insert(true);
    end;
}
