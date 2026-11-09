// Dedicated actor keeps round updates independent from inherited match/warmup logic.
class UTATRoundController extends Info;
var UTATGame Trainer;
function Tick(float Delta)
{
    if(Trainer==None) return;
    if(Trainer.AutoStart && Trainer.Trainee!=None && Trainer.Trainee.Player!=None)
    {
        Trainer.AutoStart=False;
        Trainer.Trainee.AimStart();
        Trainer.Trainee.ResumeTraining();
    }
    if(Trainer.Trainee!=None && Trainer.Trainee.PendingTrainingPanel)
        Trainer.Trainee.ShowTrainingPanel();
    if(Level.Pauser=="") Trainer.UpdateRound(Delta);
}
defaultproperties
{
    bHidden=True
    bAlwaysTick=True
    RemoteRole=ROLE_None
}
