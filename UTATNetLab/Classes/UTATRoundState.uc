class UTATRoundState extends UTATNetworkState;
var int Samples,TestMode,TestStage;
var float TotalRTT,TestAge;
var bool MenuWasOpen,TestAlt;
var int MenuTestStage;
var float MenuTestAt,PauseElapsed;
var UTATNetTarget FirstTarget;
replication
{
    reliable if(Role==ROLE_Authority) TestMode,TestAlt,FirstTarget,ClientEcho;
    reliable if(Role<ROLE_Authority) ServerEcho,ServerFinish,ServerCancel,ServerPrepareShot,ServerMenu;
}
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();if(Level.NetMode==NM_Client) SetTimer(0.5,True);
}
function ServerEcho(float Sent) {ClientEcho(Sent);}
simulated function ClientEcho(float Sent)
{
    local float RTT;
    RTT=1000*(Level.TimeSeconds-Sent)/FMax(0.01,Level.TimeDilation);
    Samples++;TotalRTT+=FMax(0,RTT);MeanRTT=TotalRTT/Samples;
}
function ServerFinish() {UTATRoundGame(Level.Game).FinishRound(Duration==0);}
function ServerMenu(bool Open)
{
    local UTATRoundGame G;
    G=UTATRoundGame(Level.Game);if(!G.Running) return;
    G.MenuPaused=Open;
    if(Open) Level.Pauser=PlayerPawn(Owner).PlayerReplicationInfo.PlayerName;else Level.Pauser="";
}
simulated function RequestMenu(bool Open) {ServerMenu(Open);}
function ServerCancel() {UTATRoundGame(Level.Game).FinishRound(False);}
simulated function RequestCancel() {ServerCancel();}
simulated function RequestFinish() {ServerFinish();}
function ServerPrepareShot()
{
    local vector Pos;
    local UTATRoundGame G;
    G=UTATRoundGame(Level.Game);
    if(G.TestMode==0 || FirstTarget==None) return;
    PlayerPawn(Owner).Handedness=0;Pawn(Owner).Weapon.SetHand(0);
    Pos=Pawn(Owner).Location;
    if(G.WeaponIndex==9) Pos.X+=60;else Pos.X+=220;
    FirstTarget.SetLocation(Pos);FirstTarget.HomePosition=Pos;
}
simulated function Acknowledge()
{
    local PlayerPawn P;
    if(TestMode!=1) {Super.Acknowledge();return;}
    if(!ResultReady || ResultAge<0.25) return;
    P=PlayerPawn(Owner);P.bFire=0;P.bAltFire=0;
    P.ClientTravel("DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NetworkReturnTest=1?OpenSetup=1",TRAVEL_Absolute,False);
}
simulated function Timer()
{
    local PlayerPawn P;
    local WindowConsole WC;
    local bool MenuOpen;
    P=PlayerPawn(Owner);if(P==None || P.Player==None) return;
    WC=WindowConsole(P.Player.Console);MenuOpen=(WC!=None && WC.bUWindowActive);
    if(MenuOpen!=MenuWasOpen) {MenuWasOpen=MenuOpen;ServerMenu(MenuOpen);}
    if(Level.Pauser=="") ServerEcho(Level.TimeSeconds);
    if(TestMode==0) return;
    if(TestMode==1 && TestStage==3 && !ResultReady)
    {
        if(MenuTestStage==0)
        {
            WC.LaunchUWindow();WC.Root.CreateWindow(class'UTATWindow',40,40,440,420,,True);
            MenuTestStage=1;MenuTestAt=0;
        }
        else if(MenuTestStage<3)
        {
            MenuTestAt+=0.5;
            if(MenuTestStage==1 && MenuTestAt>=1) {PauseElapsed=Elapsed;MenuTestStage=2;}
            else if(MenuTestStage==2 && MenuTestAt>=2)
            {
                if(Abs(Elapsed-PauseElapsed)<0.2) Log("ROUNDTEST PASS server pause while setup is open");
                else Log("ROUNDTEST FAIL server pause");
                WC.CloseUWindow();RequestMenu(False);MenuTestStage=3;
            }
        }
    }
    TestAge+=0.5;
    if(TestStage==0 && RoundRunning && TestAge>1)
    {
        if(P.Weapon!=None && P.Weapon.AmmoType!=None)
        {
            if(P.Weapon.AmmoType.UseAmmo(2000) && P.Weapon.AmmoType.AmmoAmount==999) Log("ROUNDTEST PASS true infinite client ammo");
            else Log("ROUNDTEST FAIL infinite client ammo");
        }
        ServerPrepareShot();TestStage=1;TestAge=0;return;
    }
    if(TestStage==1 && TestAge>0.7 && FirstTarget!=None)
    {
        P.Handedness=0;P.Weapon.SetHand(0);
        P.ViewRotation=rotator(FirstTarget.Location-(P.Location+P.EyeHeight*vect(0,0,1)));
        P.SetRotation(P.ViewRotation);
        if(TestAlt) {P.bAltFire=1;P.AltFire(0);} else {P.bFire=1;P.Fire(0);}
        TestStage=2;TestAge=0;return;
    }
    if(TestStage==2 && TestAge>0.5) {P.bFire=0;P.bAltFire=0;TestStage=3;}
    if(ResultReady && TestStage==3 && ResultAge>0.5)
    {
        Log("ROUNDTEST RESULT weapon="$class'UTATWeaponCatalog'.static.Key(WeaponIndex)$" shots="$Shots$" hits="$Hits$" kills="$Kills$" elapsed="$Elapsed$" requested="$RequestedRTT$" measured="$MeanRTT$" game_ping="$P.PlayerReplicationInfo.Ping);
        if(((Shots>0 && Hits>0 && Hits<=Shots) || (TestAlt && WeaponIndex==1 && Shots==0) || (TestAlt && WeaponIndex==3 && BeamActive>0 && BeamContact>0)) && Elapsed==Duration && UTATNetworkHUD(P.myHUD)!=None)
            Log("ROUNDTEST PASS weapon, score, timer and result HUD");
        else Log("ROUNDTEST FAIL weapon, score, timer or result HUD");
        TestStage=4;
        if(TestMode==1) {P.bFire=0;P.Weapon.GotoState('Idle');P.Fire(0);Log("ROUNDTEST fresh fire acknowledged result");}
        else P.ConsoleCommand("exit");
    }
}
