class UTATNetworkHUD extends ChallengeHUD;
simulated function PostRender(Canvas C)
{
    local UTATNetworkState S;
    local float Acc,X,Y;
    local string AccText,TimeText;
    local string PingText;
    Super.PostRender(C); S=class'UTATNetworkState'.static.Find(PlayerOwner);
    if(S==None) return;
    C.Reset(); C.Font=C.MedFont; C.DrawColor.R=255;C.DrawColor.G=213;C.DrawColor.B=74;
    C.SetPos(20,20);C.DrawText("UT99 AIMTRAINER / IGPLUS");
    C.DrawColor.R=240;C.DrawColor.G=245;C.DrawColor.B=255;
    PingText="waiting";if(PlayerOwner.PlayerReplicationInfo!=None) PingText=string(PlayerOwner.PlayerReplicationInfo.Ping)$" ms";
    C.SetPos(20,44);C.DrawText("Added RTT: "$S.RequestedRTT$" ms | Game ping: "$PingText);
    if(S.Shots>0) Acc=100.0*S.Hits/S.Shots;
    AccText=int(Acc)$"%";if(S.Shots==0 && S.BeamActive>0) AccText="see beam contact";
    TimeText=int(S.Elapsed)$" / "$S.Duration$"s";if(S.Duration==0) TimeText="FREE / "$int(S.Elapsed)$"s";
    C.SetPos(20,68);C.DrawText(class'UTATWeaponCatalog'.static.Label(S.WeaponIndex)$" | "$TimeText$" | Accuracy "$AccText);
    C.SetPos(20,92);C.DrawText("Units "$S.Hits$" / "$S.Shots$" | Eliminations "$S.Kills$" | Damage "$S.DamageDone);
    if(S.BeamActive>0)
    {
        C.SetPos(20,116);C.DrawText("Pulse beam contact: "$int(100*S.BeamContact/S.BeamActive)$"% (time)");
    }
    if(!S.ResultReady) return;
    X=FMax(20,(C.ClipX-540)/2);Y=C.ClipY*0.30;
    C.DrawColor.R=25;C.DrawColor.G=30;C.DrawColor.B=40;
    C.SetPos(X,Y);C.DrawTile(Texture'UTAT.TrainingWall',540,195,0,0,128,128);
    C.DrawColor.R=255;C.DrawColor.G=213;C.DrawColor.B=74;
    C.SetPos(X+16,Y+16);C.DrawText("ROUND RESULTS / IGPLUS");
    C.DrawColor.R=240;C.DrawColor.G=245;C.DrawColor.B=255;
    C.SetPos(X+16,Y+52);C.DrawText("Accuracy "$AccText$" | Units "$S.Hits$" / "$S.Shots);
    C.SetPos(X+16,Y+82);C.DrawText("Eliminations "$S.Kills$" | Time "$int(S.Elapsed)$"s");
    if(S.BeamActive>0) { C.SetPos(X+16,Y+112);C.DrawText("Beam contact "$int(100*S.BeamContact/S.BeamActive)$"% (time)"); }
    C.SetPos(X+16,Y+150);C.DrawText("Press primary FIRE to return to setup");
}
