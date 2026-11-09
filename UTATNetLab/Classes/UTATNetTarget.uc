class UTATNetTarget extends Pawn;
var int ConfirmedHits;
function TakeDamage(int Damage,Pawn InstigatedBy,vector HitLocation,vector Momentum,name DamageType)
{
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
    bBlockActors=True
    bBlockPlayers=True
    bProjTarget=True
    bGameRelevant=True
    bUnlit=True
    RemoteRole=ROLE_SimulatedProxy
    Physics=PHYS_None
    Health=100000
}
