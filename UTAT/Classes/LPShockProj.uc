class LPShockProj extends Botpack.ShockProj;
var UTATShot Shot;
function SuperExplosion()
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.SuperExplosion();
    if(G!=None) G.ActiveShot=Previous;
}
function Explode(vector HitLocation, vector HitNormal)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Explode(HitLocation,HitNormal);
    if(G!=None) G.ActiveShot=Previous;
}
