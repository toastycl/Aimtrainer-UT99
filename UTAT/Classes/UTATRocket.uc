class UTATRocket extends RocketMk2;
var UTATShot Shot;
auto state Flying
{
function BlowUp(vector HitLocation)
{
    local UTATGame G;
    local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot; G.ActiveShot=Shot; }
    Super.BlowUp(HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
}
