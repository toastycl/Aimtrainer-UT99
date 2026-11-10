class NPUTChunk3 extends InstaGibPlus_11.ST_UTChunk3;
var UTATNetShot Shot;
function ProcessTouch(Actor Other, vector HitLocation)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.ProcessTouch(Other,HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
