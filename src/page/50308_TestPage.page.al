page 50308 "Test Page"
{
    Caption = 'Test Page';
    PageType = Card;
    UsageCategory = Administration;
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field(TestField; 'Test Value')
                {
                    ApplicationArea = All;
                    Caption = 'Test Field';
                }
            }
        }
    }
}
