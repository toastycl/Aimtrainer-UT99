// Stock-weapon adapter; delegates firing and damage to the original implementation.
class LCShock extends Botpack.ShockRifle;
function TraceFire(float Accuracy)
{
    local UTATGame G;local UTATShot Previous;
    G=UTATGame(Level.Game);
    if(G!=None) { if(!G.Running) return;Previous=G.ActiveShot;G.ActiveShot=G.NewShot(); }
    Super.TraceFire(Accuracy);
    if(G!=None) G.ActiveShot=Previous;
}
function ProcessTraceHit(Actor Other,vector HitLocation,vector HitNormal,vector X,vector Y,vector Z)
{
    local UTATGame G;local UTATShot Beam;
    G=UTATGame(Level.Game);if(G!=None) Beam=G.ActiveShot;
    Super.ProcessTraceHit(Other,HitLocation,HitNormal,X,Y,Z);
    if(G!=None && Beam!=None && !Beam.Hit && LPShockProj(Other)!=None && LPShockProj(Other).Shot!=None && LPShockProj(Other).Shot.Hit && LPShockProj(Other).Shot.RoundId==Beam.RoundId)
    { Beam.Hit=True;G.Hits++; }
}
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoShock'
    bCanThrow=False
}
