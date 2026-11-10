class NPStarterBolt extends InstaGibPlus_11.ST_StarterBolt;
simulated function TraceBeam(vector Origin,vector X,float DeltaTime)
{
    local UTATRoundGame G;local UTATNetShot Previous,S;
    G=UTATRoundGame(Level.Game);
    if(G!=None && G.Running)
    {
        Previous=G.ActiveShot;S=new(None) class'UTATNetShot';S.RoundId=G.RoundId;S.Beam=True;G.ActiveShot=S;
        G.StateInfo.BeamActive+=DeltaTime;
    }
    Super.TraceBeam(Origin,X,DeltaTime);
    if(G!=None && G.Running)
    {
        if(UTATNetTarget(DamagedActor)!=None) G.StateInfo.BeamContact+=DeltaTime;
        G.ActiveShot=Previous;
    }
}
