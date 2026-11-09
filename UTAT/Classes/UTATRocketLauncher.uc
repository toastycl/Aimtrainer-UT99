class UTATRocketLauncher extends UT_Eightball;
function AltFire(float Value)
{
    PlayerPawn(Owner).ClientMessage("Primary fire training only in this version.");
}
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoRocket'
    bCanThrow=False
}
