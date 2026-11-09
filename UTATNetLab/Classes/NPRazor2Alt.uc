class NPRazor2Alt extends InstaGibPlus_11.ST_Razor2Alt;
var UTATNetShot Shot;
auto state Flying
{
function ProcessTouch(Actor Other, vector HitLocation)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.ProcessTouch(Other,HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
function BlowUp(vector HitLocation)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.BlowUp(HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
}
