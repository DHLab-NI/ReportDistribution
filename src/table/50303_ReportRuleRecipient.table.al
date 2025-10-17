table 50303 "Report Rule Recipient"
{
    Caption = 'Report Rule Recipient';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Rule Code"; Code[20])
        {
            Caption = 'Rule Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = "Report Distribution Rule".Code;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(20; "Type"; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionMembers = To,Cc,Bcc;
            OptionCaption = 'To,Cc,Bcc';
        }
        field(30; "Email Address"; Text[250])
        {
            Caption = 'Email Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
            NotBlank = true;
        }
        field(40; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Rule Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Rule Code", "Type")
        {
        }
    }

    trigger OnInsert()
    var
        RuleRecipient: Record "Report Rule Recipient";
    begin
        if "Line No." = 0 then begin
            RuleRecipient.SetRange("Rule Code", "Rule Code");
            if RuleRecipient.FindLast() then
                "Line No." := RuleRecipient."Line No." + 10000
            else
                "Line No." := 10000;
        end;

    end;

    procedure GetEmailDisplayText(): Text[350]
    begin
        if "Name" <> '' then
            exit(StrSubstNo('%1 <%2>', "Name", "Email Address"))
        else
            exit("Email Address");
    end;
}
