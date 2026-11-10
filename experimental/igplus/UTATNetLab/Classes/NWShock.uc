// Instrumentation adapter: all firing/damage behavior delegates to IGPlus.
class NWShock extends InstaGibPlus_11.ST_ShockRifle;
simulated function bool ClientFire(float Value)
{
    if(!class'UTATNetworkState'.static.CanFire(Self,True)) return False;
    return Super.ClientFire(Value);
}
simulated function bool ClientAltFire(float Value)
{
    if(!class'UTATNetworkState'.static.CanFire(Self,False)) return False;
    return Super.ClientAltFire(Value);
}
function Fire(float Value)
{
    if(!class'UTATNetworkState'.static.CanFire(Self,True)) return;
    Super.Fire(Value);
}
function AltFire(float Value)
{
    if(!class'UTATNetworkState'.static.CanFire(Self,False)) return;
    Super.AltFire(Value);
}
function TraceFire(float Accuracy)
{
    local UTATRoundGame G;local UTATNetShot Previous;
    G=UTATRoundGame(Level.Game);
    if(G!=None) { if(!G.Running) return;Previous=G.ActiveShot;G.ActiveShot=G.NewShot(); }
    Super.TraceFire(Accuracy);
    if(G!=None) G.ActiveShot=Previous;
}
function ProcessTraceHit(Actor Other,vector HitLocation,vector HitNormal,vector X,vector Y,vector Z)
{
    local UTATRoundGame G;local UTATNetShot Beam;
    G=UTATRoundGame(Level.Game);if(G!=None) Beam=G.ActiveShot;
    Super.ProcessTraceHit(Other,HitLocation,HitNormal,X,Y,Z);
    if(G!=None && Beam!=None && !Beam.Hit && NPShockProj(Other)!=None && NPShockProj(Other).Shot!=None && NPShockProj(Other).Shot.Hit && NPShockProj(Other).Shot.RoundId==Beam.RoundId)
    { Beam.Hit=True;G.StateInfo.Hits++; }
}
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoShock'
    bCanThrow=False
}
