class UTATGame extends DeathMatchPlus;

var UTATPlayer Trainee;
var UTATTarget TrainingTarget;
var bool Running, WaitingTarget;
var int Shots, Hits, TargetIndex, ExerciseMode, SessionDuration;
var float StartedAt, ExposedAt, NextTargetAt, HitTimeSum, SessionFOV;
var vector Anchor, ForwardAxis, SideAxis, TargetCenter;
var rotator AnchorRotation;
var string Snapshot, LastSummary;

// Explicitly force our player so inherited client preferences cannot bypass commands.
event PlayerPawn Login(string Portal, string Options, out string Error,
                       class<PlayerPawn> SpawnClass)
{
    if (Level.NetMode != NM_Standalone)
    {
        Error = "UTAT alpha is local-only. Online support is not implemented.";
        return None;
    }
    return Super.Login(Portal, Options, Error, class'UTATPlayer');
}

function PostBeginPlay()
{
    local Inventory I;
    Super.PostBeginPlay();
    // Keep existing maps usable as labs without map pickups changing the loadout.
    foreach AllActors(class'Inventory', I)
        if (I.Owner == None)
            I.Destroy();
}

function AddDefaultInventory(Pawn P)
{
    local UTATShock W;
    W = Spawn(class'UTATShock');
    if (W == None)
        return;
    W.GiveTo(P);
    W.GiveAmmo(P);
    W.SetSwitchPriority(P);
    W.WeaponSet(P);
    P.Weapon = W;
    W.SetHand(PlayerPawn(P).Handedness);
}

function bool RestartPlayer(Pawn P)
{
    if (Running)
        FinishSession(False);
    return Super.RestartPlayer(P);
}

function string CurrentSnapshot(UTATPlayer P)
{
    return "profile="$P.Settings.ActiveProfile$"|sens="$P.MouseSensitivity
        $"|nosmooth="$P.bNoMouseSmoothing$"|maxsmooth="$P.bMaxMouseSmoothing
        $"|threshold="$P.MouseSmoothThreshold$"|fov="$SessionFOV;
}

function StartSession(UTATPlayer P)
{
    local vector Z;
    if (Level.NetMode != NM_Standalone || Running || P.Health <= 0)
        return;
    P.EnsureSettings();
    Trainee = P;
    if (UTATShock(P.Weapon) == None)
    {
        P.ClientMessage("Select the training Shock Rifle first.");
        return;
    }
    Anchor = P.Location;
    AnchorRotation = P.ViewRotation;
    AnchorRotation.Pitch = 0;
    AnchorRotation.Roll = 0;
    GetAxes(AnchorRotation, ForwardAxis, SideAxis, Z);
    TargetCenter = Anchor + 700 * ForwardAxis;
    TargetIndex = 0;
    Shots = 0;
    Hits = 0;
    HitTimeSum = 0;
    ExerciseMode = P.Settings.Exercise;
    SessionDuration = P.Settings.Duration;
    SessionFOV = P.FOVAngle;
    Snapshot = CurrentSnapshot(P);
    StartedAt = Level.TimeSeconds;
    Running = True;
    if (!PlaceTarget())
    {
        FinishSession(False);
        P.ClientMessage("No clear target lane. Move to an open area and face it, then AimStart.");
        return;
    }
    Log("START|version=1|"$Snapshot, 'UTAT');
    P.ClientMessage("Session started. Use AimStop to cancel. Keep input and FOV unchanged.");
}

function vector CandidateLocation()
{
    local float Offset;
    // Fixed order independent of the engine's global random state.
    switch (TargetIndex % 5)
    {
        case 0: Offset = 0; break;
        case 1: Offset = -160; break;
        case 2: Offset = 160; break;
        case 3: Offset = -80; break;
        case 4: Offset = 80; break;
    }
    if (ExerciseMode == 1)
        Offset = 0;
    return TargetCenter + Offset * SideAxis;
}

