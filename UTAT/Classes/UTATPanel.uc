class UTATPanel extends UWindowDialogClientWindow;
var UWindowComboControl WeaponControl, ExerciseControl, DurationControl;
var UWindowSmallButton EnterButton, StartButton, FinishButton, CancelButton;
var bool Initializing;
var UTATPlayer P;
function UWindowComboControl AddChoice(float Y, string Caption)
{
    local UWindowComboControl B;
    B=UWindowComboControl(CreateControl(class'UWindowComboControl',16,Y,392,22));
    B.SetText(Caption); B.SetEditable(False);
    return B;
}
function UWindowSmallButton AddButton(float X, float Y, float W, string Caption)
{
    local UWindowSmallButton B;
    B=UWindowSmallButton(CreateControl(class'UWindowSmallButton',X,Y,W,24));
    B.SetText(Caption); return B;
}
function Created()
{
    local int I;
    Super.Created();
    Initializing=True;
    P=UTATPlayer(GetPlayerOwner());
    EnterButton=AddButton(16,48,392,"Enter training room");
    WeaponControl=AddChoice(90,"Weapon");
    for(I=0; I<6; I++) WeaponControl.AddItem(class'UTATGame'.static.WeaponLabel(I));
    ExerciseControl=AddChoice(124,"Targets");
    ExerciseControl.AddItem("Static characters");
    ExerciseControl.AddItem("Moving / lateral strafe");
    DurationControl=AddChoice(158,"Round");
    DurationControl.AddItem("60 seconds","60"); DurationControl.AddItem("30 seconds","30");
    DurationControl.AddItem("120 seconds","120"); DurationControl.AddItem("Free practice","0");
    WeaponControl.SetSelectedIndex(0); ExerciseControl.SetSelectedIndex(0); DurationControl.SetSelectedIndex(0);
    if(P!=None)
    {
        P.EnsureSettings();
        WeaponControl.SetSelectedIndex(P.Settings.WeaponIndex);
        ExerciseControl.SetSelectedIndex(P.Settings.Exercise);
        if(P.Settings.Duration==0) DurationControl.SetSelectedIndex(3);
        else if(P.Settings.Duration==30) DurationControl.SetSelectedIndex(1);
        else if(P.Settings.Duration==120) DurationControl.SetSelectedIndex(2);
        else DurationControl.SetSelectedIndex(0);
    }
    StartButton=AddButton(16,202,190,"Start / Play again");
    FinishButton=AddButton(218,202,190,"Finish and show score");
    CancelButton=AddButton(16,238,392,"Cancel round");
    Initializing=False;
}
function Paint(Canvas C,float X,float Y)
{
    local UTATGame G;
    Super.Paint(C,X,Y);
    P=UTATPlayer(GetPlayerOwner());
    C.Font=Root.Fonts[F_Normal];
    C.DrawColor.R=20; C.DrawColor.G=20; C.DrawColor.B=20;
    ClipText(C,16,12,"UT99 AIMTRAINER / practice room");
    if(P==None)
    {
        ClipText(C,16,30,"Enter the room to choose a weapon and exercise.");
        return;
    }
    G=UTATGame(P.Level.Game);
    if(G==None) return;
    ClipText(C,16,30,"Use your normal mouse settings. No profile required.");
    if(G.HasResult)
    {
        ClipText(C,16,280,"LAST ROUND / "$class'UTATGame'.static.WeaponLabel(G.WeaponIndex));
        ClipText(C,16,300,"Accuracy: "$int(G.AccuracyPercent())$"% | "$G.Hits$" / "$G.Shots$" units");
        ClipText(C,16,320,"Eliminations: "$G.Eliminations$" | Time: "$int(G.LastElapsed)$"s");
        ClipText(C,16,340,"Unit: "$class'UTATGame'.static.UnitLabel(G.WeaponIndex)$". Splash counted once per projectile.");
        if(!G.LastComplete) ClipText(C,16,360,"Ended early / cancelled - no timed comparison.");
    }
    else if(G.Running)
    {
        ClipText(C,16,280,"ROUND RUNNING | elapsed "$int(G.RoundElapsed)$"s");
        ClipText(C,16,300,"Finish and show score ends the current round.");
    }
    else
    {
        ClipText(C,16,280,"Primary fire. Unlimited ammunition is always enabled.");
        ClipText(C,16,300,G.LastSummary);
    }
}
function Notify(UWindowDialogControl C,byte E)
{
    local int Duration;
    local UTATGame G;
    Super.Notify(C,E);
    if(Initializing || E!=DE_Click) return;
    if(C==EnterButton)
    {
        GetPlayerOwner().ClientTravel("DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0",TRAVEL_Absolute,False);
        ParentWindow.Close(); Root.Console.CloseUWindow(); return;
    }
    P=UTATPlayer(GetPlayerOwner());
    if(P==None) return;
    G=UTATGame(P.Level.Game);
    if(C==StartButton)
    {
        if(G.Running) { P.ClientMessage("Finish or cancel the current round first."); return; }
        P.AimWeapon(WeaponControl.GetSelectedIndex());
        P.AimExercise(ExerciseControl.GetSelectedIndex());
        Duration=int(DurationControl.GetValue2());
        if(DurationControl.GetValue2()=="") Duration=60;
        P.AimDuration(Duration); P.AimStart();
        ParentWindow.Close(); P.ResumeTraining();
    }
    else if(C==FinishButton) { P.AimFinish(); }
    else if(C==CancelButton) { P.AimStop(); }
}
