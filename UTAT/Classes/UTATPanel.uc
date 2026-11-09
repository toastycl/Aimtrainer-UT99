class UTATPanel extends UWindowDialogClientWindow;
var UWindowComboControl WeaponControl, ExerciseControl, DurationControl, EnvironmentControl;
var UWindowEditControl RTTControl;
var UTATNetworkBridge Bridge;
var UTATStore Saved;
var string NetworkError;
var UWindowSmallButton StartButton, FinishButton, CancelButton, AboutButton;
var bool Initializing;
var UTATPlayer P;
function UWindowComboControl AddChoice(float Y,string Caption)
{
    local UWindowComboControl B;
    B=UWindowComboControl(CreateControl(class'UWindowComboControl',16,Y,392,22));
    B.SetText(Caption); B.SetEditable(False); return B;
}
function UWindowSmallButton AddButton(float X,float Y,float W,string Caption)
{
    local UWindowSmallButton B;
    B=UWindowSmallButton(CreateControl(class'UWindowSmallButton',X,Y,W,24));
    B.SetText(Caption); return B;
}
function Created()
{
    local int I;
    Super.Created(); Initializing=True;
    P=UTATPlayer(GetPlayerOwner());
    Saved=new(None) class'UTATStore';
    EnvironmentControl=AddChoice(8,"Environment");
    EnvironmentControl.AddItem("Local practice"); EnvironmentControl.AddItem("IGPlus / all classic weapons");
    EnvironmentControl.SetSelectedIndex(Clamp(Saved.NetworkEnvironment,0,1));
    RTTControl=UWindowEditControl(CreateControl(class'UWindowEditControl',16,40,392,22));
    RTTControl.SetText("IGPlus added RTT / 0-300 ms");RTTControl.SetValue(string(Clamp(Saved.AddedRTT,0,300)));
    RTTControl.SetNumericOnly(True);RTTControl.SetMaxLength(3);
    WeaponControl=AddChoice(80,"Weapon");
    for(I=0; I<11; I++) WeaponControl.AddItem(class'UTATWeaponCatalog'.static.Label(I));
    ExerciseControl=AddChoice(120,"Targets");
    ExerciseControl.AddItem("Static characters"); ExerciseControl.AddItem("Moving / lateral strafe");
    DurationControl=AddChoice(160,"Round");
    DurationControl.AddItem("60 seconds","60"); DurationControl.AddItem("30 seconds","30");
    DurationControl.AddItem("120 seconds","120"); DurationControl.AddItem("Free practice","0");
    WeaponControl.SetSelectedIndex(0); ExerciseControl.SetSelectedIndex(0); DurationControl.SetSelectedIndex(0);
    if(P!=None)
    {
        P.EnsureSettings(); WeaponControl.SetSelectedIndex(P.Settings.WeaponIndex);
        ExerciseControl.SetSelectedIndex(P.Settings.Exercise);
        if(P.Settings.Duration==0) DurationControl.SetSelectedIndex(3);
        else if(P.Settings.Duration==30) DurationControl.SetSelectedIndex(1);
        else if(P.Settings.Duration==120) DurationControl.SetSelectedIndex(2);
    }
    StartButton=AddButton(16,202,392,"Start training");
    FinishButton=AddButton(16,242,190,"Finish round");
    CancelButton=AddButton(218,242,190,"Cancel round");
    AboutButton=AddButton(16,344,392,"About / Credits");
    if(Saved.NetworkEnvironment==1)
    {
        WeaponControl.SetSelectedIndex(Clamp(Saved.NetworkWeapon,0,10));ExerciseControl.SetSelectedIndex(Clamp(Saved.Exercise,0,1));
        if(Saved.Duration==0) DurationControl.SetSelectedIndex(3);else if(Saved.Duration==30) DurationControl.SetSelectedIndex(1);else if(Saved.Duration==120) DurationControl.SetSelectedIndex(2);
    }
    Initializing=False;
}
function Paint(Canvas C,float X,float Y)
{
    local UTATGame G;
    local UTATNetworkState NS;
    Super.Paint(C,X,Y);
    P=UTATPlayer(GetPlayerOwner());
    C.Font=Root.Fonts[F_Normal]; C.DrawColor.R=20; C.DrawColor.G=20; C.DrawColor.B=20;
    if(Bridge!=None) ClipText(C,16,328,Bridge.Status);
    else if(NetworkError!="") ClipText(C,16,328,NetworkError);
    else if(EnvironmentControl.GetSelectedIndex()==0) ClipText(C,16,328,"Local mode has no added network latency.");
    else ClipText(C,16,328,"Start-Aimtrainer helper must be running.");
    if(P==None)
    {
        NS=class'UTATNetworkState'.static.Find(GetPlayerOwner());
        if(NS!=None) { StartButton.bDisabled=NS.RoundRunning;if(NS.ResultReady) StartButton.SetText("Return to setup");FinishButton.bDisabled=!NS.RoundRunning;CancelButton.bDisabled=!NS.RoundRunning; }
        return;
    }
    G=UTATGame(P.Level.Game); if(G==None) return;
    FinishButton.bDisabled=!G.Running; CancelButton.bDisabled=!G.Running; StartButton.bDisabled=G.Running || (Bridge!=None && Bridge.Waiting);
    if(Bridge!=None && Bridge.Waiting) CancelButton.bDisabled=False;
    if(G.Running)
    {
        ClipText(C,16,286,"Round paused in menu | elapsed "$int(G.RoundElapsed)$"s");
        ClipText(C,16,308,"Finish round shows results over the room.");
    }
    else if(G.HasResult)
    {
        if(G.Shots==0 && G.BeamActive>0) ClipText(C,16,286,"Last beam contact: "$int(100*G.BeamContact/G.BeamActive)$"%");
        else ClipText(C,16,286,"Last accuracy: "$int(G.AccuracyPercent())$"% | "$G.Hits$" / "$G.Shots);
        ClipText(C,16,308,"Eliminations: "$G.Eliminations$" | "$int(G.LastElapsed)$"s");
    }
    else ClipText(C,16,286,"Random safe spawns / unlimited ammunition.");
}
function Notify(UWindowDialogControl C,byte E)
{
    local int Duration,Weapon,Exercise;
    local string URL;
    local UTATGame G;
    local UTATNetworkState NS;
    local int I,RTT;
    local string Value;
    Super.Notify(C,E);
    if(Initializing) return;
    if(C==EnvironmentControl && E==DE_Change)
    {
        Initializing=True;WeaponControl.Clear();
        for(I=0;I<11;I++) WeaponControl.AddItem(class'UTATWeaponCatalog'.static.Label(I));
        WeaponControl.SetSelectedIndex(0);Initializing=False;return;
    }
    if(E!=DE_Click) return;
    P=UTATPlayer(GetPlayerOwner());
    if(P!=None) G=UTATGame(P.Level.Game);
    if(C==AboutButton)
    {
        Root.CreateWindow(class'UTATAboutWindow',60,60,440,390,,True);
        return;
    }
    if(C==StartButton)
    {
        NS=class'UTATNetworkState'.static.Find(GetPlayerOwner());
        if(NS!=None) {if(!NS.RoundRunning) NS.Acknowledge();return;}
        if(G!=None && G.Running) return;
        if(Bridge!=None && Bridge.Waiting) return;
        NetworkError="";
        Weapon=Max(0,WeaponControl.GetSelectedIndex());
        Exercise=Max(0,ExerciseControl.GetSelectedIndex());
        Duration=int(DurationControl.GetValue2()); if(DurationControl.GetValue2()=="") Duration=60;
        Saved.NetworkEnvironment=EnvironmentControl.GetSelectedIndex();
        if(Saved.NetworkEnvironment==1)
        {
            Value=RTTControl.GetValue();
            if(Value=="" || int(Value)<0 || int(Value)>300) { NetworkError="Enter added RTT from 0 to 300 ms.";return; }
            for(I=0;I<Len(Value);I++) if(InStr("0123456789",Mid(Value,I,1))<0) { NetworkError="Use whole milliseconds only.";return; }
            RTT=int(Value);Saved.AddedRTT=RTT;Saved.NetworkWeapon=Weapon;Saved.Exercise=Exercise;Saved.Duration=Duration;Saved.SaveConfig();
            if(Bridge!=None) Bridge.Destroy();
            Bridge=GetPlayerOwner().Spawn(class'UTATNetworkBridge');
            if(Bridge==None) {NetworkError="Could not start local handshake.";return;}
            Bridge.BeginRequest(GetPlayerOwner(),Weapon,Exercise,Duration,RTT);return;
        }
        Saved.SaveConfig();
        if(P!=None && P.Settings!=None) P.Settings.NetworkEnvironment=0;
        if(P==None || !(string(P.Level.Outer.Name)~="DM-UTAT-Room"))
        {
            URL="DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?AutoStart=1?LabWeapon="$Weapon$"?LabExercise="$Exercise$"?LabSeconds="$Duration;
            if(G!=None && G.ClientTest) URL=URL$"?ClientTest=1?AutoStartCheck=1";
            GetPlayerOwner().ClientTravel(URL,TRAVEL_Absolute,False);
            ParentWindow.Close(); Root.Console.CloseUWindow(); return;
        }
        P.AimWeapon(Weapon); P.AimExercise(Exercise); P.AimDuration(Duration); P.AimStart();
        ParentWindow.Close(); P.ResumeTraining();
    }
    else if(C==FinishButton)
    {
        if(P!=None) P.AimFinish();
        else { NS=class'UTATNetworkState'.static.Find(GetPlayerOwner());if(NS!=None) { NS.RequestFinish();Root.Console.CloseUWindow(); } }
    }
    else if(C==CancelButton)
    {
        if(Bridge!=None && Bridge.Waiting) {Bridge.CancelRequest();return;}
        if(P!=None) P.AimStop();else {NS=class'UTATNetworkState'.static.Find(GetPlayerOwner());if(NS!=None) {NS.RequestCancel();Root.Console.CloseUWindow();}}
    }
}
