class UTATSetupOpener extends Info;
var float Age;
function Tick(float Delta)
{
    local UTATPlayer P;
    Age+=Delta;
    if(Age<1) return;
    foreach AllActors(class'UTATPlayer',P) if(P.Player!=None) { P.ShowTrainingPanel();Destroy();return; }
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
