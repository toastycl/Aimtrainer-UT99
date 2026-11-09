class UTATGame extends DeathMatchPlus;
var UTATPlayer Trainee;
var UTATTarget Targets[3];
var UTATShot ActiveShot;
var UTATRoomInfo Room;
var UTATRoundController RoundController;
var float RoundElapsed, ResultsAt;
var int RandomSeed, RoundSeed, PendingWeapon, PendingExercise, PendingSeconds;
var bool AutoStart, ResultsDismissed, AutoStartCheck;
var bool Running, HasResult, LastComplete;
var int Shots, Hits, Eliminations, DamageDealt, RoundId, ExerciseMode, SessionDuration, WeaponIndex;
var float StartedAt, LastElapsed, SessionFOV;
var vector Anchor, ForwardAxis, SideAxis;
var rotator AnchorRotation;
var string Snapshot, LastSummary;
var bool SmokeTest, ClientTest;

function InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);
    SmokeTest = HasOption(Options, "SmokeTest");
    ClientTest = HasOption(Options, "ClientTest");
    AutoStart=HasOption(Options,"AutoStart");
    AutoStartCheck=HasOption(Options,"AutoStartCheck");
    PendingWeapon=Clamp(GetIntOption(Options,"LabWeapon",0),0,5);
    PendingExercise=Clamp(GetIntOption(Options,"LabExercise",0),0,1);
    PendingSeconds=Clamp(GetIntOption(Options,"LabSeconds",60),0,300);
    RandomSeed=Rand(65535)+1;
    // Global DeathMatch bot/tournament preferences must never populate the room.
    MinPlayers=0; InitialBots=0; RemainingBots=0;
    bTournament=False; bRatedGame=False; bRequireReady=False; bNetReady=False;
    CountDown=0; TimeLimit=0; FragLimit=0; RemainingTime=0;
    MaxPlayers=1; bRestartLevel=False;
}
event PlayerPawn Login(string Portal, string Options, out string Error, class<PlayerPawn> SpawnClass)
{
    if (Level.NetMode != NM_Standalone)
    {
        Error = "Aimtrainer is local-only in this version.";
        return None;
    }
    return Super.Login(Portal, Options, Error, class'UTATPlayer');
}
function PostBeginPlay()
{
    local Inventory I;
    InitialBots=0; MinPlayers=0;
    Super.PostBeginPlay();
    RemainingBots=0; bRequireReady=False; bNetReady=False; CountDown=0;
    foreach AllActors(class'Inventory', I)
        if (I.Owner == None) I.Destroy();
    foreach AllActors(class'UTATRoomInfo', Room) break;
    Spawn(class'UTATProjectileNotify');
    RoundController=Spawn(class'UTATRoundController');
    if(RoundController!=None) RoundController.Trainer=Self;
    if (SmokeTest) Spawn(class'UTATSmokeTest');
    if (ClientTest) Spawn(class'UTATClientTest');
}
// This lab never enters DeathMatch ready/bot-fill/end-match logic.
function Timer() { SentText=0; }
function bool AddBot() { return False; }
function bool ForceAddBot() { return False; }
function bool NeedPlayers() { return False; }
function int ReduceDamage(int Damage,name DamageType,Pawn Injured,Pawn InstigatedBy)
{
    if(UTATPlayer(Injured)!=None) return 0;
    return Super.ReduceDamage(Damage,DamageType,Injured,InstigatedBy);
}
event PostLogin(PlayerPawn NewPlayer)
{
    RemainingBots=0;
    Super.PostLogin(NewPlayer);
    if(UTATPlayer(NewPlayer)!=None)
    {
        Trainee=UTATPlayer(NewPlayer);
        PlaceTrainee(Trainee);
        Trainee.ClientMessage("Practice room ready. Open Mods > UT99 Aimtrainer to start a round.");
    }
}
static function string WeaponLabel(int Index)
{
    switch(Index)
    {
        case 0: return "Shock Rifle";
        case 1: return "Sniper Rifle";
        case 2: return "Minigun";
        case 3: return "Pulse Gun";
        case 4: return "Rocket Launcher";
        case 5: return "Flak Cannon";
    }
    return "Unknown";
}
static function string UnitLabel(int Index)
{
    if (Index == 5) return "fragment";
    if (Index >= 3) return "projectile";
    return "trace";
}
function GiveTrainingWeapon(UTATPlayer P, int Index)
{
    local Inventory I, N;
    local Weapon W;
    local class<Weapon> WC;
    if (Running || P == None) return;
    Index = Clamp(Index,0,5);
    for (I=P.Inventory; I!=None; I=N)
    {
        N=I.Inventory;
        P.DeleteInventory(I);
        I.Destroy();
    }
    P.Weapon=None;
    P.PendingWeapon=None;
    switch(Index)
    {
        case 0: WC=class'UTATShock'; break;
        case 1: WC=class'UTATSniper'; break;
        case 2: WC=class'UTATMinigun'; break;
        case 3: WC=class'UTATPulse'; break;
        case 4: WC=class'UTATRocketLauncher'; break;
        case 5: WC=class'UTATFlak'; break;
    }
    W=Spawn(WC);
    if (W == None) return;
    W.GiveTo(P);
    W.GiveAmmo(P);
    if(W.AmmoType!=None) W.AmmoType.AmmoAmount=W.AmmoType.MaxAmmo;
    W.SetSwitchPriority(P);
    W.WeaponSet(P);
    P.Weapon=W;
    W.SetHand(P.Handedness);
    W.BringUp();
    P.Settings.WeaponIndex=Index;
    P.Settings.SaveConfig();
}
function AddDefaultInventory(Pawn P)
{
    if (UTATPlayer(P) == None) return;
    UTATPlayer(P).EnsureSettings();
    if(AutoStart)
    {
        UTATPlayer(P).Settings.WeaponIndex=PendingWeapon;
        UTATPlayer(P).Settings.Exercise=PendingExercise;
        UTATPlayer(P).Settings.Duration=PendingSeconds;
    }
    GiveTrainingWeapon(UTATPlayer(P), UTATPlayer(P).Settings.WeaponIndex);
}
function bool RestartPlayer(Pawn P)
{
    local bool Result;
    if(Running) FinishSession(False);
    Result=Super.RestartPlayer(P);
    if(Result && UTATPlayer(P)!=None) PlaceTrainee(UTATPlayer(P));
    return Result;
}
function bool PlaceTrainee(UTATPlayer P)
{
    local int Attempt;
    local vector Pos;
    if(Room==None) return True;
    for(Attempt=0; Attempt<32; Attempt++)
    {
        Pos=class'UTATSpawnPlanner'.static.InBox(RandomSeed,Room.PlayerSpawnMin,Room.PlayerSpawnMax);
        if(VSize(Pos-P.Location)<160) continue;
        if(P.SetLocation(Pos))
        {
            P.SetRotation(rotator(Room.TargetOrigin-Pos));
            P.ViewRotation=P.Rotation;
            P.Velocity=vect(0,0,0); P.Acceleration=vect(0,0,0);
            return True;
        }
    }
    return False;
}
function bool PlaceTarget(UTATTarget T, bool Respawning)
{
    local int Attempt,I;
    local bool Clear;
    local vector Pos;
    if(Room==None) return False;
    for(Attempt=0; Attempt<64; Attempt++)
    {
        Pos=class'UTATSpawnPlanner'.static.InBox(RandomSeed,Room.TargetSpawnMin,Room.TargetSpawnMax);
        if(VSize(Pos-Trainee.Location)<700 || !FastTrace(Pos,Trainee.Location)) continue;
        if(Respawning && VSize(Pos-T.HomePosition)<180) continue;
        Clear=True;
        for(I=0; I<3; I++)
            if(Targets[I]!=None && Targets[I]!=T && VSize(Pos-Targets[I].HomePosition)<200) Clear=False;
        if(!Clear || !T.SetLocation(Pos)) continue;
        T.HomePosition=Pos; T.Health=100; T.bHidden=False;
        T.SetCollision(True,False,False);
        T.SetRotation(rotator(Trainee.Location-Pos));
        return True;
    }
    return False;
}
function StartSession(UTATPlayer P)
{
    local vector Z, Pos;
    local int I;
    if(Running || P==None) return;
    if(P.Health<=0)
    {
        LastSummary="Respawn first, then start a training round.";
        P.ClientMessage(LastSummary); return;
    }
    if(Room==None) { P.ClientMessage("Use DM-UTAT-Room for training."); return; }
    P.EnsureSettings();
    Trainee=P;
    GiveTrainingWeapon(P,P.Settings.WeaponIndex);
    if (P.Weapon==None) return;
    RoundSeed=Rand(65535)+1;
    RandomSeed=RoundSeed;
    if(!PlaceTrainee(P)) { P.ClientMessage("No safe player start available."); return; }
    Anchor=P.Location;
    AnchorRotation=P.ViewRotation;
    AnchorRotation.Pitch=0;
    AnchorRotation.Roll=0;
    GetAxes(AnchorRotation,ForwardAxis,SideAxis,Z);
    WeaponIndex=P.Settings.WeaponIndex;
    SessionFOV=P.DefaultFOV;
    Snapshot="profile="$P.Settings.ActiveProfile$"|sens="$P.MouseSensitivity
        $"|nosmooth="$P.bNoMouseSmoothing$"|maxsmooth="$P.bMaxMouseSmoothing
        $"|threshold="$P.MouseSmoothThreshold$"|fov="$SessionFOV;
    Shots=0; Hits=0; Eliminations=0; DamageDealt=0;
    RoundId++;
    ActiveShot=None;
    ExerciseMode=P.Settings.Exercise;
    SessionDuration=P.Settings.Duration;
    StartedAt=Level.TimeSeconds;
    RoundElapsed=0;
    HasResult=False; ResultsDismissed=False;
    Running=True;
    for (I=0; I<3; I++)
    {
        // Spawn hidden at the marker, then choose a collision-checked random location.
        Pos=Room.TargetOrigin;
        Targets[I]=Spawn(class'UTATTarget',,,Pos,rotator(-ForwardAxis));
        if(Targets[I]==None) { FinishSession(False); return; }
        Targets[I].Trainer=Self; Targets[I].Index=I;
        if(!PlaceTarget(Targets[I],False)) { FinishSession(False); P.ClientMessage("No safe target spawn."); return; }
    }
    P.Health=100;
    P.SetPause(False);
    P.ClientMessage("ROUND STARTED | duration "$SessionDuration$"s (0=free) | unlimited ammo");
    P.ClientMessage("AimFinish: result | AimRestart: repeat | AimMenu: controls");
}
function UTATShot NewShot()
{
    local UTATShot S;
    if (!Running || (SessionDuration>0 && RoundElapsed>=SessionDuration)) return None;
    S=new(None) class'UTATShot';
    S.Trainer=Self; S.RoundId=RoundId;
    Shots++;
    return S;
}
function bool AcceptDamage(UTATTarget T, int Damage)
{
    if (!Running || Damage<=0 || ActiveShot==None || ActiveShot.Trainer!=Self
        || ActiveShot.RoundId!=RoundId || (SessionDuration>0 && RoundElapsed>=SessionDuration)) return False;
    if (!ActiveShot.Hit)
    {
        ActiveShot.Hit=True;
        Hits++;
    }
    DamageDealt+=Min(Damage,T.Health);
    return True;
}
function UpdateRound(float Delta)
{
    local int I;
    local float Age;
    local vector Pos;
    if (!Running) return;
    if (Trainee==None || Trainee.Health<=0)
    {
        FinishSession(False); return;
    }
    Trainee.Health=100;
    RoundElapsed+=Delta/FMax(0.01,Level.TimeDilation);
    Age=RoundElapsed;
    if (SessionDuration>0 && Age>=SessionDuration)
    {
        FinishSession(True); return;
    }
    for (I=0; I<3; I++)
    {
        if (Targets[I]==None) { FinishSession(False); return; }
        if (Targets[I].bHidden && Level.TimeSeconds>=Targets[I].ReadyAt)
        {
            if(!PlaceTarget(Targets[I],True)) { FinishSession(False); return; }
        }
        Pos=Targets[I].HomePosition;
        if (ExerciseMode==1) Pos+=64*Sin(Age*2.0+I)*SideAxis;
        if (!Targets[I].SetLocation(Pos)) { FinishSession(False); return; }
    }
}
function float AccuracyPercent()
{
    if (Shots==0) return 0;
    return 100.0*Hits/Shots;
}
function FinishSession(bool Complete)
{
    local int I;
    local Projectile P;
    local string Record;
    if (!Running) return;
    Running=False;
    LastElapsed=FMax(0,RoundElapsed);
    if (SessionDuration>0) LastElapsed=FMin(SessionDuration,LastElapsed);
    if(Complete && SessionDuration>0 && LastElapsed<SessionDuration) Complete=False;
    LastComplete=Complete;
    HasResult=True; ResultsDismissed=False; ResultsAt=Level.TimeSeconds;
    ActiveShot=None;
    for (I=0; I<3; I++)
    {
        if (Targets[I]!=None) Targets[I].Destroy();
        Targets[I]=None;
    }
    foreach AllActors(class'Projectile',P)
        if (P.Instigator==Trainee) P.Destroy();
    Record="RESULT|version=2|complete="$Complete$"|exercise="$ExerciseMode
        $"|protocol=primary-units-v2|weapon="$WeaponLabel(WeaponIndex)$"|unit="$UnitLabel(WeaponIndex)
        $"|sequence=random-v1|seed="$RoundSeed$"|duration="$SessionDuration$"|elapsed="$LastElapsed$"|shots="$Shots$"|hits="$Hits
        $"|kills="$Eliminations$"|damage="$DamageDealt$"|mean_ms=0|map="$string(Level.Outer.Name)
        $"|anchor="$string(Anchor)$"|yaw="$AnchorRotation.Yaw$"|input=unverified|"$Snapshot;
    Log(Record,'UTAT');
    LastSummary="Accuracy "$int(AccuracyPercent())$"% | Hits "$Hits$" / "$Shots$" | Eliminations "$Eliminations;
    if (Trainee!=None)
    {
        Trainee.Settings.LastResult=Record;
        Trainee.Settings.SaveConfig();
        Trainee.ClientMessage(LastSummary);
        Trainee.PendingTrainingPanel=False;
        Trainee.bFire=0; Trainee.bAltFire=0;
        if(Trainee.Weapon!=None) Trainee.Weapon.GotoState('Idle');
        if(!SmokeTest) Trainee.ResumeTraining();
    }
}
defaultproperties
{
    GameName="UT99 Aimtrainer"
    DefaultPlayerClass=Class'UTAT.UTATPlayer'
    HUDType=Class'UTAT.UTATHUD'
    DefaultWeapon=Class'UTAT.UTATShock'
    MinPlayers=0
    FragLimit=0
    TimeLimit=0
    bRequireReady=False
    bUseTranslocator=False
    bNoMonsters=True
    MaxPlayers=1
}
