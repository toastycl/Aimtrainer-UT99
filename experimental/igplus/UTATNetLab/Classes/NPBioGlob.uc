class NPBioGlob extends InstaGibPlus_11.ST_BioGlob;
var UTATNetShot Shot;
function Timer()
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Timer();
    if(G!=None) G.ActiveShot=Previous;
}
function SpawnSplash()
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.SpawnSplash();
    if(G!=None) G.ActiveShot=Previous;
}
