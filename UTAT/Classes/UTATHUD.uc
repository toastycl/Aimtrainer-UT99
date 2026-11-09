class UTATHUD extends ChallengeHUD;
simulated function PostRender(Canvas C)
{
    local UTATPlayer P;
    local UTATGame G;
    local string TimeText,AccuracyText;
    local float BoxX, BoxY, BoxW;
    Super.PostRender(C);
    P=UTATPlayer(PlayerOwner);
    if(P==None) return;
    G=UTATGame(P.Level.Game);
    if(G==None) return;
    AccuracyText=int(G.AccuracyPercent())$"%";if(G.Shots==0 && G.BeamActive>0) AccuracyText="see beam contact";
    C.Reset(); C.Font=C.MedFont;
    C.DrawColor.R=255; C.DrawColor.G=213; C.DrawColor.B=74;
    C.SetPos(20,20); C.DrawText("UT99 AIMTRAINER / PRACTICE ROOM");
    C.DrawColor.R=235; C.DrawColor.G=242; C.DrawColor.B=255;
    C.SetPos(20,42);
    if(!G.Running)
    {
        C.DrawText("Mods > UT99 Aimtrainer or console: AimMenu");
        C.SetPos(20,64); C.DrawText(G.LastSummary);
        if(G.HasResult && !G.ResultsDismissed)
        {
            BoxW=FMin(540,C.ClipX-40); BoxX=(C.ClipX-BoxW)/2; BoxY=C.ClipY*0.30;
            C.DrawColor.R=30; C.DrawColor.G=35; C.DrawColor.B=45;
            C.SetPos(BoxX,BoxY); C.DrawTile(Texture'UTAT.TrainingWall',BoxW,210,0,0,128,128);
            C.DrawColor.R=255; C.DrawColor.G=213; C.DrawColor.B=74;
            C.Font=C.LargeFont; C.SetPos(BoxX+18,BoxY+14); C.DrawText("ROUND RESULTS");
            C.Font=C.MedFont; C.DrawColor.R=240; C.DrawColor.G=245; C.DrawColor.B=255;
            C.SetPos(BoxX+18,BoxY+52); C.DrawText("Accuracy: "$AccuracyText);
            C.SetPos(BoxX+18,BoxY+78); C.DrawText("Hits / emitted units: "$G.Hits$" / "$G.Shots);
            C.SetPos(BoxX+18,BoxY+104); C.DrawText("Eliminations: "$G.Eliminations$" | Time: "$int(G.LastElapsed)$"s");
            C.SetPos(BoxX+18,BoxY+130); C.DrawText("Unit: "$class'UTATGame'.static.UnitLabel(G.WeaponIndex));
            if(G.BeamActive>0) {C.SetPos(BoxX+18,BoxY+148);C.DrawText("Beam contact "$int(100*G.BeamContact/G.BeamActive)$"% (time)");}
            C.SetPos(BoxX+18,BoxY+164); C.DrawText("Press FIRE to choose your next weapon / exercise");
        }
        return;
    }
    TimeText="FREE PRACTICE";
    if(G.SessionDuration>0) TimeText=string(int(FMax(0,G.SessionDuration-G.RoundElapsed)))$"s left";
    C.DrawText(class'UTATGame'.static.WeaponLabel(G.WeaponIndex)$" | "$TimeText);
    C.SetPos(20,64); C.DrawText("Accuracy "$AccuracyText$" | Hits "$G.Hits$" / "$G.Shots$" | Eliminations "$G.Eliminations);
    if(G.BeamActive>0) {C.SetPos(20,110);C.DrawText("Beam contact "$int(100*G.BeamContact/G.BeamActive)$"% (time)");}
    C.SetPos(20,86); C.DrawText("Units: "$class'UTATGame'.static.UnitLabel(G.WeaponIndex)$" | AimFinish: score | AimRestart: repeat");
}
