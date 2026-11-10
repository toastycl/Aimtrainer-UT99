class UTATHistoryPanel extends UWindowDialogClientWindow;
var UTATStore Store;
var UWindowSmallButton PreviousButton,NextButton,BackButton;
var int Page;
var bool Painted; // Native client regression observes an actual rendered history frame.
function Created()
{
    Super.Created();Store=new(None) class'UTATStore';
    PreviousButton=UWindowSmallButton(CreateControl(class'UWindowSmallButton',16,344,170,24));PreviousButton.SetText("Newer rounds");
    NextButton=UWindowSmallButton(CreateControl(class'UWindowSmallButton',194,344,170,24));NextButton.SetText("Older rounds");
    BackButton=UWindowSmallButton(CreateControl(class'UWindowSmallButton',372,344,190,24));BackButton.SetText("Back to setup");
}
function Paint(Canvas C,float X,float Y)
{
    local int I,Index,Count,RowY;
    Super.Paint(C,X,Y);Painted=True;C.Font=Root.Fonts[F_Normal];
    C.DrawColor.R=20;C.DrawColor.G=20;C.DrawColor.B=20;
    Count=Clamp(Store.HistoryCount,0,10);
    ClipText(C,16,12,"ROUND HISTORY / newest first / page "$(Page+1));
    ClipText(C,16,34,"Compare the same settings and fire style across several rounds.");
    if(Count==0) ClipText(C,16,76,"No rounds saved yet. Finish a practice round to see it here.");
    for(I=0;I<3;I++)
    {
        Index=Page*3+I;if(Index>=Count) break;
        RowY=70+I*88;
        ClipText(C,16,RowY,Store.HistoryLine(Index,0));
        ClipText(C,16,RowY+20,Store.HistoryLine(Index,1));
        ClipText(C,16,RowY+40,Store.HistoryLine(Index,2));
        ClipText(C,16,RowY+60,Store.HistoryLine(Index,3));
    }
    PreviousButton.bDisabled=Page==0;NextButton.bDisabled=(Page+1)*3>=Count;
}
function Notify(UWindowDialogControl C,byte E)
{
    Super.Notify(C,E);if(E!=DE_Click) return;
    if(C==PreviousButton) Page=Max(0,Page-1);
    else if(C==NextButton && (Page+1)*3<Min(10,Store.HistoryCount)) Page++;
    else if(C==BackButton) ParentWindow.Close();
}
