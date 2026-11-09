// Optional network experiment. Keeps the IGPlus player class selected by UTPure.
class UTATNetGame extends DeathMatchPlus;
var UTATNetTarget NetTarget;
var string LabWeapon;
function InitGame(string Options,out string Error)
{
    Super.InitGame(Options,Error);
    LabWeapon=ParseOption(Options,"LabWeapon");
    if(!(LabWeapon~="Sniper")) LabWeapon="Shock";
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
    WC=class<Weapon>(DynamicLoadObject("InstaGibPlus_11.ST_"$LabWeapon$"Rifle",class'Class'));
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
