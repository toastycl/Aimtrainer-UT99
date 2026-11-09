class UTATHUD extends ChallengeHUD;
simulated function PostRender(Canvas C)
{
    local UTATPlayer P;
    local UTATGame G;
    local string TimeText;
    Super.PostRender(C);
    P=UTATPlayer(PlayerOwner);
    if(P==None) return;
    G=UTATGame(P.Level.Game);
    if(G==None) return;
    C.Reset(); C.Font=C.MedFont;
    C.DrawColor.R=255; C.DrawColor.G=213; C.DrawColor.B=74;
    C.SetPos(20,20); C.DrawText("UT99 AIMTRAINER / PRACTICE ROOM");
    C.DrawColor.R=235; C.DrawColor.G=242; C.DrawColor.B=255;
    C.SetPos(20,42);
    if(!G.Running)
    {
        C.DrawText("Mods > UT99 Aimtrainer or console: AimMenu");
        C.SetPos(20,64); C.DrawText(G.LastSummary); return;
    }
    TimeText="FREE PRACTICE";
    if(G.SessionDuration>0) TimeText=string(int(FMax(0,G.SessionDuration-(Level.TimeSeconds-G.StartedAt))))$"s left";
    C.DrawText(class'UTATGame'.static.WeaponLabel(G.WeaponIndex)$" | "$TimeText);
    C.SetPos(20,64); C.DrawText("Accuracy "$int(G.AccuracyPercent())$"% | Hits "$G.Hits$" / "$G.Shots$" | Eliminations "$G.Eliminations);
    C.SetPos(20,86); C.DrawText("Units: "$class'UTATGame'.static.UnitLabel(G.WeaponIndex)$" | AimFinish: score | AimRestart: repeat");
}
