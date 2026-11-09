class UTATPanel extends UWindowDialogClientWindow;
var UWindowComboControl WeaponControl, ExerciseControl, DurationControl;
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
    WeaponControl=AddChoice(64,"Weapon");
    for(I=0; I<6; I++) WeaponControl.AddItem(class'UTATGame'.static.WeaponLabel(I));
    ExerciseControl=AddChoice(104,"Targets");
    ExerciseControl.AddItem("Static characters"); ExerciseControl.AddItem("Moving / lateral strafe");
    DurationControl=AddChoice(144,"Round");
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
    StartButton=AddButton(16,194,392,"Start training");
    FinishButton=AddButton(16,236,190,"Finish round");
    CancelButton=AddButton(218,236,190,"Cancel round");
    AboutButton=AddButton(16,344,392,"About / Credits");
    Initializing=False;
}
function Paint(Canvas C,float X,float Y)
{
    local UTATGame G;
    Super.Paint(C,X,Y);
    P=UTATPlayer(GetPlayerOwner());
    C.Font=Root.Fonts[F_Normal]; C.DrawColor.R=20; C.DrawColor.G=20; C.DrawColor.B=20;
    ClipText(C,16,12,"UT99 AIMTRAINER / choose your training");
    ClipText(C,16,32,"Select your weapon and press Start training.");
    if(P==None) return;
    G=UTATGame(P.Level.Game); if(G==None) return;
    FinishButton.bDisabled=!G.Running; CancelButton.bDisabled=!G.Running; StartButton.bDisabled=G.Running;
    if(G.Running)
    {
        ClipText(C,16,286,"Round paused in menu | elapsed "$int(G.RoundElapsed)$"s");
        ClipText(C,16,308,"Finish round shows results over the room.");
    }
    else if(G.HasResult)
    {
        ClipText(C,16,286,"Last accuracy: "$int(G.AccuracyPercent())$"% | "$G.Hits$" / "$G.Shots);
        ClipText(C,16,308,"Eliminations: "$G.Eliminations$" | "$int(G.LastElapsed)$"s");
    }
    else ClipText(C,16,286,"Random safe spawns / unlimited ammunition.");
}
function Notify(UWindowDialogControl C,byte E)
{
    local int Duration,Weapon,Exercise;
    local string URL;
    local UTATGame G;
    Super.Notify(C,E); if(Initializing || E!=DE_Click) return;
    P=UTATPlayer(GetPlayerOwner());
    if(P!=None) G=UTATGame(P.Level.Game);
    if(C==AboutButton)
    {
        Root.CreateWindow(class'UTATAboutWindow',60,60,440,390,,True);
        return;
    }
    if(C==StartButton)
    {
        if(G!=None && G.Running) return;
        Weapon=Max(0,WeaponControl.GetSelectedIndex());
        Exercise=Max(0,ExerciseControl.GetSelectedIndex());
        Duration=int(DurationControl.GetValue2()); if(DurationControl.GetValue2()=="") Duration=60;
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
    else if(P!=None && C==FinishButton) P.AimFinish();
    else if(P!=None && C==CancelButton) P.AimStop();
}
