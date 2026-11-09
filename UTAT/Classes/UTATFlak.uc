class UTATFlak extends UT_FlakCannon;
function AltFire(float Value)
{
    PlayerPawn(Owner).ClientMessage("Primary fire training only in this version.");
}
defaultproperties
{
    bCanThrow=False
}
