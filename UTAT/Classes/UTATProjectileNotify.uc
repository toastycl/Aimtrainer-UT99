// Replace exact stock projectile classes, preserving their flight and spawn settings.
class UTATProjectileNotify extends SpawnNotify;
event Actor SpawnNotification(Actor A)
{
    local Projectile P, R;
    local class<Projectile> Replacement;
    local UTATGame G;
    local UTATShot S;
    P=Projectile(A);
    G=UTATGame(Level.Game);
    if(P==None || G==None || !G.Running || P.Instigator!=G.Trainee) return A;
    if(P.Class==class'PlasmaSphere') Replacement=class'UTATPlasma';
    if(P.Class==class'RocketMk2') Replacement=class'UTATRocket';
    if(P.Class==class'UT_SeekingRocket') Replacement=class'UTATSeekingRocket';
    if(P.Class==class'UTChunk1') Replacement=class'UTATChunk1';
    if(P.Class==class'UTChunk2') Replacement=class'UTATChunk2';
    if(P.Class==class'UTChunk3') Replacement=class'UTATChunk3';
    if(P.Class==class'UTChunk4') Replacement=class'UTATChunk4';
    if(Replacement==None) return A;
    R=Spawn(Replacement,P.Owner,,P.Location,P.Rotation);
    if(R==None) return A;
    R.Instigator=P.Instigator;
    R.Velocity=P.Velocity;
    R.Acceleration=P.Acceleration;
    R.SetPhysics(P.Physics);
    S=G.NewShot();
    if(UTATPlasma(R)!=None) UTATPlasma(R).Shot=S;
    if(UTATRocket(R)!=None) UTATRocket(R).Shot=S;
    if(UTATSeekingRocket(R)!=None) UTATSeekingRocket(R).Shot=S;
    if(UTATChunk1(R)!=None) UTATChunk1(R).Shot=S;
    if(UTATChunk2(R)!=None) UTATChunk2(R).Shot=S;
    if(UTATChunk3(R)!=None) UTATChunk3(R).Shot=S;
    if(UTATChunk4(R)!=None) UTATChunk4(R).Shot=S;
    P.Destroy();
    return R;
}
defaultproperties
{
    ActorClass=Class'Engine.Projectile'
}
