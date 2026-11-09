class UTATHUD extends ChallengeHUD;

simulated function PostRender(Canvas C)
{
    local UTATGame G;
    local UTATPlayer P;
    local float Y;
    Super.PostRender(C);
    P = UTATPlayer(PlayerOwner);
    if (P == None)
        return;
    G = UTATGame(P.Level.Game);
    if (G == None)
        return;
    P.EnsureSettings();
    C.Reset();
    C.Font = C.MedFont;
    C.DrawColor.R = 255;
    C.DrawColor.G = 213;
    C.DrawColor.B = 74;
    C.SetPos(24, 24);
    C.DrawText("UT99 AIMTRAINER / CTF - ALPHA");
    C.DrawColor.R = 235;
    C.DrawColor.G = 242;
    C.DrawColor.B = 255;
    Y = 48;
    C.SetPos(24, Y);
    C.DrawText("Sens "$P.MouseSensitivity$" | Smoothing OFF: "$P.bNoMouseSmoothing);
    C.SetPos(24, Y+20);
    if (G.Running)
    {
        C.DrawText("Time "$int(FMax(0, G.SessionDuration-(Level.TimeSeconds-G.StartedAt)))
            $" | Hits "$G.Hits$" / "$G.Shots$" | Accuracy "$int(G.AccuracyPercent())$"%");
        C.SetPos(24, Y+40);
        C.DrawText("Shock primary | AimStop cancels | Input backend unverified");
    }
    else
    {
        C.DrawText("Mods > UT99 Aimtrainer | console: AimHelp");
        C.SetPos(24, Y+40);
        C.DrawText(G.LastSummary);
    }
}
