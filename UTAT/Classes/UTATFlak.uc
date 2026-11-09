class UTATFlak extends UT_FlakCannon;
function AltFire(float Value)
{
    PlayerPawn(Owner).ClientMessage("Primary fire training only in this version.");
}
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoFlak'
    bCanThrow=False
}
