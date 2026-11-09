class UTATRoundGame extends DeathMatchPlus;
var UTATRoundState StateInfo;
var UTATNetTarget Targets[3];
var UTATNetShot ActiveShot;
var PlayerPawn Trainee;
var int WeaponIndex,Exercise,RoundSeconds,AddedRTT,RoundId,Seed,TestMode;
var float RoundAge;
var bool Running,MenuPaused,TestAlt;
function InitGame(string Options,out string Error)
{
    local int I;
    local string Key;
    Super.InitGame(Options,Error);
    Key=ParseOption(Options,"LabWeapon");
    WeaponIndex=-1;
    for(I=0;I<11;I++) if(class'UTATWeaponCatalog'.static.Key(I)~=Key) WeaponIndex=I;
    if(WeaponIndex<0) { Error="Unknown training weapon";return; }
    Exercise=Clamp(GetIntOption(Options,"Exercise",0),0,1);
    RoundSeconds=Clamp(GetIntOption(Options,"Duration",60),0,300);
    AddedRTT=Clamp(GetIntOption(Options,"AddedRTT",0),0,300);
    TestAlt=HasOption(Options,"AltTest");
    TestMode=GetIntOption(Options,"RoundTest",0);
    if(TestMode==2) RoundSeconds=7;
    InitialBots=0;MinPlayers=0;RemainingBots=0;CountDown=0;
    bTournament=False;bRequireReady=False;bNetReady=False;TimeLimit=0;FragLimit=0;
}
function PostBeginPlay()
{
    Super.PostBeginPlay();RemainingBots=0;
    Spawn(class'UTATNetProjectileNotify');
}
function bool AddBot() { return False; }
function bool ForceAddBot() { return False; }
function bool NeedPlayers() { return False; }
function Timer() {SentText=0;}
function int ReduceDamage(int Damage,name DamageType,Pawn Injured,Pawn InstigatedBy) {return 0;}
function AddDefaultInventory(Pawn P)
{
    local Weapon W;
    local class<Weapon> WC;
    WC=class<Weapon>(DynamicLoadObject("UTATNetLab.NW"$class'UTATWeaponCatalog'.static.Key(WeaponIndex),class'Class'));
    if(WC==None) return;
    W=Spawn(WC,,,P.Location);if(W==None) return;
    W.GiveTo(P);W.GiveAmmo(P);W.SetSwitchPriority(P);W.WeaponSet(P);P.Weapon=W;W.SetHand(PlayerPawn(P).Handedness);W.BringUp();
}
function PostLogin(PlayerPawn P)
{
    local int I;
    Super.PostLogin(P);Trainee=P;Seed=Rand(65535)+1;RoundId++;
    P.SetLocation(class'UTATSpawnPlanner'.static.InBox(Seed,vect(-1250,-550,40),vect(-950,550,40)));
    P.ViewRotation=rotator(vect(300,0,40)-P.Location);P.SetRotation(P.ViewRotation);
    StateInfo=Spawn(class'UTATRoundState',P);
    StateInfo.RoundRunning=True;StateInfo.RequestedRTT=AddedRTT;StateInfo.Duration=RoundSeconds;
    StateInfo.WeaponIndex=WeaponIndex;StateInfo.Exercise=Exercise;StateInfo.TestMode=TestMode;StateInfo.TestAlt=TestAlt;
    Running=True;
    for(I=0;I<3;I++) { Targets[I]=Spawn(class'UTATNetTarget',,,vect(300,0,40));Targets[I].Trainer=Self;PlaceTarget(Targets[I],False); }
    StateInfo.FirstTarget=Targets[0];
    Log("ROUND backend pawn="$P.Class$" weapon="$P.Weapon.Class$" added_rtt_ms="$AddedRTT);
}
function bool PlaceTarget(UTATNetTarget T,bool Respawn)
{
    local int Attempt,I;
    local vector Pos;
    local bool Clear;
    for(Attempt=0;Attempt<64;Attempt++)
    {
        Pos=class'UTATSpawnPlanner'.static.InBox(Seed,vect(-200,-700,40),vect(1150,700,40));
        if(VSize(Pos-Trainee.Location)<750 || (Respawn && VSize(Pos-T.HomePosition)<180)) continue;
        Clear=True;
        for(I=0;I<3;I++) if(Targets[I]!=None && Targets[I]!=T && VSize(Pos-Targets[I].HomePosition)<200) Clear=False;
        if(!Clear || !FastTrace(Pos,Trainee.Location) || !T.SetLocation(Pos)) continue;
        T.HomePosition=Pos;T.Health=100;T.bHidden=False;T.SetCollision(True,False,False);T.SetRotation(rotator(Trainee.Location-Pos));return True;
    }
    FinishRound(False);return False;
}
function UTATNetShot NewShot()
{
    local UTATNetShot S;
    if(!Running) return None;
    S=new(None) class'UTATNetShot';S.RoundId=RoundId;StateInfo.Shots++;return S;
}
function bool AcceptDamage(int Damage)
{
    if(!Running || Damage<=0 || ActiveShot==None || ActiveShot.RoundId!=RoundId) return False;
    if(!ActiveShot.Hit && !ActiveShot.Beam) { ActiveShot.Hit=True;StateInfo.Hits++; }
    return True;
}
function Tick(float Delta)
{
    local int I;
    local vector Pos;
    if(!Running || Trainee==None || MenuPaused) return;
    RoundAge+=Delta/FMax(0.01,Level.TimeDilation);StateInfo.Elapsed=RoundAge;
    if(Trainee.Weapon!=None && Trainee.Weapon.AmmoType!=None) Trainee.Weapon.AmmoType.AmmoAmount=999;
    Trainee.Health=100;
    if(RoundSeconds>0 && RoundAge>=RoundSeconds) {StateInfo.Elapsed=RoundSeconds;FinishRound(True);return;}
    for(I=0;I<3;I++)
    {
        if(Targets[I]==None) continue;
        if(Targets[I].bHidden && Level.TimeSeconds>=Targets[I].ReadyAt) PlaceTarget(Targets[I],True);
        if(!Targets[I].bHidden) { Pos=Targets[I].HomePosition;if(Exercise==1) Pos.Y+=64*Sin(RoundAge*2+I);Targets[I].SetLocation(Pos); }
    }

}
function FinishRound(bool Complete)
{
    local Projectile P;
    local int I;
    if(!Running) return;
    Running=False;MenuPaused=False;Level.Pauser="";ActiveShot=None;StateInfo.RoundRunning=False;StateInfo.ResultReady=True;
    if(Trainee!=None) {Trainee.bFire=0;Trainee.bAltFire=0;if(Trainee.Weapon!=None) Trainee.Weapon.GotoState('Idle');}
    foreach AllActors(class'Projectile',P) if(P.Instigator==Trainee) P.Destroy();
    for(I=0;I<3;I++) if(Targets[I]!=None) Targets[I].Destroy();
    Log("NETRESULT|weapon="$class'UTATWeaponCatalog'.static.Key(WeaponIndex)$"|shots="$StateInfo.Shots$"|hits="$StateInfo.Hits$"|kills="$StateInfo.Kills$"|damage="$StateInfo.DamageDone$"|elapsed="$StateInfo.Elapsed$"|complete="$Complete$"|added_rtt_ms="$AddedRTT$"|exercise="$Exercise$"|beam_active="$StateInfo.BeamActive$"|beam_contact="$StateInfo.BeamContact);
}
defaultproperties
{
    GameName="UT99 Aimtrainer / IGPlus"
    HUDType=Class'UTAT.UTATNetworkHUD'
    MaxPlayers=1
    InitialBots=0
    MinPlayers=0
    bRequireReady=False
    bRestartLevel=False
}
