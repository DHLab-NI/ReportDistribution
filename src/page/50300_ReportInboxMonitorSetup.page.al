page 50300 "Report Inbox Monitor Setup"
{
    Caption = 'Report Inbox Monitor Setup';
    PageType = Card;
    SourceTable = "Report Inbox Monitor Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether the Report Inbox Monitor is enabled.';
                }
                field("Default Preferred Sender Email"; Rec."Default Preferred Sender Email")
                {
                    ApplicationArea = All;
                    Caption = 'Default Preferred Sender Email';
                    ToolTip = 'Specifies the default email address to use as sender when no specific sender is configured.';
                }
            }

            group("Date Range")
            {
                Caption = 'Date Range';

                field("Date Range Mode"; Rec."Date Range Mode")
                {
                    ApplicationArea = All;
                    Caption = 'Date Range Mode';
                    ToolTip = 'Specifies whether to monitor reports from today only or use custom date formulas.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("From Date Formula"; Rec."From Date Formula")
                {
                    ApplicationArea = All;
                    Caption = 'From Date Formula';
                    ToolTip = 'Specifies the date formula for the start date when using Custom Formula mode.';
                    Editable = (Rec."Date Range Mode" = 1);
                }
                field("To Date Formula"; Rec."To Date Formula")
                {
                    ApplicationArea = All;
                    Caption = 'To Date Formula';
                    ToolTip = 'Specifies the date formula for the end date when using Custom Formula mode.';
                    Editable = (Rec."Date Range Mode" = 1);
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Monitored Inboxes")
            {
                ApplicationArea = All;
                Caption = 'Monitored Inboxes';
                Image = Email;
                RunObject = Page "Monitored Report Inboxes";
                ToolTip = 'Open the list of monitored report inboxes.';
            }

            action("Distribution Rules")
            {
                ApplicationArea = All;
                Caption = 'Distribution Rules';
                Image = Setup;
                RunObject = Page "Report Distribution Rules";
                ToolTip = 'Open the list of report distribution rules.';
            }

            action("Send Log")
            {
                ApplicationArea = All;
                Caption = 'Send Log';
                Image = Log;
                RunObject = Page "Report Inbox Send Log";
                ToolTip = 'Open the report inbox send log.';
            }
        }

        area(Processing)
        {
            action("Test Monitor")
            {
                ApplicationArea = All;
                Caption = 'Test Monitor';
                Image = TestReport;
                ToolTip = 'Run the Report Inbox Monitor to test the configuration.';

                trigger OnAction()
                var
                    ReportInboxMonitor: Codeunit "DHLab Report Inbox Monitor";
                begin
                    if not Rec."Enabled" then
                        Error('The Report Inbox Monitor is not enabled. Please enable it first.');

                    ReportInboxMonitor.Run();
                    Message('Report Inbox Monitor test completed. Check the Send Log for results.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec."Date Range Mode" := Rec."Date Range Mode"::Today;
            Rec.Insert();
        end;
    end;

}
