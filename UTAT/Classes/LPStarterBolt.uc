class LPStarterBolt extends Botpack.StarterBolt;
simulated function Tick(float Delta)
{
    local UTATGame G;local UTATShot Previous,S;local PBolt B;local bool Contact;
    G=UTATGame(Level.Game);
    if(G!=None && G.Running)
    {
        Previous=G.ActiveShot;S=new(None) class'UTATShot';S.Trainer=G;S.RoundId=G.RoundId;S.Beam=True;G.ActiveShot=S;
        G.BeamActive+=Delta;
    }
    Super.Tick(Delta);
    if(G!=None && G.Running)
    {
        foreach AllActors(class'PBolt',B) if(B.Instigator==Instigator && UTATTarget(B.DamagedActor)!=None) Contact=True;
        if(Contact) G.BeamContact+=Delta;
        G.ActiveShot=Previous;
    }
}
