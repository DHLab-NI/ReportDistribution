permissionset 50300 DHLabReportDist
{
    Assignable = true;
    Caption = 'DHLab Report Distribution';
    Permissions =

        // Permissions for Report Inbox Monitor
        Codeunit "DHLab Report Inbox Monitor" = X,
        Table "Report Inbox" = X,
        Table "User" = X,
        Codeunit "Email Message" = X,
        Codeunit "Email" = X,
        Codeunit "Temp Blob" = X,

        // Permissions for Report Inbox Monitor Configuration Tables
        tabledata "Report Inbox Monitor Setup" = RIMD,
        tabledata "Monitored Report Inbox" = RIMD,
        tabledata "Report Distribution Rule" = RIMD,
        tabledata "Report Rule Recipient" = RIMD,
        tabledata "Report Inbox Send Log" = RIMD,

        // Permissions for Email functionality
        Table "Email Account" = X,
        Codeunit "Email Account" = X,

        // Permissions for Report Inbox Monitor Pages
        Page "Report Inbox Monitor Setup" = X,
        Page "Monitored Report Inboxes" = X,
        Page "Monitored Report Inbox Card" = X,
        Page "Report Distribution Rules" = X,
        Page "Report Distribution Rule Card" = X,
        Page "Report Dist Rules Subpage" = X,
        Page "Report Rule Recipients" = X,
        Page "Report Inbox Send Log" = X;
}