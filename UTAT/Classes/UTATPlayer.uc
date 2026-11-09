class UTATPlayer extends TMale2;

var UTATStore Settings;
var float OriginalSensitivity, OriginalThreshold;
var bool OriginalNoSmoothing, OriginalMaxSmoothing, HasOriginal;

function EnsureSettings()
{
    if (Settings != None)
        return;
    Settings = new(None) class'UTATStore';
    Settings.ActiveProfile = Clamp(Settings.ActiveProfile, 0, 2);
    Settings.Exercise = Clamp(Settings.Exercise, 0, 1);
    Settings.Duration = Clamp(Settings.Duration, 0, 300);
    Settings.WeaponIndex = Clamp(Settings.WeaponIndex, 0, 5);
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
    if (CanConfigure() && Mode >= 0 && Mode <= 1)
    {
        Settings.Exercise = Mode;
        Settings.SaveConfig();
    }
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

exec function AimMenu()
{
    ShowTrainingPanel();
}
function ShowTrainingPanel()
{
    local WindowConsole WC;
    if (Player == None) return;
    WC=WindowConsole(Player.Console);
    if(WC==None || WC.Root==None) return;
    WC.LaunchUWindow();
    WC.Root.CreateWindow(class'UTATWindow',40,40,440,420);
}
exec function AimWeapon(int Index)
{
    EnsureSettings();
    if(CanConfigure() && Index>=0 && Index<=5)
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
    ClientMessage("Input backend is not controlled or verified by this alpha.");
    ClientMessage("Inspect Options > Preferences > Input and record it with your results.");
}

exec function AimHelp()
{
    ClientMessage("Mods > UT99 Aimtrainer opens the training panel.");
    ClientMessage("AimSave 0..2 | AimProfile 0..2 | AimSensitivity 1.8 | AimSmoothing");
    ClientMessage("AimWeapon 0..5 | AimExercise 0=static,1=strafe | AimDuration 0=free or 60");
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
