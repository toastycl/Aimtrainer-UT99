// Stock-weapon adapter; delegates firing and damage to the original implementation.
class LCRipper extends Botpack.ripper;
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoRipper'
    bCanThrow=False
}
