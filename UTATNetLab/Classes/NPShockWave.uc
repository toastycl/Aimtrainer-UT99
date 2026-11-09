class NPShockWave extends InstaGibPlus_11.ST_ShockWave;
var UTATNetShot Shot;
simulated function Timer()
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Timer();
    if(G!=None) G.ActiveShot=Previous;
}
