class LPUT_Grenade extends Botpack.UT_Grenade;
var UTATShot Shot;
function BlowUp(vector HitLocation)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.BlowUp(HitLocation);
    if(G!=None) G.ActiveShot=Previous;
}
