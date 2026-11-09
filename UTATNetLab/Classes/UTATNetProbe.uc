// Owner-only round-trip measurement and actual client-side weapon firing.
class UTATNetProbe extends ReplicationInfo;
var UTATNetTarget NetTarget;
var int Samples, Stage;
var float TotalRTT, Started;
replication
{
    reliable if(Role==ROLE_Authority) NetTarget, ClientEcho, ClientReport;
    reliable if(Role<ROLE_Authority) ServerEcho, ServerReport;
}
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    Log("NETLAB probe begin mode="$Level.NetMode$" role="$Role);
    if(Level.NetMode==NM_Client) SetTimer(0.5,True);
}
function ServerEcho(float Sent) { ClientEcho(Sent); }
simulated function ClientEcho(float Sent)
{
    local float RTT;
    RTT=1000*(Level.TimeSeconds-Sent)/FMax(0.01,Level.TimeDilation);
    Samples++; TotalRTT+=RTT;
    Log("NETLAB RTT_ms="$RTT$" sample="$Samples);
}
function ServerReport()
{
    ClientReport(NetTarget.ConfirmedHits,string(Owner.Class),string(Pawn(Owner).Weapon.Class));
}
simulated function ClientReport(int Hits,string PlayerClass,string WeaponClass)
{
    Log("NETLAB RESULT hits="$Hits$" mean_rpc_rtt_ms="$(TotalRTT/Max(1,Samples))$" pawn="$PlayerClass$" weapon="$WeaponClass);
    if(Hits>0 && InStr(PlayerClass,"InstaGibPlus_11.")>=0 && InStr(WeaponClass,"InstaGibPlus_11.ST_")>=0)
        Log("NETLAB PASS actual IGPlus client fire produced server hit");
    else Log("NETLAB FAIL backend or server-hit check");
    ConsoleCommand("exit");
}
simulated function Timer()
{
    local PlayerPawn P;
    P=PlayerPawn(Owner);
    if(P==None || P.Player==None || NetTarget==None) return;
    if(Stage==0)
    {
        if(Samples<8) { ServerEcho(Level.TimeSeconds); return; }
        P.ViewRotation=rotator(NetTarget.Location-(P.Location+P.EyeHeight*vect(0,0,1)));
        P.SetRotation(P.ViewRotation); P.bFire=1; P.Fire(0);
        Stage=1; return;
    }
    P.bFire=0;
    if(Stage++>=4) { SetTimer(0,False); ServerReport(); }
}
defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
    bOnlyOwnerSee=True
    NetPriority=3
}
