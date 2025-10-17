table 50301 "Monitored Report Inbox"
{
    Caption = 'Monitored Report Inbox';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(10; "User ID to Monitor"; Text[250])
        {
            Caption = 'User ID to Monitor';
            DataClassification = SystemMetadata;
            NotBlank = true;
            // TableRelation removed due to primary key constraint - validation handled in OnValidate

            trigger OnValidate()
            var
                User: Record User;
            begin
                if "User ID to Monitor" <> '' then begin
                    User.SetRange("User Name", "User ID to Monitor");
                    if not User.FindFirst() then
                        Error('User %1 not found.', "User ID to Monitor");
                end;
            end;
        }
        field(20; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(30; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = SystemMetadata;
            TableRelation = Company.Name;
        }
        field(40; "Override Sender Email"; Text[250])
        {
            Caption = 'Override Preferred Sender Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(50; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Validate("Enabled", true);
    end;

    procedure GetPreferredSenderEmail(): Text[250]
    var
        Setup: Record "Report Inbox Monitor Setup";
    begin
        if "Override Sender Email" <> '' then
            exit("Override Sender Email");

        Setup := Setup.GetSetup();
        exit(Setup."Default Preferred Sender Email");
    end;
}