function bool PlaceTarget()
{
    local vector Pos, HitLoc, HitNormal;
    local Actor Obstruction;
    Pos = CandidateLocation();
    // Reject a lane obstructed by world geometry or another actor.
    Obstruction = Trace(HitLoc, HitNormal, Pos, Anchor, False, vect(20,20,40));
    if (Obstruction != None)
        return False;
    if (TrainingTarget == None)
    {
        TrainingTarget = Spawn(class'UTATTarget',,, Pos, rotator(-ForwardAxis));
        if (TrainingTarget == None)
            return False;
        TrainingTarget.Trainer = Self;
    }
    else if (!TrainingTarget.SetLocation(Pos))
        return False;
    TrainingTarget.bHidden = False;
    TrainingTarget.SetCollision(True, False, False);
    TrainingTarget.AcceptHits = True;
    WaitingTarget = False;
    ExposedAt = Level.TimeSeconds;
    return True;
}

function RegisterShot()
{
    if (Running && Level.TimeSeconds - StartedAt < SessionDuration)
        Shots++;
}

function RegisterHit(UTATTarget T)
{
    if (!Running || WaitingTarget || T != TrainingTarget
        || Level.TimeSeconds - StartedAt >= SessionDuration)
        return;
    Hits++;
    HitTimeSum += Level.TimeSeconds - ExposedAt;
    T.AcceptHits = False;
    T.bHidden = True;
    T.SetCollision(False, False, False);
    WaitingTarget = True;
    NextTargetAt = Level.TimeSeconds + 0.25;
    TargetIndex++;
}

function Tick(float Delta)
{
    local vector Pos;
    local float Age;
    if (!Running)
        return;
    if (Trainee == None || Trainee.Health <= 0)
    {
        FinishSession(False);
        return;
    }
    // Config changes through the stock menu/console also invalidate the run.
    if (Trainee.FOVAngle != SessionFOV || Snapshot != CurrentSnapshot(Trainee))
    {
        Trainee.ClientMessage("Configuration changed. Session cancelled.");
        FinishSession(False);
        return;
    }
    if (UTATShock(Trainee.Weapon) != None && Trainee.Weapon.AmmoType != None)
        Trainee.Weapon.AmmoType.AmmoAmount = 50;
    Age = Level.TimeSeconds - StartedAt;
    if (Age >= SessionDuration)
    {
        FinishSession(True);
        return;
    }
    if (TrainingTarget == None)
    {
        FinishSession(False);
        return;
    }
    if (WaitingTarget)
    {
        if (Level.TimeSeconds >= NextTargetAt && !PlaceTarget())
        {
            Trainee.ClientMessage("TrainingTarget lane blocked. Session cancelled.");
            FinishSession(False);
        }
    }
    else if (ExerciseMode == 1)
    {
        Pos = TargetCenter + 160 * Sin(Age * 2.0) * SideAxis;
        if (!TrainingTarget.SetLocation(Pos))
            FinishSession(False);
    }
}

function float AccuracyPercent()
{
    if (Shots == 0)
        return 0;
    return 100.0 * Hits / Shots;
}

function FinishSession(bool Complete)
{
    local float Elapsed, MeanMS;
    local string ResultLine;
    if (!Running)
        return;
    Running = False;
    Elapsed = FMin(SessionDuration, FMax(0, Level.TimeSeconds - StartedAt));
    if (TrainingTarget != None)
        TrainingTarget.Destroy();
    TrainingTarget = None;
    WaitingTarget = False;
    if (Hits > 0)
        MeanMS = 1000.0 * HitTimeSum / Hits;
    ResultLine = "RESULT|version=1|complete="$Complete$"|exercise="$ExerciseMode
        $"|protocol=shock-primary-v1|sequence=1|duration="$SessionDuration
        $"|elapsed="$Elapsed$"|shots="$Shots$"|hits="$Hits$"|mean_ms="$MeanMS
        $"|map="$string(Level.Outer.Name)$"|anchor="$string(Anchor)
        $"|yaw="$AnchorRotation.Yaw$"|input=unverified|"$Snapshot;
    Log(ResultLine, 'UTAT');
    LastSummary = "Hits "$Hits$" / "$Shots$"  |  Accuracy "$int(AccuracyPercent())$"%";
    if (Trainee != None)
    {
        Trainee.Settings.LastResult = ResultLine;
        Trainee.Settings.SaveConfig();
        Trainee.ClientMessage(LastSummary);
        if (!Complete)
            Trainee.ClientMessage("Cancelled session: excluded from comparisons.");
    }
}

defaultproperties
{
    GameName="UT99 Aimtrainer (CTF Lab)"
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
