// Opt-in real standalone Viewport/UWindow integration test: ?ClientTest=1.
class UTATClientTest extends Info;
var UTATGame G;
var UTATPlayer P;
var WindowConsole WC;
var UTATWindow W;
var UTATPanel Panel;
var int Stage, Failures;
var float Age;
function Check(bool Condition,string Message)
{
    if(Condition) Log("PASS "$Message,'UTATClientTest');
    else { Failures++; Log("FAIL "$Message,'UTATClientTest'); }
}
function PostBeginPlay()
{
    Super.PostBeginPlay();
    G=UTATGame(Level.Game);
}
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
        Check(Level.NetMode==NM_Standalone,"real standalone viewport is active");
        Check(G.NumBots==0 && !G.bRequireReady && P.Health>0,"hostile DM defaults do not spawn bots or kill trainee");
        P.ShowTrainingPanel(); FindPanel();
        Check(Panel!=None,"training controls created in real UWindow root");
        if(Panel==None) { ConsoleCommand("exit"); return; }
        Panel.DurationControl.SetSelectedIndex(1);
        Panel.WeaponControl.SetSelectedIndex(0);
        Panel.Notify(Panel.StartButton,Panel.DE_Click);
        Check(G.Running && G.SessionDuration==30,"Start button applies selected 30-second duration");
        Check(Level.Pauser=="" && !WC.bUWindowActive,"Start resumes gameplay and closes menu");
        Check(P.Weapon.AmmoType.UseAmmo(5000) && P.Weapon.AmmoType.AmmoAmount==999,"viewport weapon has true infinite ammo");
        Age=0; Stage=1;
    }
    else if(Stage==1 && Age>1.0)
    {
        Check(G.RoundElapsed>0.5,"round clock advances in real standalone client");
        P.Weapon.GotoState('Idle'); P.Fire(0);
        P.ShowTrainingPanel(); FindPanel();
        Panel.Notify(Panel.FinishButton,Panel.DE_Click);
        Check(!G.Running && G.HasResult && G.Shots>0,"Finish button ends round and retains scored statistics");
        Check(W.bWindowVisible && WC.bUWindowActive,"results stay visible in the live menu");
        Panel.DurationControl.SetSelectedIndex(1);
        Panel.Notify(Panel.StartButton,Panel.DE_Click);
        Check(G.Running && G.Shots==0 && !G.HasResult,"replay clears counters and old results");
        Age=0; Stage=2;
    }
    else if(Stage==2 && !G.Running)
    {
        Check(G.HasResult && G.LastComplete && G.LastElapsed==30,"30-second round finishes automatically with results");
        FindPanel();
        Check(Panel!=None && WC.bUWindowActive,"timed finish opens result controls");
        P.ResumeTraining(); Age=0; Stage=3;
    }
    else if(Stage==3 && Age>0.25)
    {
        Check(UTATHUD(P.myHUD)!=None && G.HasResult,"persistent result HUD remains available after closing menu");
        Log("DONE failures="$Failures,'UTATClientTest');
        ConsoleCommand("exit");
        Stage=4;
    }
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
