page 50307 "Report Dist Rules Subpage"
{
    Caption = 'Distribution Rules';
    PageType = ListPart;
    SourceTable = "Report Distribution Rule";
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
                    ToolTip = 'Specifies the unique code for this distribution rule.';
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Edit Rule")
            {
                ApplicationArea = All;
                Caption = 'Edit Rule';
                Image = Edit;
                RunObject = Page "Report Distribution Rule Card";
                RunPageLink = "Code" = field("Code");
                ToolTip = 'Open the rule card for editing.';
            }
        }
    }
}
