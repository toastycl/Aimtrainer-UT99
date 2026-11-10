// Stock-weapon adapter; delegates firing and damage to the original implementation.
class LCRedeemer extends Botpack.WarheadLauncher;
defaultproperties
{
    AmmoName=Class'UTAT.UTATAmmoRedeemer'
    bCanThrow=False
}
