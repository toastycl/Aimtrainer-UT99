class NPUT_SeekingRocket extends InstaGibPlus_11.ST_UT_SeekingRocket;
var UTATNetShot Shot;
auto state Flying
{
function BlowUp(vector HitLocation)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.BlowUp(HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
}
