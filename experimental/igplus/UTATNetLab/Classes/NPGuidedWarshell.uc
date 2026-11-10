class NPGuidedWarshell extends InstaGibPlus_11.ST_GuidedWarshell;
var UTATNetShot Shot;
singular function TakeDamage(int Damage,Pawn InstigatedBy,vector HitLocation,vector Momentum,name DamageType)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);if(G!=None) {Previous=G.ActiveShot;G.ActiveShot=Shot;}
    Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
    if(G!=None) G.ActiveShot=Previous;
}
auto state Flying
{
function Explode(vector HitLocation, vector HitNormal)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { Previous=G.ActiveShot;G.ActiveShot=Shot; }
    Super.Explode(HitLocation,HitNormal);
    if(G!=None) G.ActiveShot=Previous;
}
}
