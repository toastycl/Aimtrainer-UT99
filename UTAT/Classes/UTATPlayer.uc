class UTATPlayer extends TMale2;

var UTATStore Settings;
var bool PendingTrainingPanel;
var float OriginalSensitivity, OriginalThreshold;
var bool OriginalNoSmoothing, OriginalMaxSmoothing, HasOriginal;

function EnsureSettings()
{
    if (Settings != None)
        return;
    Settings = new(None) class'UTATStore';
    Settings.ActiveProfile = Clamp(Settings.ActiveProfile, 0, 2);
    Settings.Exercise = Clamp(Settings.Exercise, 0, 3);
    Settings.TargetDistance=Clamp(Settings.TargetDistance,0,3);
    Settings.TargetSize=Clamp(Settings.TargetSize,0,2);
    Settings.HistoryCount=Clamp(Settings.HistoryCount,0,10);
    Settings.Duration = Clamp(Settings.Duration, 0, 300);
    Settings.WeaponIndex = Clamp(Settings.WeaponIndex, 0, 10);
    OriginalSensitivity = MouseSensitivity;
    OriginalNoSmoothing = bNoMouseSmoothing;
    OriginalMaxSmoothing = bMaxMouseSmoothing;
    OriginalThreshold = MouseSmoothThreshold;
    HasOriginal = True;
    if (!Settings.Profiles[0].Saved)
        SaveProfile(0);
}

function bool CanConfigure()
{
    local UTATGame G;
    G = UTATGame(Level.Game);
    if (G == None || Level.NetMode != NM_Standalone)
        return False;
    if (G.Running)
    {
        ClientMessage("Stop the session before changing configuration.");
        return False;
    }
    return True;
}

function SaveProfile(int Slot)
{
    if (Settings == None || Slot < 0 || Slot > 2)
        return;
    Settings.Profiles[Slot].Saved = True;
    Settings.Profiles[Slot].Sensitivity = MouseSensitivity;
    Settings.Profiles[Slot].NoSmoothing = bNoMouseSmoothing;
    Settings.Profiles[Slot].MaxSmoothing = bMaxMouseSmoothing;
    Settings.Profiles[Slot].SmoothThreshold = MouseSmoothThreshold;
    Settings.ActiveProfile = Slot;
    Settings.SaveConfig();
}

exec function AimSave(int Slot)
{
    EnsureSettings();
    if (CanConfigure() && Slot >= 0 && Slot <= 2)
    {
        SaveProfile(Slot);
        ClientMessage("Saved profile "$Slot$". Original User.ini is not overwritten.");
    }
}

exec function AimProfile(int Slot)
{
    EnsureSettings();
    if (!CanConfigure() || Slot < 0 || Slot > 2)
        return;
    if (!Settings.Profiles[Slot].Saved)
    {
        ClientMessage("Empty slot. Use AimSave "$Slot$" first.");
        return;
    }
    UpdateSensitivity(Settings.Profiles[Slot].Sensitivity);
    bNoMouseSmoothing = Settings.Profiles[Slot].NoSmoothing;
    bMaxMouseSmoothing = Settings.Profiles[Slot].MaxSmoothing;
    MouseSmoothThreshold = Settings.Profiles[Slot].SmoothThreshold;
    Settings.ActiveProfile = Slot;
    Settings.SaveConfig();
    ClientMessage("Applied profile "$Slot$" for this training visit.");
}

exec function AimSensitivity(float Value)
{
    EnsureSettings();
    if (CanConfigure() && Value >= 0.01 && Value <= 100)
        UpdateSensitivity(Value);
}

exec function AimSmoothing()
{
    EnsureSettings();
    if (CanConfigure())
    {
        bNoMouseSmoothing = !bNoMouseSmoothing;
        bMaxMouseSmoothing = False;
    }
}

exec function AimExercise(int Mode)
{
    EnsureSettings();
    if (CanConfigure() && Mode >= 0 && Mode <= 3)
    {
        Settings.Exercise = Mode;
        Settings.SaveConfig();
    }
}

exec function AimDistance(int Mode)
{
    EnsureSettings();
    if(CanConfigure() && Mode>=0 && Mode<=3) {Settings.TargetDistance=Mode;Settings.SaveConfig();}
}
exec function AimSize(int Mode)
{
    EnsureSettings();
    if(CanConfigure() && Mode>=0 && Mode<=2) {Settings.TargetSize=Mode;Settings.SaveConfig();}
}
exec function AimDuration(int Seconds)
{
    EnsureSettings();
    if (CanConfigure() && (Seconds == 0 || Seconds >= 10) && Seconds <= 300)
    {
        Settings.Duration = Seconds;
        Settings.SaveConfig();
    }
}

