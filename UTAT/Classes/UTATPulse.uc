class UTATPulse extends PulseGun;
function AltFire(float Value)
{
    PlayerPawn(Owner).ClientMessage("Primary fire training only in this version.");
}
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoPulse'
    bCanThrow=False
}
