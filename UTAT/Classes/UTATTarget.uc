// Standing human-sized training dummy. No AI or attack behavior.
class UTATTarget extends Pawn;
var UTATGame Trainer;
var vector HomePosition;
var int Index;
var float ReadyAt,MoveRemaining,MoveSpeed,JumpAge,BurstRemaining;
var vector TrainingGoal;
var bool Jumping;
function PostBeginPlay()
{
    local int I;
    local Texture T;
    Super.PostBeginPlay();
    for(I=0; I<4; I++)
    {
        T=Texture(DynamicLoadObject("SoldierSkins.blkt"$string(I+1),class'Texture',True));
        if(T!=None) MultiSkins[I]=T;
    }
    LoopAnim('Breath1',0.4);
}
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, name DamageType)
{
    if (bHidden || Trainer==None || InstigatedBy!=Trainer.Trainee || !Trainer.AcceptDamage(Self,Damage)) return;
    Health-=Damage;
    if(Health<=0)
    {
        Trainer.Eliminations++;
        bHidden=True;
        SetCollision(False,False,False);
        ReadyAt=Level.TimeSeconds+0.5;
    }
}
defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'Botpack.Soldier'
    CollisionRadius=17.000000
    CollisionHeight=39.000000
    bCollideActors=True
    bCollideWorld=True
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=True
    bGameRelevant=True
    bUnlit=True
    RemoteRole=ROLE_None
    Physics=PHYS_None
    Health=100
}
