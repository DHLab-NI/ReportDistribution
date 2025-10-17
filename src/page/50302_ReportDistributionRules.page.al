page 50302 "Report Distribution Rules"
{
    Caption = 'Report Distribution Rules';
    PageType = List;
    SourceTable = "Report Distribution Rule";
    UsageCategory = Administration;
    Editable = false;
    ApplicationArea = All;
    InsertAllowed = false;

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
                    ToolTip = 'Specifies the unique code for this distribution rule. Click to edit the rule.';

                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"Report Distribution Rule Card", Rec);
                    end;
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
            action("Edit Rule")
            {
                ApplicationArea = All;
                Caption = 'Edit Rule';
                Image = Edit;
                RunObject = Page "Report Distribution Rule Card";
                RunPageLink = "Code" = field("Code");
                ToolTip = 'Open the rule card to edit all fields including templates.';
            }

            action("New Rule")
            {
                ApplicationArea = All;
                Caption = 'New Rule';
                Image = New;
                ToolTip = 'Create a new distribution rule.';

                trigger OnAction()
                var
                    ReportDistributionRule: Record "Report Distribution Rule";
                    ReportDistributionRuleCard: Page "Report Distribution Rule Card";
                begin
                    // Initialize a new record (defaults will be applied automatically)
                    ReportDistributionRule.Init();

                    // Open the card page for the new record
                    ReportDistributionRuleCard.SetTableview(ReportDistributionRule);
                    ReportDistributionRuleCard.RunModal();
                end;
            }

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
