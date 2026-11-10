class UTATAboutPanel extends UWindowDialogClientWindow;
var UWindowSmallButton CloseButton;
function Created()
{
    Super.Created();
    CloseButton=UWindowSmallButton(CreateControl(class'UWindowSmallButton',16,302,392,24));
    CloseButton.SetText("Back to training setup");
}
function Paint(Canvas C,float X,float Y)
{
    Super.Paint(C,X,Y);
    C.Font=Root.Fonts[F_Normal];
    C.DrawColor.R=20; C.DrawColor.G=20; C.DrawColor.B=20;
    ClipText(C,16,16,"UT99 AIMTRAINER");
    ClipText(C,16,44,class'UTATAboutInfo'.static.AuthorText());
    ClipText(C,16,68,class'UTATAboutInfo'.static.BuildText());
    ClipText(C,16,104,"A practice tool for the entire UT99 community.");
    ClipText(C,16,128,"11 classic weapons / static or moving targets.");
    ClipText(C,16,152,"Random spawns / unlimited ammo / round accuracy.");
    ClipText(C,16,188,"Use your usual mouse DPI, sensitivity and input.");
    ClipText(C,16,212,"DPI and hardware latency are not measured.");
    ClipText(C,16,248,"Install mod + map and play. No helper required.");
    ClipText(C,16,272,"github.com/toastycl/aimtrainer-ut99");
}
function Notify(UWindowDialogControl C,byte E)
{
    Super.Notify(C,E);
    if(C==CloseButton && E==DE_Click) ParentWindow.Close();
}
