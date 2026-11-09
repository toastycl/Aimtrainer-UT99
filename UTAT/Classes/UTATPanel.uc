class UTATPanel extends UWindowDialogClientWindow;
var UWindowSmallButton ProfileButton, ApplyButton, SaveButton, LessButton, MoreButton;
var UWindowSmallButton SmoothButton, ExerciseButton, DurationButton, StartButton, StopButton, RestoreButton;
var UTATPlayer P;
var int Slot;

function UWindowSmallButton AddButton(float X, float Y, float W, string Caption)
{
    local UWindowSmallButton B;
    B = UWindowSmallButton(CreateControl(class'UWindowSmallButton', X, Y, W, 22));
    B.SetText(Caption);
    return B;
}
function Created()
{
    Super.Created();
    ProfileButton = AddButton(16, 72, 116, "Slot 0 / A >");
    ApplyButton = AddButton(144, 72, 116, "Apply slot");
    SaveButton = AddButton(272, 72, 120, "Save to slot");
    LessButton = AddButton(16, 108, 182, "Sensitivity - 0.10");
    MoreButton = AddButton(210, 108, 182, "Sensitivity + 0.10");
    SmoothButton = AddButton(16, 144, 376, "Toggle mouse smoothing");
    ExerciseButton = AddButton(16, 180, 182, "Toggle Flick / Strafe");
    DurationButton = AddButton(210, 180, 182, "Cycle 30 / 60 / 120 s");
    StartButton = AddButton(16, 216, 182, "Start session");
    StopButton = AddButton(210, 216, 182, "Cancel session");
    RestoreButton = AddButton(16, 252, 376, "Restore original mouse settings");
}
function Paint(Canvas C, float X, float Y)
{
    Super.Paint(C, X, Y);
    P = UTATPlayer(GetPlayerOwner());
    C.Font = Root.Fonts[F_Normal];
    C.DrawColor.R=20; C.DrawColor.G=20; C.DrawColor.B=20;
    ClipText(C, 16, 10, "CTF weapons lab / Shock primary alpha");
    if (P == None)
    {
        ClipText(C, 16, 30, "Start a local UTATGame first (see README).");
        return;
    }
    P.EnsureSettings();
    ClipText(C, 16, 30, "Sens "$P.MouseSensitivity$" | Smooth OFF: "$P.bNoMouseSmoothing);
    ClipText(C, 16, 48, "Exercise "$P.Settings.Exercise$" | "$P.Settings.Duration$"s | Input: unverified");
    ClipText(C, 16, 290, "Select slot > apply saved / save current settings.");
}
function Notify(UWindowDialogControl C, byte E)
{
    Super.Notify(C, E);
    if (E != DE_Click)
        return;
    P = UTATPlayer(GetPlayerOwner());
    if (P == None)
        return;
    P.EnsureSettings();
    if (C == ProfileButton)
    {
        Slot = (Slot+1) % 3;
        ProfileButton.SetText("Slot "$Slot$" >");
    }
    else if (C == ApplyButton) P.AimProfile(Slot);
    else if (C == SaveButton) P.AimSave(Slot);
    else if (C == LessButton) P.AimSensitivity(FMax(0.01,P.MouseSensitivity-0.1));
    else if (C == MoreButton) P.AimSensitivity(P.MouseSensitivity+0.1);
    else if (C == SmoothButton) P.AimSmoothing();
    else if (C == ExerciseButton) P.AimExercise(1-P.Settings.Exercise);
    else if (C == DurationButton)
    {
        if (P.Settings.Duration == 30) P.AimDuration(60);
        else if (P.Settings.Duration == 60) P.AimDuration(120);
        else P.AimDuration(30);
    }
    else if (C == StartButton)
    {
        P.AimStart();
        Root.Console.CloseUWindow();
    }
    else if (C == StopButton) P.AimStop();
    else if (C == RestoreButton) P.AimRestore();
}
