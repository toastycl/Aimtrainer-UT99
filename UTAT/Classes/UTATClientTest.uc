// Real viewport/UWindow regression: Entry -> selected weapon -> round -> result -> click.
class UTATClientTest extends Info;
var UTATGame G;
var UTATPlayer P;
var WindowConsole WC;
var UTATWindow W;
var UTATPanel Panel;
var int Stage, Failures, FinishedShots;
var float Age;
var vector PreviousAnchor, PreviousTarget;
function Check(bool Condition,string Message)
{
    if(Condition) Log("PASS "$Message,'UTATClientTest');
    else { Failures++; Log("FAIL "$Message,'UTATClientTest'); }
}
function PostBeginPlay() { Super.PostBeginPlay(); G=UTATGame(Level.Game); }
function FindPanel()
{
    W=UTATWindow(WC.Root.FindChildWindow(class'UTATWindow',True));
    if(W!=None) Panel=UTATPanel(W.ClientArea);
}
function Tick(float Delta)
{
    Age+=Delta/FMax(0.01,Level.TimeDilation);
    if(Stage==0)
    {
        foreach AllActors(class'UTATPlayer',P)
            if(P.Player!=None && Viewport(P.Player)!=None) break;
        if(P==None || P.Player==None || Age<1.0) return;
        WC=WindowConsole(P.Player.Console);
        if(WC==None) return;
        if(WC.Root==None) { P.ShowTrainingPanel(); return; }
        P.ShowTrainingPanel(); FindPanel();
        if(Panel==None) { Check(False,"controls exist"); ConsoleCommand("exit"); return; }
        if(!(string(Level.Outer.Name)~="DM-UTAT-Room"))
        {
            Panel.WeaponControl.SetSelectedIndex(1); Panel.DurationControl.SetSelectedIndex(1);
            Log("ENTRY_START: selected Sniper and 30 seconds through the only Start button",'UTATClientTest');
            Stage=99; Panel.Notify(Panel.StartButton,Panel.DE_Click); return;
        }
        if(G.AutoStartCheck)
        {
            Check(G.Running && G.WeaponIndex==1 && P.Weapon.IsA('UTATSniper'),"one Start button keeps selected Sniper across room travel");
            Check(G.SessionDuration==30,"selected duration survives room travel");
            G.FinishSession(False); P.ShowTrainingPanel(); FindPanel();
        }
        Check(Level.NetMode==NM_Standalone,"real standalone viewport is active");
        Check(G.NumBots==0 && !G.bRequireReady && P.Health>0,"combat bots and warmup remain disabled");
        Panel.WeaponControl.SetSelectedIndex(1); Panel.ExerciseControl.SetSelectedIndex(0);
        Panel.DurationControl.SetSelectedIndex(1);
        Panel.Notify(Panel.StartButton,Panel.DE_Click);
        Check(G.Running && G.SessionDuration==30 && G.WeaponIndex==1,"Start uses selected weapon and 30-second duration");
        Check(Level.Pauser=="" && !WC.bUWindowActive,"Start resumes world");
        PreviousAnchor=G.Anchor;
        Age=0; Stage=1;
    }
    else if(Stage==1 && Age>1.0)
    {
        Check(G.RoundElapsed>0.5,"round clock advances");
        P.Weapon.GotoState('Idle'); P.bFire=1; P.Fire(0);
        P.ShowTrainingPanel(); FindPanel(); Panel.Notify(Panel.FinishButton,Panel.DE_Click);
        FinishedShots=G.Shots;
        Check(!G.Running && G.HasResult && !G.ResultsDismissed,"manual finish stores results over the room");
        Check(!WC.bUWindowActive && Level.Pauser=="","manual finish does not open selection menu");
        Check(P.bFire==0 && P.bAltFire==0,"held fire is cleared at finish");
        P.Fire(0);
        Check(!WC.bUWindowActive && G.Shots==FinishedShots,"finish-frame fire cannot skip results or add a shot");
        Age=0; Stage=2;
    }
    else if(Stage==2 && Age>0.4)
    {
        P.Fire(0); FindPanel();
        Check(WC.bUWindowActive && G.ResultsDismissed,"fresh fire acknowledges result and opens selector");
        Check(G.Shots==FinishedShots,"acknowledgement does not fire weapon or alter accuracy");
        Panel.DurationControl.SetSelectedIndex(1); Panel.Notify(Panel.StartButton,Panel.DE_Click);
        Check(G.Running && G.Shots==0 && !G.HasResult,"replay clears counters");
        Check(VSize(G.Anchor-PreviousAnchor)>=160,"new round chooses a different safe trainee start");
        PreviousTarget=G.Targets[0].HomePosition;
        G.ActiveShot=G.NewShot();
        G.Targets[0].TakeDamage(1000,P,G.Targets[0].Location,vect(0,0,0),'shot');
        G.ActiveShot=None; Age=0; Stage=3;
    }
    else if(Stage==3 && Age>1.0)
    {
        Check(!G.Targets[0].bHidden && G.Targets[0].Health==100,"eliminated target respawns");
        Check(VSize(G.Targets[0].HomePosition-PreviousTarget)>=180,"target respawns at a different random point");
        Check(VSize(G.Targets[0].Location-P.Location)>=700,"respawn stays away from trainee");
        Stage=4;
    }
    else if(Stage==4 && !G.Running)
    {
        Check(G.HasResult && G.LastComplete && G.LastElapsed==30,"timed round finishes at selected duration");
        Check(!WC.bUWindowActive && !G.ResultsDismissed,"timed result stays on screen without menu");
        Age=0; Stage=5;
    }
    else if(Stage==5 && Age>0.4)
    {
        Check(UTATHUD(P.myHUD)!=None && G.HasResult,"result HUD stays available");
        FinishedShots=G.Shots; P.Fire(0);
        Check(WC.bUWindowActive && G.Shots==FinishedShots,"post-timer fire opens selector without shooting");
        Log("DONE failures="$Failures,'UTATClientTest'); ConsoleCommand("exit"); Stage=99;
    }
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
