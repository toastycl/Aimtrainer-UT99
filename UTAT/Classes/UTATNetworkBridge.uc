// Strict localhost request/ready handshake. Helper must be started once by the launcher.
class UTATNetworkBridge extends UdpLink;
var PlayerPawn Trainee;
var int WeaponIndex,Exercise,Duration,AddedRTT;
var string Status,RequestId;
var bool Waiting;
var IpAddr HelperAddress;
var float Age;
function BeginRequest(PlayerPawn P,int W,int E,int D,int RTT)
{
    local IpAddr Address;
    Trainee=P; WeaponIndex=W;Exercise=E;Duration=D;AddedRTT=RTT;
    if(BindPort()==0) { Status="Cannot bind local helper socket."; return; }
    ReceiveMode=RMODE_Event;LinkMode=MODE_Text;
    StringToIpAddr("127.0.0.1",Address);Address.Port=18778;HelperAddress=Address;
    RequestId=string(Rand(100000000));
    Status="Starting IGPlus session...";Waiting=True;Age=0;
    SendText(Address,"START|"$RequestId$"|"$class'UTATWeaponCatalog'.static.Key(W)$"|"$RTT$"|"$E$"|"$D);
}
function CancelRequest()
{
    if(!Waiting) return;
    SendText(HelperAddress,"CANCEL|"$RequestId);Waiting=False;Status="Session startup cancelled.";
}
event ReceivedText(IpAddr Address,string Text)
{
    local string Prefix;
    if(!Waiting || Address.Addr!=HelperAddress.Addr || Address.Port!=18778) return;
    Prefix="READY|"$RequestId;
    if(Text==Prefix)
    {
        Waiting=False;Status="Connected. Loading room...";
        Trainee.ClientTravel("127.0.0.1:18777",TRAVEL_Absolute,False);
        if(WindowConsole(Trainee.Player.Console)!=None) WindowConsole(Trainee.Player.Console).CloseUWindow();
    }
    else if(Left(Text,Len("ERROR|"$RequestId$"|"))==("ERROR|"$RequestId$"|"))
    { Waiting=False;Status=Mid(Text,Len("ERROR|"$RequestId$"|"));Trainee.ClientMessage(Status); }
}
function Tick(float Delta)
{
    if(!Waiting) return;
    Age+=Delta/FMax(0.01,Level.TimeDilation);
    if(Age>20) { Waiting=False;Status="Helper unavailable. Start Start-Aimtrainer first.";Trainee.ClientMessage(Status); }
}
defaultproperties
{
    bAlwaysTick=True
    RemoteRole=ROLE_None
}
