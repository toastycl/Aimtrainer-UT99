// Labels and geometry shared by setup, results, history and native checks.
class UTATTrainingOptions extends Object;
static function string Exercise(int Mode)
{
    switch(Mode) {case 1:return "Lateral strafe";case 2:return "Evasive / jumps";case 3:return "Random aerial";}
    return "Static";
}
static function string Distance(int Mode)
{
    switch(Mode) {case 1:return "Close";case 2:return "Medium";case 3:return "Far";}
    return "Mixed distance";
}
static function string Size(int Mode)
{
    switch(Mode) {case 1:return "Small";case 2:return "Large";}
    return "Normal";
}
static function float Scale(int Mode)
{
    switch(Mode) {case 1:return 0.6;case 2:return 1.4;}
    return 1.0;
}
static function float MinDistance(int Mode)
{
    switch(Mode) {case 2:return 1150;case 3:return 1750;}
    return 700;
}
static function float MaxDistance(int Mode)
{
    switch(Mode) {case 1:return 1050;case 2:return 1550;case 3:return 2300;}
    return 2700;
}
