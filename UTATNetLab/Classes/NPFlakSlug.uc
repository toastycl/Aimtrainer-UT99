class NPFlakSlug extends InstaGibPlus_11.ST_FlakSlug;
var UTATNetShot Shot;
function NewExplode(vector HitLocation, vector HitNormal)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.NewExplode(HitLocation,HitNormal);
    if(G!=None) G.ActiveShot=Previous;
}
