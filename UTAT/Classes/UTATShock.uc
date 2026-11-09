class UTATShock extends ShockRifle;
function TraceFire(float Accuracy)
{
    local UTATGame G;
    local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None)
    {
        Previous=G.ActiveShot;
        G.ActiveShot=G.NewShot();
    }
    Super.TraceFire(Accuracy);
    if(G!=None) G.ActiveShot=Previous;
}
function AltFire(float Value) { PlayerPawn(Owner).ClientMessage("Primary fire training only in this version."); }
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoShock'
    bCanThrow=False
}
