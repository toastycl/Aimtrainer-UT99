class UTATNetTarget extends Pawn;
var int ConfirmedHits;
var UTATRoundGame Trainer;
var vector HomePosition;
var float ReadyAt;
function PostBeginPlay()
{
    local int I;local Texture T;
    Super.PostBeginPlay();
    for(I=0;I<4;I++) { T=Texture(DynamicLoadObject("SoldierSkins.blkt"$string(I+1),class'Texture',True));if(T!=None) MultiSkins[I]=T; }
    LoopAnim('Breath1',0.4);
}
function TakeDamage(int Damage,Pawn InstigatedBy,vector HitLocation,vector Momentum,name DamageType)
{
    if(Trainer!=None)
    {
        if(bHidden || InstigatedBy!=Trainer.Trainee || !Trainer.AcceptDamage(Damage)) return;
        Trainer.StateInfo.DamageDone+=Min(Damage,Health);Health-=Damage;
        if(Health<=0) { Trainer.StateInfo.Kills++;bHidden=True;SetCollision(False,False,False);ReadyAt=Level.TimeSeconds+0.5; }
        return;
    }
    if(Damage>0 && PlayerPawn(InstigatedBy)!=None)
    {
        ConfirmedHits++;
        Log("NETLAB server-hit "$ConfirmedHits$" damage="$Damage$" weapon="$InstigatedBy.Weapon.Class);
    }
}
defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'Botpack.Soldier'
    CollisionRadius=17
    CollisionHeight=39
    bCollideActors=True
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=True
    bGameRelevant=True
    bUnlit=True
    RemoteRole=ROLE_SimulatedProxy
    Physics=PHYS_None
    Health=100000
}
