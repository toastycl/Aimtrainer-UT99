class UTATAmmoRocket extends RocketPack;
function bool UseAmmo(int AmountNeeded)
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
