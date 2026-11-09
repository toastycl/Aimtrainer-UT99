class LPBioGlob extends Botpack.BioGlob;
var UTATShot Shot;
function Timer()
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Timer();
    if(G!=None) G.ActiveShot=Previous;
}
function SpawnSplash()
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.SpawnSplash();
    if(G!=None) G.ActiveShot=Previous;
}
