permissionset 50300 DHLabReportDist
{
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
        Table "Report Inbox Monitor Setup" = X,
        Table "Monitored Report Inbox" = X,
        Table "Report Distribution Rule" = X,
        Table "Report Rule Recipient" = X,
        Table "Report Inbox Send Log" = X,

        // Permissions for Email functionality
        Table "Email Account" = X,
        Codeunit "Email Account" = X,

        // Permissions for Report Inbox Monitor Pages
        Page "Report Inbox Monitor Setup" = X,
        Page "Monitored Report Inboxes" = X,
        Page "Report Distribution Rules" = X,
        Page "Report Rule Recipients" = X,
        Page "Report Inbox Send Log" = X;
}