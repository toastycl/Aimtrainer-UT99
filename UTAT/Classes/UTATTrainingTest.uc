// Opt-in native regression for new exercise geometry, motion and persistent history.
class UTATTrainingTest extends Info;
var int Failures;
function Check(bool Value,string Message)
{
    if(Value) Log("PASS "$Message,'UTATTrainingTest');
    else {Failures++;Log("FAIL "$Message,'UTATTrainingTest');}
}
function PostBeginPlay() {Super.PostBeginPlay();SetTimer(1,False);}
function Timer()
{
    local UTATGame G;
    local UTATPlayer P;
    local UTATStore Reloaded;
    local UTATShot Shot;
    local int Mode,Distance,Size,I,Frame,Count;
    local vector Offset,Before,BeforeRespawn;
    local bool Safe,Moved,ChangedHeight,Started,SawBurst;
    G=UTATGame(Level.Game);P=Spawn(class'UTATPlayer',,,G.Room.Location);
    Check(P!=None,"training fixture has a player");
    if(P==None) {ConsoleCommand("exit");return;}
    P.EnsureSettings();P.Settings.Duration=0;P.Settings.WeaponIndex=0;
    P.Settings.HistoryCount=0;
    for(Mode=0;Mode<4;Mode++)
    for(Distance=0;Distance<4;Distance++)
    for(Size=0;Size<3;Size++)
    {
        P.Settings.Exercise=Mode;P.Settings.TargetDistance=Distance;P.Settings.TargetSize=Size;
        G.StartSession(P);Started=G.Running && G.Targets[0]!=None && G.Targets[2]!=None;
        Check(Started,"three targets / mode "$Mode$" distance "$Distance$" size "$Size);
        if(!Started) continue;
        Safe=True;Moved=False;ChangedHeight=False;Before=G.Targets[0].Location;
        for(Frame=0;Frame<180;Frame++)
        {
            G.UpdateRound(0.05);
            if(Mode==2 && G.Targets[0]!=None && G.Targets[0].BurstRemaining>0) SawBurst=True;
            for(I=0;I<3;I++)
            {
                if(G.Targets[I]==None) {Safe=False;continue;}
                Offset=G.Targets[I].Location-G.Anchor;Offset.Z=0;
                if(VSize(Offset)<class'UTATTrainingOptions'.static.MinDistance(Distance)-0.1
                    || VSize(Offset)>class'UTATTrainingOptions'.static.MaxDistance(Distance)+0.1) Safe=False;
                if(G.Targets[I].Location.Z<G.Targets[I].CollisionHeight+0.9
                    || G.Targets[I].Location.Z>740-G.Targets[I].CollisionHeight+0.1) Safe=False;
                if(Abs(G.Targets[I].CollisionHeight-39*class'UTATTrainingOptions'.static.Scale(Size))>0.01) Safe=False;
            }
            if(G.Targets[0]!=None)
            {
                if(VSize(G.Targets[0].Location-Before)>2) Moved=True;
                if(Abs(G.Targets[0].Location.Z-Before.Z)>2) ChangedHeight=True;
            }
        }
        Check(Safe && G.Running,"scaled collision and distance/height bounds survive motion");
        Check((Mode==0 && !Moved) || (Mode!=0 && Moved),"selected exercise moves only when intended");
        if(Mode==2 || Mode==3) Check(ChangedHeight,"jump/aerial trajectory changes target height");
        if(Mode==3)
        {
            BeforeRespawn=G.Targets[0].HomePosition;
            Shot=G.NewShot();G.ActiveShot=Shot;
            G.Targets[0].TakeDamage(1000,P,G.Targets[0].Location,vect(0,0,0),'shot');G.ActiveShot=None;
            Check(G.Targets[0].bHidden && G.Targets[0].Health<=0 && G.Hits==1,"scaled aerial target accepts weapon scoring");
            G.Targets[0].ReadyAt=Level.TimeSeconds;G.UpdateRound(0.05);
            Check(!G.Targets[0].bHidden && G.Targets[0].Health==100
                && G.Targets[0].Location.Z>=200 && VSize(G.Targets[0].HomePosition-BeforeRespawn)>=180,"aerial elimination respawns at a new elevated random point");
        }
        G.FireMask=2;G.BeamActive=4;G.BeamContact=3;
        G.FinishSession(False);
    }
    Check(SawBurst,"evasive movement includes brief dodge-like speed bursts");
    Check(P.Settings.HistoryCount==10,"history keeps only the last ten rounds");
    Reloaded=new(None) class'UTATStore';
    Check(Reloaded.HistoryCount==10 && InStr(Reloaded.HistoryLine(0,1),"Random aerial | Far | Large")>=0,"saved history reloads exercise, distance and size");
    Check(InStr(Reloaded.HistoryLine(0,0),"Beam 75%")>=0 && InStr(Reloaded.HistoryLine(0,2),"secondary")>=0
        && InStr(Reloaded.HistoryLine(0,1),"partial")>=0,"history preserves beam metric, fire style and partial status");
    Count=Reloaded.HistoryCount;G.FinishSession(False);
    Check(P.Settings.HistoryCount==Count,"repeated finish does not add duplicate history");
    P.Settings.Exercise=0;P.Settings.TargetDistance=0;P.Settings.TargetSize=0;P.Settings.Duration=1;
    G.StartSession(P);G.UpdateRound(1.1);
    Reloaded=new(None) class'UTATStore';
    Check(InStr(Reloaded.HistoryLine(0,1),"1/1s (0=free) | complete")>=0,"timed completion persists as complete");
    P.Settings.Duration=60;P.Settings.SaveConfig();
    Log("DONE failures="$Failures,'UTATTrainingTest');ConsoleCommand("exit");
}
defaultproperties
{
    bHidden=True
}
