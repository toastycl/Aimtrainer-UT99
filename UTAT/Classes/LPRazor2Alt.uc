class LPRazor2Alt extends Botpack.Razor2Alt;
var UTATShot Shot;
auto state Flying
{
function ProcessTouch(Actor Other, vector HitLocation)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.ProcessTouch(Other,HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
function BlowUp(vector HitLocation)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.BlowUp(HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
}
