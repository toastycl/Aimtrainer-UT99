class UTATMenuNetworkTest extends Info;
var bool Returning,Done;
var float Age;
function Tick(float Delta)
{
    local UTATPlayer P;
    local WindowConsole WC;
    local UTATWindow W;
    local UTATPanel Panel;
    Age+=Delta;if(Done || Age<1.5) return;
    foreach AllActors(class'UTATPlayer',P) if(P.Player!=None) break;
    if(P==None || P.Player==None) return;
    P.ShowTrainingPanel();WC=WindowConsole(P.Player.Console);
    if(WC==None || WC.Root==None) return;
    W=UTATWindow(WC.Root.FindChildWindow(class'UTATWindow',True));if(W==None) return;
    Panel=UTATPanel(W.ClientArea);
    if(Returning)
    {
        if(Panel.EnvironmentControl.GetSelectedIndex()==1 && Panel.RTTControl.GetValue()=="85" && Panel.WeaponControl.GetSelectedIndex()==0)
            Log("MENUTEST DONE failures=0");
        else Log("MENUTEST DONE failures=1");
        Done=True;P.ConsoleCommand("exit");return;
    }
    Panel.EnvironmentControl.SetSelectedIndex(1);
    Panel.Notify(Panel.EnvironmentControl,Panel.DE_Change);
    Panel.WeaponControl.SetSelectedIndex(0);Panel.ExerciseControl.SetSelectedIndex(0);Panel.DurationControl.SetSelectedIndex(1);
    Panel.RTTControl.SetValue("85");
    Panel.Notify(Panel.StartButton,Panel.DE_Click);
    Log("MENUTEST selected IGPlus, Shock, 85 ms and 30 seconds through Start");Done=True;
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
