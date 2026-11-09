class UTATWindow extends UWindowFramedWindow;
function Close(optional bool bByParent)
{
    local UTATNetworkState S;
    S=class'UTATNetworkState'.static.Find(GetPlayerOwner());if(S!=None) S.RequestMenu(False);
    Super.Close(bByParent);
}
defaultproperties
{
    WindowTitle="UT99 Aimtrainer / Practice Room - 0.4.0"
    ClientClass=Class'UTAT.UTATPanel'
    bSizable=False
    bStatusBar=False
}
