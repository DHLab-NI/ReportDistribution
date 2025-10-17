page 50301 "Monitored Report Inboxes"
{
    Caption = 'Monitored Report Inboxes';
    PageType = List;
    SourceTable = "Monitored Report Inbox";
    UsageCategory = Administration;
    Editable = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique code for this monitored inbox.';
                }
                field("User ID to Monitor"; Rec."User ID to Monitor")
                {
                    ApplicationArea = All;
                    Caption = 'User ID to Monitor';
                    ToolTip = 'Specifies the User ID whose Report Inbox will be monitored.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description for this monitored inbox.';
                }
                field("Enabled"; Rec."Enabled")
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether this inbox is being monitored.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the company name if cross-company monitoring is needed.';
                }
                field("Override Sender Email"; Rec."Override Sender Email")
                {
                    ApplicationArea = All;
                    Caption = 'Override Sender Email';
                    ToolTip = 'Specifies an override sender email for this inbox.';
                }
            }
        }

        area(FactBoxes)
        {
            part("Dist Rules"; "Report Dist Rules Subpage")
            {
                ApplicationArea = All;
                Caption = 'Distribution Rules';
                SubPageLink = "Inbox Code" = field("Code");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("View Distribution Rules")
            {
                ApplicationArea = All;
                Caption = 'Distribution Rules';
                Image = Setup;
                RunObject = Page "Report Distribution Rules";
                RunPageLink = "Inbox Code" = field("Code");
                ToolTip = 'View and manage distribution rules for this inbox.';
            }
        }

        area(Processing)
        {
            action("Test Inbox")
            {
                ApplicationArea = All;
                Caption = 'Test Inbox';
                Image = TestReport;
                ToolTip = 'Test the monitoring for this specific inbox.';

                trigger OnAction()
                var
                    ReportInboxMonitor: Codeunit "DHLab Report Inbox Monitor";
                begin
                    if not Rec."Enabled" then
                        Error('This inbox is not enabled for monitoring.');

                    // TODO: Modify codeunit to accept inbox code parameter
                    ReportInboxMonitor.Run();
                    Message('Test completed for inbox: %1', Rec."Code");
                end;
            }
        }
    }
}
