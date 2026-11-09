class UTATSniper extends SniperRifle;
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
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoSniper'
    bCanThrow=False
}
