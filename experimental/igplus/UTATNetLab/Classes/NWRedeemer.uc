// Instrumentation adapter: all firing/damage behavior delegates to IGPlus.
class NWRedeemer extends InstaGibPlus_11.ST_WarheadLauncher;
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
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoRedeemer'
    bCanThrow=False
}
