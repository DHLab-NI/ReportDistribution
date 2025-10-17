table 50300 "Report Inbox Monitor Setup"
{
    Caption = 'Report Inbox Monitor Setup';
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
            
            trigger OnValidate()
            begin
                if not "Enabled" then
                    Validate("Default Preferred Sender Email", '');
            end;
        }
        field(20; "Default Preferred Sender Email"; Text[250])
        {
            Caption = 'Default Preferred Sender Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(30; "Date Range Mode"; Option)
        {
            Caption = 'Date Range Mode';
            DataClassification = SystemMetadata;
            OptionMembers = Today,CustomFormula;
            OptionCaption = 'Today,Custom Formula';
            
            trigger OnValidate()
            begin
                if "Date Range Mode" = "Date Range Mode"::Today then begin
                    Clear("From Date Formula");
                    Clear("To Date Formula");
                end;
            end;
        }
        field(40; "From Date Formula"; DateFormula)
        {
            Caption = 'From Date Formula';
            DataClassification = SystemMetadata;
            
            trigger OnValidate()
            begin
                if "Date Range Mode" = "Date Range Mode"::Today then
                    Error('Date formulas can only be used when Date Range Mode is set to Custom Formula.');
            end;
        }
        field(50; "To Date Formula"; DateFormula)
        {
            Caption = 'To Date Formula';
            DataClassification = SystemMetadata;
            
            trigger OnValidate()
            begin
                if "Date Range Mode" = "Date Range Mode"::Today then
                    Error('Date formulas can only be used when Date Range Mode is set to Custom Formula.');
            end;
        }
    }
    
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
    
    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'SETUP';
    end;
    
    procedure GetSetup(): Record "Report Inbox Monitor Setup"
    var
        Setup: Record "Report Inbox Monitor Setup";
    begin
        if not Setup.Get('SETUP') then begin
            Setup.Init();
            Setup."Primary Key" := 'SETUP';
            Setup."Date Range Mode" := Setup."Date Range Mode"::Today;
            Setup.Insert();
        end;
        exit(Setup);
    end;
    
    procedure IsEnabled(): Boolean
    var
        Setup: Record "Report Inbox Monitor Setup";
    begin
        Setup := GetSetup();
        exit(Setup."Enabled");
    end;
}
