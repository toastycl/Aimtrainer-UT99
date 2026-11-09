// Only this object saves configuration. Player settings are applied in memory.
class UTATStore extends Object config(UTAT);

struct AimProfile
{
    var bool Saved;
    var float Sensitivity;
    var bool NoSmoothing;
    var bool MaxSmoothing;
    var float SmoothThreshold;
};
var config AimProfile Profiles[3];
var config int ActiveProfile;
var config int Exercise; // 0 flick, 1 strafe
var config int WeaponIndex;
var config int Duration;
var config string LastResult;
var config int NetworkEnvironment,AddedRTT,NetworkWeapon;

defaultproperties
{
    Duration=60
}
