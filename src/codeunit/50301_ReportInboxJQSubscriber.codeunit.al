codeunit 50301 "Report Inbox JQ Subscriber"
{
    // Populates JQ Description on new Report Inbox entries by finding the in-progress
    // Job Queue Entry for the same report and user at the time of insertion.

    [EventSubscriber(ObjectType::Table, Database::"Report Inbox", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertReportInbox(var Rec: Record "Report Inbox"; RunTrigger: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // Find the in-progress JQE for this report and user
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Rec."Report ID");
        JobQueueEntry.SetRange("User ID", Rec."User ID");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.FindFirst() then begin
            // Fallback: match on report ID only (covers cases where user IDs differ)
            JobQueueEntry.SetRange("User ID");
            if not JobQueueEntry.FindFirst() then
                exit;
        end;

        if JobQueueEntry.Description = '' then
            exit;

        Rec."JQ Description" := JobQueueEntry.Description;
        Rec.Modify(false);
    end;
}
