class LPWarShell extends Botpack.WarShell;
var UTATShot Shot;
singular function TakeDamage(int Damage,Pawn InstigatedBy,vector HitLocation,vector Momentum,name DamageType)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);if(G!=None) {Previous=G.ActiveShot;G.ActiveShot=Shot;}
    Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
    if(G!=None) G.ActiveShot=Previous;
}
auto state Flying
{
function Explode(vector HitLocation, vector HitNormal)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Explode(HitLocation,HitNormal);
    if(G!=None) G.ActiveShot=Previous;
}
}
