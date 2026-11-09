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
    Settings.Duration = Clamp(Settings.Duration, 10, 300);
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
    if (CanConfigure() && Seconds >= 10 && Seconds <= 300)
    {
        Settings.Duration = Seconds;
        Settings.SaveConfig();
    }
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
    ClientMessage("AimExercise 0=flick, 1=strafe | AimDuration 60 | AimStart | AimStop | AimRestore");
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
