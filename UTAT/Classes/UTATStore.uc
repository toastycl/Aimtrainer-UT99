// Only this object saves configuration. Player settings are applied in memory.
class UTATStore extends Object config(UTAT);

struct AimProfile
{
    var bool Saved;
    var float Sensitivity;
    var bool NoSmoothing;
    var bool MaxSmoothing;
    var float SmoothThreshold;
};
var config AimProfile Profiles[3];
var config int ActiveProfile;
var config int Exercise; // 0 static, 1 strafe, 2 evasive, 3 aerial
var config int WeaponIndex;
var config int Duration;
var config int TargetDistance,TargetSize;
struct RoundEntry
{
    var string Weapon,Exercise,Distance,Size,FireStyle;
    var int Seconds,Elapsed,Shots,Hits,Kills;
    var float Sensitivity,BeamActive,BeamContact,FOV;
    var bool Complete,NoSmoothing,MaxSmoothing;
    var float SmoothThreshold;
};
var config RoundEntry History[10];
var config int HistoryCount;
var config string LastResult;
// Keep large config arrays inside their owner (UE1 context bytecode has a 255-byte limit).
function string HistoryLine(int Index,int Line)
{
    local string Metric,Status;
    Index=Clamp(Index,0,9);
    if(Line==0)
    {
        Metric="No emissions";
        if(History[Index].Shots==0 && History[Index].BeamActive>0) Metric="Acc n/a";
        if(History[Index].Shots>0) Metric="Acc "$(100*History[Index].Hits/History[Index].Shots)$"%";
        if(History[Index].BeamActive>0) Metric=Metric$" | Beam "$int(100*History[Index].BeamContact/History[Index].BeamActive)$"%";
        return "#"$(Index+1)$" "$History[Index].Weapon$" | sens "$Left(string(History[Index].Sensitivity),6)$" | "$Metric$" | kills "$History[Index].Kills;
    }
    if(Line==1)
    {
        Status="partial";if(History[Index].Complete) Status="complete";
        return History[Index].Exercise$" | "$History[Index].Distance$" | "$History[Index].Size$" | "$History[Index].Elapsed$"/"$History[Index].Seconds$"s (0=free) | "$Status;
    }
    if(Line==2) return History[Index].FireStyle$" | units "$History[Index].Hits$"/"$History[Index].Shots$" | FOV "$int(History[Index].FOV)$" | noSmooth "$History[Index].NoSmoothing;
    return "maxSmooth "$History[Index].MaxSmoothing$" | threshold "$History[Index].SmoothThreshold;
}
function AddRound(UTATGame G,UTATPlayer P)
{
    local int I;
    for(I=9;I>0;I--) History[I]=History[I-1];
    History[0].Weapon=class'UTATGame'.static.WeaponLabel(G.WeaponIndex);
    History[0].Exercise=class'UTATTrainingOptions'.static.Exercise(G.ExerciseMode);
    History[0].Distance=class'UTATTrainingOptions'.static.Distance(G.DistanceMode);
    History[0].Size=class'UTATTrainingOptions'.static.Size(G.SizeMode);
    History[0].FireStyle="none";
    if(G.FireMask==1) History[0].FireStyle="primary";
    else if(G.FireMask==2) History[0].FireStyle="secondary";
    else if(G.FireMask==3) History[0].FireStyle="mixed";
    History[0].Seconds=G.SessionDuration;History[0].Elapsed=int(G.LastElapsed);
    History[0].Shots=G.Shots;History[0].Hits=G.Hits;History[0].Kills=G.Eliminations;
    History[0].Sensitivity=P.MouseSensitivity;History[0].FOV=G.SessionFOV;
    History[0].NoSmoothing=P.bNoMouseSmoothing;History[0].MaxSmoothing=P.bMaxMouseSmoothing;
    History[0].SmoothThreshold=P.MouseSmoothThreshold;
    History[0].BeamActive=G.BeamActive;History[0].BeamContact=G.BeamContact;
    History[0].Complete=G.LastComplete;
    HistoryCount=Min(10,Max(0,HistoryCount)+1);SaveConfig();
}
// Legacy network settings are ignored; local play has no external helper.

defaultproperties
{
    Duration=60
}