// The first fresh shot after a result acknowledges it; it never reaches the weapon.
exec function Fire(optional float F)
{
    local UTATGame G;
    G=UTATGame(Level.Game);
    if(G!=None && G.HasResult && !G.Running)
    {
        bFire=0;
        if(Level.TimeSeconds-G.ResultsAt>=0.25)
        {
            G.ResultsDismissed=True;
            ShowTrainingPanel();
        }
        return;
    }
    if(G!=None && G.Running) G.FireMask=G.FireMask | 1;
    Super.Fire(F);
}
exec function AltFire(optional float F)
{
    if(UTATGame(Level.Game)!=None && UTATGame(Level.Game).HasResult && !UTATGame(Level.Game).Running)
    {
        bAltFire=0; return;
    }
    if(UTATGame(Level.Game)!=None && UTATGame(Level.Game).Running)
        UTATGame(Level.Game).FireMask=UTATGame(Level.Game).FireMask | 2;
    Super.AltFire(F);
}
exec function AimMenu()
{
    ShowTrainingPanel();
}
function ShowTrainingPanel()
{
    local WindowConsole WC;
    if (Player == None) return;
    WC=WindowConsole(Player.Console);
    if(WC==None) return;
    WC.LaunchUWindow();
    if(WC.Root==None) { PendingTrainingPanel=True; return; }
    PendingTrainingPanel=False;
    WC.Root.CreateWindow(class'UTATWindow',40,40,440,420,,True);
}
function ResumeTraining()
{
    local WindowConsole WC;
    if(Player!=None)
    {
        WC=WindowConsole(Player.Console);
        if(WC!=None) WC.CloseUWindow();
    }
    SetPause(False);
}
// No other pawn can telefrag the trainee in this local practice lab.
event EncroachedBy(Actor Other)
{
    if(UTATGame(Level.Game)==None) Super.EncroachedBy(Other);
}
exec function AimWeapon(int Index)
{
    EnsureSettings();
    if(CanConfigure() && Index>=0 && Index<=10)
        UTATGame(Level.Game).GiveTrainingWeapon(Self,Index);
}
exec function AimFinish()
{
    if(UTATGame(Level.Game)!=None)
        UTATGame(Level.Game).FinishSession(True);
}
exec function AimRestart()
{
    AimStop();
    AimStart();
}

exec function AimStart()
{
    EnsureSettings();
    if (UTATGame(Level.Game) != None)
        UTATGame(Level.Game).StartSession(Self);
}

exec function AimStop()
{
    if (UTATGame(Level.Game) != None)
        UTATGame(Level.Game).FinishSession(False);
}

exec function AimRestore()
{
    if (CanConfigure())
        RestoreOriginal();
}

function RestoreOriginal()
{
    if (!HasOriginal)
        return;
    UpdateSensitivity(OriginalSensitivity);
    bNoMouseSmoothing = OriginalNoSmoothing;
    bMaxMouseSmoothing = OriginalMaxSmoothing;
    MouseSmoothThreshold = OriginalThreshold;
}

exec function AimInput()
{
    // Inspection only. A backend switch/restart workflow is a later milestone.
    ClientMessage("Input backend is not controlled or verified by this version.");
    ClientMessage("Inspect Options > Preferences > Input and record it with your results.");
}

exec function AimHelp()
{
    ClientMessage("Mods > UT99 Aimtrainer opens the training panel.");
    ClientMessage("AimSave 0..2 | AimProfile 0..2 | AimSensitivity 1.8 | AimSmoothing");
    ClientMessage("AimWeapon 0..10 | AimExercise 0=static,1=strafe,2=evasive,3=aerial | AimDuration 0=free or 60");
    ClientMessage("AimDistance 0=mixed,1=close,2=medium,3=far | AimSize 0=normal,1=small,2=large");
    ClientMessage("AimStart | AimFinish | AimRestart | AimStop | AimMenu");
}

event PreClientTravel()
{
    if (UTATGame(Level.Game) != None)
        UTATGame(Level.Game).FinishSession(False);
    RestoreOriginal();
    Super.PreClientTravel();
}

function Destroyed()
{
    RestoreOriginal();
    Super.Destroyed();
}

defaultproperties
{
    bAutoActivate=False
}
