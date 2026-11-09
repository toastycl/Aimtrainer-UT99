// A controlled target, not an AI bot. Collision approximates a standing player.
class UTATTarget extends Actor;
var UTATGame Trainer;
var bool AcceptHits;

function PostBeginPlay()
{
    local int I;
    local Texture T;
    Super.PostBeginPlay();
    for (I=0; I<4; I++)
    {
        T = Texture(DynamicLoadObject("SoldierSkins.blkt"$string(I+1), class'Texture', True));
        if (T != None)
            MultiSkins[I] = T;
    }
    LoopAnim('Breath1', 0.4);
}

function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                    vector Momentum, name DamageType)
{
    if (AcceptHits && Trainer != None && InstigatedBy == Trainer.Trainee)
        Trainer.RegisterHit(Self);
}

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=LodMesh'Botpack.Soldier'
    DrawScale=1.000000
    CollisionRadius=17.000000
    CollisionHeight=39.000000
    bCollideActors=True
    bCollideWorld=True
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=True
    bUnlit=True
    RemoteRole=ROLE_None
    Physics=PHYS_None
}
