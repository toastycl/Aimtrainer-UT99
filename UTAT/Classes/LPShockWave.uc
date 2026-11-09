class LPShockWave extends Botpack.ShockWave;
var UTATShot Shot;
simulated function Timer()
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Timer();
    if(G!=None) G.ActiveShot=Previous;
}
