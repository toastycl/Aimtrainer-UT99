// Stock-weapon adapter; delegates firing and damage to the original implementation.
class LCHammer extends Botpack.ImpactHammer;
function TraceFire(float Accuracy)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { if(!G.Running) return;Previous=G.ActiveShot;G.ActiveShot=G.NewShot(); }
    Super.TraceFire(Accuracy);
    if(G!=None) G.ActiveShot=Previous;
}
function TraceAltFire()
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { if(!G.Running) return;Previous=G.ActiveShot;G.ActiveShot=G.NewShot(); }
    Super.TraceAltFire();
    if(G!=None) G.ActiveShot=Previous;
}
defaultproperties
{
    bCanThrow=False
}
