class UTATPulse extends PulseGun;
function AltFire(float Value)
{
    PlayerPawn(Owner).ClientMessage("Primary fire training only in this version.");
}
defaultproperties
{
    bCanThrow=False
}
