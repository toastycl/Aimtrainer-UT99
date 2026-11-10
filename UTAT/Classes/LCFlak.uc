// Stock-weapon adapter; delegates firing and damage to the original implementation.
class LCFlak extends Botpack.UT_FlakCannon;
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoFlak'
    bCanThrow=False
}
