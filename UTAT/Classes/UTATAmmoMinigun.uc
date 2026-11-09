class UTATAmmoMinigun extends Miniammo;
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
