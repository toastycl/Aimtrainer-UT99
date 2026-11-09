class UTATPlasma extends PlasmaSphere;
var UTATShot Shot;
simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local UTATGame G;
    local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot; G.ActiveShot=Shot; }
    Super.ProcessTouch(Other,HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
