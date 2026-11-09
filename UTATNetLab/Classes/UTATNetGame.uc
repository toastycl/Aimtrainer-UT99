// Optional network experiment. Keeps the IGPlus player class selected by UTPure.
class UTATNetGame extends DeathMatchPlus;
var UTATNetTarget NetTarget;
var string LabWeapon;
var bool ManualLab;
var int RequestedRTT;
function InitGame(string Options,out string Error)
{
    local int I;local bool Found;
    Super.InitGame(Options,Error);
    ManualLab=HasOption(Options,"ManualLab");
    RequestedRTT=Clamp(GetIntOption(Options,"AddedRTT",100),0,300);
    LabWeapon=ParseOption(Options,"LabWeapon");
    if(LabWeapon=="") LabWeapon="Shock";
    for(I=0;I<11;I++) if(class'UTATWeaponCatalog'.static.Key(I)~=LabWeapon) Found=True;
    if(!Found) Error="Unknown classic weapon";
    InitialBots=0; MinPlayers=0; RemainingBots=0; bTournament=False;
    bRequireReady=False; bNetReady=False; CountDown=0; TimeLimit=0; FragLimit=0;
}
function Timer() { SentText=0; }
function bool AddBot() { return False; }
function bool NeedPlayers() { return False; }
function AddDefaultInventory(Pawn P)
{
    local class<Weapon> WC;
    local Weapon W;
    local string Suffix;
    Suffix=LabWeapon;
    if(LabWeapon~="Shock") Suffix="ShockRifle";else if(LabWeapon~="Sniper") Suffix="SniperRifle";
    else if(LabWeapon~="Minigun") Suffix="minigun2";else if(LabWeapon~="Pulse") Suffix="PulseGun";
    else if(LabWeapon~="Rocket") Suffix="UT_Eightball";else if(LabWeapon~="Flak") Suffix="UT_FlakCannon";
    else if(LabWeapon~="Bio") Suffix="ut_biorifle";else if(LabWeapon~="Hammer") Suffix="ImpactHammer";
    else if(LabWeapon~="Redeemer") Suffix="WarheadLauncher";
    WC=class<Weapon>(DynamicLoadObject("InstaGibPlus_11.ST_"$Suffix,class'Class'));
    if(WC==None) { Log("NETLAB FAIL missing IGPlus 11 weapon"); return; }
    W=Spawn(WC,,,P.Location);
    if(W==None) return;
    W.GiveTo(P); W.GiveAmmo(P); W.SetSwitchPriority(P);
    if(W.AmmoType!=None) W.AmmoType.AmmoAmount=999;
    P.Weapon=W; W.BringUp();
}
function PostLogin(PlayerPawn P)
{
    local UTATNetProbe Probe;
    Super.PostLogin(P);
    P.SetLocation(vect(-1100,0,40)); P.ViewRotation=rot(0,0,0); P.SetRotation(P.ViewRotation);
    NetTarget=Spawn(class'UTATNetTarget',,,vect(0,0,40));
    Probe=Spawn(class'UTATNetProbe',P); Probe.NetTarget=NetTarget;
    Probe.ManualLab=ManualLab; Probe.RequestedRTT=RequestedRTT;
    Log("NETLAB backend pawn="$P.Class$" weapon="$P.Weapon.Class);
}
defaultproperties
{
    GameName="UT99 Aimtrainer - Network Lab (experimental)"
    MaxPlayers=1
    InitialBots=0
    MinPlayers=0
    bRequireReady=False
    bRestartLevel=False
}
