page 50305 "Report Inbox Send Log"
{
    Caption = 'Report Inbox Send Log';
    PageType = List;
    SourceTable = "Report Inbox Send Log";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the unique entry number.';
                }
                field("Sent Datetime"; Rec."Sent Datetime")
                {
                    ApplicationArea = All;
                    Caption = 'Sent Datetime';
                    ToolTip = 'Specifies when the email was sent.';
                }
                field("Inbox Code"; Rec."Inbox Code")
                {
                    ApplicationArea = All;
                    Caption = 'Inbox Code';
                    ToolTip = 'Specifies the monitored inbox code.';
                }
                field("Rule Code"; Rec."Rule Code")
                {
                    ApplicationArea = All;
                    Caption = 'Rule Code';
                    ToolTip = 'Specifies the distribution rule that was used.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'Specifies the user whose report was processed.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    Caption = 'Report ID';
                    ToolTip = 'Specifies the report ID that was sent.';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = All;
                    Caption = 'Report Name';
                    ToolTip = 'Specifies the name of the report that was sent.';
                }
                field("Created Datetime"; Rec."Created Datetime")
                {
                    ApplicationArea = All;
                    Caption = 'Created Datetime';
                    ToolTip = 'Specifies when the report was originally created.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies whether the email was sent successfully or failed.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Shows the error message if the send failed.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Open Report Inbox")
            {
                ApplicationArea = All;
                Caption = 'Open Report Inbox';
                Image = Email;
                ToolTip = 'Open the original Report Inbox entry.';

                trigger OnAction()
                var
                    ReportInbox: Record "Report Inbox";
                begin
                    if ReportInbox.Get(Rec."Report Inbox Entry No.") then
                        Page.RunModal(Page::"Report Inbox", ReportInbox)
                    else
                        Error('Report Inbox entry %1 not found.', Rec."Report Inbox Entry No.");
                end;
            }
        }

        area(Processing)
        {
            action("Clear Old Entries")
            {
                ApplicationArea = All;
                Caption = 'Clear Old Entries';
                Image = Delete;
                ToolTip = 'Delete log entries older than 30 days.';

                trigger OnAction()
                var
                    ConfirmMsg: Label 'This will delete all log entries older than 30 days. Do you want to continue?';
                    DeleteCount: Integer;
                begin
                    if not Confirm(ConfirmMsg) then
                        exit;

                    Rec.SetRange("Sent Datetime", 0DT, CreateDateTime(Today - 30, 0T));
                    DeleteCount := Rec.Count;

                    if DeleteCount > 0 then begin
                        Rec.DeleteAll(true);
                        Message('Deleted %1 log entries older than 30 days.', DeleteCount);
                    end else
                        Message('No entries older than 30 days found.');

                    CurrPage.Update(false);
                end;
            }

            action("Export to Excel")
            {
                ApplicationArea = All;
                Caption = 'Export to Excel';
                Image = ExportToExcel;
                ToolTip = 'Export the send log to Excel.';

                trigger OnAction()
                var
                    TempExcelBuffer: Record "Excel Buffer" temporary;
                    LineNo: Integer;
                begin
                    TempExcelBuffer.Reset();
                    TempExcelBuffer.DeleteAll();

                    // Add headers
                    LineNo := 1;
                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 1);
                    TempExcelBuffer.Validate("Cell Value as Text", 'Sent Datetime');
                    TempExcelBuffer.Insert(true);

                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 2);
                    TempExcelBuffer.Validate("Cell Value as Text", 'Inbox Code');
                    TempExcelBuffer.Insert(true);

                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 3);
                    TempExcelBuffer.Validate("Cell Value as Text", 'Rule Code');
                    TempExcelBuffer.Insert(true);

                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 4);
                    TempExcelBuffer.Validate("Cell Value as Text", 'User ID');
                    TempExcelBuffer.Insert(true);

                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 5);
                    TempExcelBuffer.Validate("Cell Value as Text", 'Report Name');
                    TempExcelBuffer.Insert(true);

                    TempExcelBuffer.Init();
                    TempExcelBuffer.Validate("Row No.", LineNo);
                    TempExcelBuffer.Validate("Column No.", 6);
                    TempExcelBuffer.Validate("Cell Value as Text", 'Status');
                    TempExcelBuffer.Insert(true);

                    // Add data
                    if Rec.FindSet() then
                        repeat
                            LineNo += 1;

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 1);
                            TempExcelBuffer.Validate("Cell Value as Text", Format(Rec."Sent Datetime"));
                            TempExcelBuffer.Insert(true);

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 2);
                            TempExcelBuffer.Validate("Cell Value as Text", Rec."Inbox Code");
                            TempExcelBuffer.Insert(true);

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 3);
                            TempExcelBuffer.Validate("Cell Value as Text", Rec."Rule Code");
                            TempExcelBuffer.Insert(true);

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 4);
                            TempExcelBuffer.Validate("Cell Value as Text", Rec."User ID");
                            TempExcelBuffer.Insert(true);

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 5);
                            TempExcelBuffer.Validate("Cell Value as Text", Rec."Report Name");
                            TempExcelBuffer.Insert(true);

                            TempExcelBuffer.Init();
                            TempExcelBuffer.Validate("Row No.", LineNo);
                            TempExcelBuffer.Validate("Column No.", 6);
                            TempExcelBuffer.Validate("Cell Value as Text", Format(Rec."Status"));
                            TempExcelBuffer.Insert(true);
                        until Rec.Next() = 0;

                    TempExcelBuffer.CreateNewBook('Report Inbox Send Log');
                    TempExcelBuffer.WriteSheet('Send Log', CompanyName, UserId);
                    TempExcelBuffer.CloseBook();
                    TempExcelBuffer.OpenExcel();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Set default filter to show recent entries
        Rec.SetCurrentKey("Sent Datetime");
        Rec.Ascending(false);
    end;
}
