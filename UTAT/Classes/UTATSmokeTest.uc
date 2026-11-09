// Opt-in engine-level smoke test: ?SmokeTest=1. Never used by normal training.
class UTATSmokeTest extends Info;
var UTATGame G;
var UTATPlayer P;
var int Step, Failures;
var UTATShot OldShot;
function Check(bool Value,string Message)
{
    if(Value) Log("PASS "$Message,'UTATTest');
    else { Log("FAIL "$Message,'UTATTest'); Failures++; }
}
function PostBeginPlay()
{
    Super.PostBeginPlay();
    G=UTATGame(Level.Game);
    SetTimer(2.0,True);
}
function Timer()
{
    local int WeaponId;
    if(Step==0)
    {
        Check(G.Room!=None,"room marker exists");
        Check(G.InitialBots==0 && G.MinPlayers==0 && !G.bRequireReady,"DeathMatch preferences cannot populate or stall lab");
        Check(!G.AddBot() && !G.ForceAddBot() && !G.NeedPlayers(),"combat bot insertion disabled");
        if(G.Room==None) { ConsoleCommand("exit"); return; }
        P=Spawn(class'UTATPlayer',,,G.Room.Location);
        Check(P!=None,"player fits inside map");
        if(P==None) { ConsoleCommand("exit"); return; }
        P.EnsureSettings();
        P.Settings.Duration=0;
    }
    if(Step<12)
    {
        WeaponId=Step/2;
        if(Step%2==0)
        {
            P.Settings.WeaponIndex=WeaponId;
            P.Settings.Exercise=0;
            G.StartSession(P);
            Check(G.Running && G.Targets[0]!=None && G.Targets[2]!=None,"round starts with three targets");
            Check(VSize(P.Location-G.Targets[1].Location)>=700,"trainee and target starts are separated");
            Check(P.Weapon.AmmoType.UseAmmo(2000) && P.Weapon.AmmoType.AmmoAmount==999,"infinite ammo independent from round tick");
            if(WeaponId==5) P.SetLocation(G.Targets[1].Location-400*Normal(G.Targets[1].Location-P.Location));
            else P.SetLocation(G.Targets[1].Location-600*Normal(G.Targets[1].Location-P.Location));
            P.ViewRotation=rotator(G.Targets[1].Location-P.Location-P.EyeHeight*vect(0,0,1));
            P.Weapon.GotoState('Idle');
            P.Weapon.Fire(0);
        }
        else
        {
            Check(P.Weapon.AmmoType.AmmoAmount==999,"infinite ammo survives round updates");
            Check(G.Shots>0,"emissions counted: "$G.WeaponLabel(WeaponId));
            Check(G.Hits>0,"real weapon hits target: "$G.WeaponLabel(WeaponId));
            Check(G.Hits<=G.Shots,"accuracy bounded: "$G.WeaponLabel(WeaponId));
            G.FinishSession(True);
        }
    }
    else if(Step==12)
    {
        P.Settings.WeaponIndex=0; P.Settings.Exercise=1;
        G.StartSession(P);
        OldShot=G.NewShot();
        G.ActiveShot=OldShot;
        G.Targets[0].TakeDamage(1,P,G.Targets[0].Location,vect(0,0,0),'shot');
        G.Targets[1].TakeDamage(1,P,G.Targets[1].Location,vect(0,0,0),'shot');
        Check(G.Shots==1 && G.Hits==1,"one emission can hit multiple targets only once");
        G.ActiveShot=None;
    }
    else if(Step==13)
    {
        Check(VSize(G.Targets[0].Location-G.Targets[0].HomePosition)>1,"moving exercise changes target position");
        G.FinishSession(False);
        G.StartSession(P);
        Check(G.Shots==0 && G.Hits==0 && G.Eliminations==0,"restart clears counters");
        G.ActiveShot=OldShot;
        G.Targets[0].TakeDamage(50,P,G.Targets[0].Location,vect(0,0,0),'shot');
        Check(G.Targets[0].Health==100,"old-round projectile cannot score");
        G.ActiveShot=None;
        G.FinishSession(False);
        P.Settings.Duration=1;
        G.StartSession(P);
    }
    else if(Step==14)
    {
        Check(!G.Running && G.LastComplete,"timed round ends automatically");
        Check(G.NewShot()==None,"no emissions after finish");
        Log("DONE failures="$Failures,'UTATTest');
        ConsoleCommand("exit");
    }
    Step++;
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
