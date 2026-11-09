class UTATGame extends DeathMatchPlus;
var UTATPlayer Trainee;
var UTATTarget Targets[3];
var UTATShot ActiveShot;
var UTATRoomInfo Room;
var bool Running, HasResult, LastComplete;
var int Shots, Hits, Eliminations, DamageDealt, RoundId, ExerciseMode, SessionDuration, WeaponIndex;
var float StartedAt, LastElapsed, SessionFOV;
var vector Anchor, ForwardAxis, SideAxis;
var rotator AnchorRotation;
var string Snapshot, LastSummary;
var bool SmokeTest;

function InitGame(string Options, out string Error)
{
    Super.InitGame(Options, Error);
    SmokeTest = HasOption(Options, "SmokeTest");
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
    Super.PostBeginPlay();
    foreach AllActors(class'Inventory', I)
        if (I.Owner == None) I.Destroy();
    foreach AllActors(class'UTATRoomInfo', Room) break;
    Spawn(class'UTATProjectileNotify');
    if (SmokeTest) Spawn(class'UTATSmokeTest');
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
    GiveTrainingWeapon(UTATPlayer(P), UTATPlayer(P).Settings.WeaponIndex);
}
function bool RestartPlayer(Pawn P)
{
    if (Running) FinishSession(False);
    return Super.RestartPlayer(P);
}
function StartSession(UTATPlayer P)
{
    local vector Z, Pos;
    local int I;
    if (Running || P == None || P.Health<=0) return;
    P.EnsureSettings();
    Trainee=P;
    GiveTrainingWeapon(P,P.Settings.WeaponIndex);
    if (P.Weapon==None) return;
    if (Room!=None)
    {
        if (!P.SetLocation(Room.Location))
        {
            P.ClientMessage("Start area blocked.");
            return;
        }
        P.SetRotation(Room.Rotation);
        P.ViewRotation=Room.Rotation;
        P.Velocity=vect(0,0,0);
    }
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
    HasResult=False;
    Running=True;
    for (I=0; I<3; I++)
    {
        Pos=Anchor+900*ForwardAxis+(I-1)*240*SideAxis;
        Targets[I]=Spawn(class'UTATTarget',,,Pos,rotator(-ForwardAxis));
        if (Targets[I]==None || !FastTrace(Pos,Anchor))
        {
            FinishSession(False);
            P.ClientMessage("Target area blocked. Use the included training room.");
            return;
        }
        Targets[I].Trainer=Self;
        Targets[I].HomePosition=Pos;
        Targets[I].Index=I;
    }
    P.Health=1999;
    P.ClientMessage("Training started. AimFinish ends and shows results; AimRestart repeats.");
}
function UTATShot NewShot()
{
    local UTATShot S;
    if (!Running || (SessionDuration>0 && Level.TimeSeconds-StartedAt>=SessionDuration)) return None;
    S=new(None) class'UTATShot';
    S.Trainer=Self; S.RoundId=RoundId;
    Shots++;
    return S;
}
function bool AcceptDamage(UTATTarget T, int Damage)
{
    if (!Running || Damage<=0 || ActiveShot==None || ActiveShot.Trainer!=Self
        || ActiveShot.RoundId!=RoundId || (SessionDuration>0 && Level.TimeSeconds-StartedAt>=SessionDuration)) return False;
    if (!ActiveShot.Hit)
    {
        ActiveShot.Hit=True;
        Hits++;
    }
    DamageDealt+=Min(Damage,T.Health);
    return True;
}
function Tick(float Delta)
{
    local int I;
    local float Age;
    local vector Pos;
    if (!Running) return;
    if (Trainee==None || Trainee.Health<=0)
    {
        FinishSession(False); return;
    }
    Trainee.Health=1999;
    if (Trainee.Weapon!=None && Trainee.Weapon.AmmoType!=None)
        Trainee.Weapon.AmmoType.AmmoAmount=Min(50,Trainee.Weapon.AmmoType.MaxAmmo);
    Age=Level.TimeSeconds-StartedAt;
    if (SessionDuration>0 && Age>=SessionDuration)
    {
        FinishSession(True); return;
    }
    for (I=0; I<3; I++)
    {
        if (Targets[I]==None) { FinishSession(False); return; }
        if (Targets[I].bHidden && Level.TimeSeconds>=Targets[I].ReadyAt)
        {
            Targets[I].Health=100;
            Targets[I].bHidden=False;
            Targets[I].SetCollision(True,False,False);
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
    LastElapsed=FMax(0,Level.TimeSeconds-StartedAt);
    if (SessionDuration>0) LastElapsed=FMin(SessionDuration,LastElapsed);
    if(Complete && SessionDuration>0 && LastElapsed<SessionDuration) Complete=False;
    LastComplete=Complete;
    HasResult=True;
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
        $"|sequence=1|duration="$SessionDuration$"|elapsed="$LastElapsed$"|shots="$Shots$"|hits="$Hits
        $"|kills="$Eliminations$"|damage="$DamageDealt$"|mean_ms=0|map="$string(Level.Outer.Name)
        $"|anchor="$string(Anchor)$"|yaw="$AnchorRotation.Yaw$"|input=unverified|"$Snapshot;
    Log(Record,'UTAT');
    LastSummary="Accuracy "$int(AccuracyPercent())$"% | Hits "$Hits$" / "$Shots$" | Eliminations "$Eliminations;
    if (Trainee!=None)
    {
        Trainee.Settings.LastResult=Record;
        Trainee.Settings.SaveConfig();
        Trainee.ClientMessage(LastSummary);
        if (!SmokeTest) Trainee.ShowTrainingPanel();
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
