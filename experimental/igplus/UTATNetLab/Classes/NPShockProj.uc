class NPShockProj extends InstaGibPlus_11.ST_ShockProj;
var UTATNetShot Shot;
function SuperExplosion()
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.SuperExplosion();
    if(G!=None) G.ActiveShot=Previous;
}
function Explode(vector HitLocation, vector HitNormal)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Explode(HitLocation,HitNormal);
    if(G!=None) G.ActiveShot=Previous;
}
