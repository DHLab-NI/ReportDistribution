page 50303 "Report Rule Recipients"
{
    Caption = 'Report Rule Recipients';
    PageType = ListPart;
    SourceTable = "Report Rule Recipient";
    UsageCategory = Administration;
    Editable = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies whether this recipient is a To, Cc, or Bcc recipient.';
                }
                field("Email Address"; Rec."Email Address")
                {
                    ApplicationArea = All;
                    Caption = 'Email Address';
                    ToolTip = 'Specifies the email address of the recipient.';
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the recipient (optional).';
                }
                field("Email Display Text"; Rec.GetEmailDisplayText())
                {
                    ApplicationArea = All;
                    Caption = 'Display Text';
                    ToolTip = 'Shows how the email address will be displayed.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Add To Recipient")
            {
                ApplicationArea = All;
                Caption = 'Add To Recipient';
                Image = Add;
                ToolTip = 'Add a new To recipient.';

                trigger OnAction()
                var
                    RuleRecipient: Record "Report Rule Recipient";
                begin
                    RuleRecipient.Init();
                    RuleRecipient."Rule Code" := Rec."Rule Code";
                    RuleRecipient."Type" := 0; // To
                    RuleRecipient.Insert(true);

                    // Refresh the page
                    CurrPage.Update(false);
                end;
            }

            action("Add Cc Recipient")
            {
                ApplicationArea = All;
                Caption = 'Add Cc Recipient';
                Image = Add;
                ToolTip = 'Add a new Cc recipient.';

                trigger OnAction()
                var
                    RuleRecipient: Record "Report Rule Recipient";
                begin
                    RuleRecipient.Init();
                    RuleRecipient."Rule Code" := Rec."Rule Code";
                    RuleRecipient."Type" := 1; // Cc
                    RuleRecipient.Insert(true);

                    // Refresh the page
                    CurrPage.Update(false);
                end;
            }

            action("Add Bcc Recipient")
            {
                ApplicationArea = All;
                Caption = 'Add Bcc Recipient';
                Image = Add;
                ToolTip = 'Add a new Bcc recipient.';

                trigger OnAction()
                var
                    RuleRecipient: Record "Report Rule Recipient";
                begin
                    RuleRecipient.Init();
                    RuleRecipient."Rule Code" := Rec."Rule Code";
                    RuleRecipient."Type" := 2; // Bcc
                    RuleRecipient.Insert(true);

                    // Refresh the page
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Rule Code" = '' then
            Rec."Rule Code" := xRec."Rule Code";
    end;
}
