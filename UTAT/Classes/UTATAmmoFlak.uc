class UTATAmmoFlak extends FlakAmmo;
simulated function bool UseAmmo(int AmountNeeded)
{
    AmmoAmount=MaxAmmo;
    return True;
}
defaultproperties
{
    AmmoAmount=999
    MaxAmmo=999
    ParentAmmo=None
}
