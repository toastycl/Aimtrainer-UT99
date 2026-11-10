// Package-independent client view; the actual IGPlus player class stays intact.
class UTATNetworkState extends ReplicationInfo;
var bool RoundRunning, ResultReady;
var int Shots, Hits, Kills, DamageDone, RequestedRTT, Duration, WeaponIndex, Exercise;
var float Elapsed, MeanRTT, BeamActive, BeamContact;
var float ResultAge;
var bool SawResult;
replication
{
    reliable if(Role==ROLE_Authority) RoundRunning,ResultReady,Shots,Hits,Kills,DamageDone,RequestedRTT,Duration,WeaponIndex,Exercise,Elapsed,BeamActive,BeamContact;
}
simulated static function UTATNetworkState Find(Actor A)
{
    local UTATNetworkState S;
    if(A==None) return None;
    foreach A.AllActors(class'UTATNetworkState',S) if(S.Owner==A || S.Owner==A.Owner) return S;
    return None;
}
simulated function Tick(float Delta)
{
    local PlayerPawn P;
    if(Level.NetMode!=NM_Client) return;
    P=PlayerPawn(Owner);
    if(ResultReady)
    {
        if(!SawResult && P!=None)
        {
            P.bFire=0; P.bAltFire=0;
            if(P.Weapon!=None) P.Weapon.GotoState('Idle');
            SawResult=True;
        }
        ResultAge+=Delta/FMax(0.01,Level.TimeDilation);
    }
}
simulated function Acknowledge()
{
    local PlayerPawn P;
    if(!ResultReady || ResultAge<0.25) return;
    P=PlayerPawn(Owner);
    if(P!=None)
    {
        P.bFire=0; P.bAltFire=0;
        P.ClientTravel("DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?OpenSetup=1",TRAVEL_Absolute,False);
    }
}
simulated function RequestFinish() {}
simulated function RequestCancel() {}
simulated function RequestMenu(bool Open) {}
simulated static function bool CanFire(Weapon W,bool Primary)
{
    local UTATNetworkState S;
    S=Find(W);
    if(S==None) return True;
    if(S.ResultReady)
    {
        if(Primary && W.Level.NetMode==NM_Client) S.Acknowledge();
        return False;
    }
    return S.RoundRunning;
}
defaultproperties
{
    bAlwaysTick=True
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    NetPriority=3
}
