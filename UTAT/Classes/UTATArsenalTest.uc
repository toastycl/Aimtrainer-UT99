// Opt-in real-client weapon matrix, never spawned in ordinary play.
class UTATArsenalTest extends Info;
var float Age;
var int Stage;
var UTATGame G;
var UTATPlayer P;
function PostBeginPlay() { Super.PostBeginPlay();G=UTATGame(Level.Game); }
function Tick(float Delta)
{
    local vector Pos;
    if(G==None) return;
    Age+=Delta/FMax(0.01,Level.TimeDilation);
    if(Stage==0 && G.Running && G.Trainee!=None && Age>1)
    {
        P=G.Trainee;Pos=P.Location;
        if(G.WeaponIndex==9) Pos.X+=60;else Pos.X+=220;
        G.Targets[0].HomePosition=Pos;G.Targets[0].SetLocation(Pos);
        P.Handedness=0;P.Weapon.SetHand(0);
        P.ViewRotation=rotator(Pos-(P.Location+P.EyeHeight*vect(0,0,1)));P.SetRotation(P.ViewRotation);
        P.Weapon.GotoState('Idle');
        if(G.ArsenalAlt) {P.bAltFire=1;P.AltFire(0);}else {P.bFire=1;P.Fire(0);}
        Stage=1;Age=0;
    }
    else if(Stage==1 && Age>0.5) { P.bFire=0;P.bAltFire=0;Stage=2; }
    if(Stage==2 && !G.Running)
    {
        Log("ARSENAL RESULT weapon="$class'UTATWeaponCatalog'.static.Key(G.WeaponIndex)$" shots="$G.Shots$" hits="$G.Hits$" elapsed="$G.LastElapsed$" beam_active="$G.BeamActive$" beam_contact="$G.BeamContact);
        if(((G.Shots>0 && G.Hits>0 && G.Hits<=G.Shots) || (G.ArsenalAlt && G.WeaponIndex==1 && G.Shots==0) || (G.ArsenalAlt && G.WeaponIndex==3 && G.BeamActive>0 && G.BeamContact>0)) && G.LastComplete) Log("ARSENAL PASS");else Log("ARSENAL FAIL");
        P.ConsoleCommand("exit");Stage=3;
    }
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
}
