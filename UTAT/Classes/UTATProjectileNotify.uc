class UTATProjectileNotify extends SpawnNotify;
simulated event Actor SpawnNotification(Actor A)
{
    local Pawn PreviousInstigator;
    local bool WasColliding,WasBlockingActors,WasBlockingPlayers;
    local Actor R;local class<Actor> WC;local UTATGame G;local UTATShot S;
    G=UTATGame(Level.Game);if(G==None || !G.Running || A.Instigator!=G.Trainee) return A;
    if(A.Class==class'Botpack.PlasmaSphere') WC=class'LPPlasmaSphere';
    if(A.Class==class'Botpack.RocketMk2') WC=class'LPRocketMk2';
    if(A.Class==class'Botpack.UT_SeekingRocket') WC=class'LPUT_SeekingRocket';
    if(A.Class==class'Botpack.UT_Grenade') WC=class'LPUT_Grenade';
    if(A.Class==class'Botpack.ShockProj') WC=class'LPShockProj';
    if(A.Class==class'Botpack.FlakSlug') WC=class'LPFlakSlug';
    if(A.Class==class'Botpack.UT_BioGel') WC=class'LPUT_BioGel';
    if(A.Class==class'Botpack.BioGlob') WC=class'LPBioGlob';
    if(A.Class==class'Botpack.BioSplash') WC=class'LPBioSplash';
    if(A.Class==class'Botpack.Razor2') WC=class'LPRazor2';
    if(A.Class==class'Botpack.Razor2Alt') WC=class'LPRazor2Alt';
    if(A.Class==class'Botpack.WarShell') WC=class'LPWarShell';
    if(A.Class==class'Botpack.GuidedWarshell') WC=class'LPGuidedWarshell';
    if(A.Class==class'Botpack.ShockWave') WC=class'LPShockWave';
    if(A.Class==class'Botpack.UTChunk1') WC=class'LPUTChunk1';
    if(A.Class==class'Botpack.UTChunk2') WC=class'LPUTChunk2';
    if(A.Class==class'Botpack.UTChunk3') WC=class'LPUTChunk3';
    if(A.Class==class'Botpack.UTChunk4') WC=class'LPUTChunk4';
    if(A.Class==class'Botpack.StarterBolt') WC=class'LPStarterBolt';
    if(WC==None) return A;
    WasColliding=A.bCollideActors;WasBlockingActors=A.bBlockActors;WasBlockingPlayers=A.bBlockPlayers;
    A.SetCollision(False,False,False);
    PreviousInstigator=Instigator;Instigator=A.Instigator;
    R=Spawn(WC,A.Owner,,A.Location,A.Rotation);Instigator=PreviousInstigator;
    if(R==None) {A.SetCollision(WasColliding,WasBlockingActors,WasBlockingPlayers);return A;}
    R.SetCollision(WasColliding,WasBlockingActors,WasBlockingPlayers);R.SetCollisionSize(A.CollisionRadius,A.CollisionHeight);
    R.Instigator=A.Instigator;R.Velocity=A.Velocity;R.Acceleration=A.Acceleration;R.SetPhysics(A.Physics);
    S=G.ActiveShot;if(S==None && !A.IsA('StarterBolt')) S=G.NewShot();
    if(LPPlasmaSphere(R)!=None) LPPlasmaSphere(R).Shot=S;
    if(LPRocketMk2(R)!=None) LPRocketMk2(R).Shot=S;
    if(LPUT_SeekingRocket(R)!=None) LPUT_SeekingRocket(R).Shot=S;
    if(LPUT_Grenade(R)!=None) LPUT_Grenade(R).Shot=S;
    if(LPShockProj(R)!=None) LPShockProj(R).Shot=S;
    if(LPFlakSlug(R)!=None) LPFlakSlug(R).Shot=S;
    if(LPUT_BioGel(R)!=None) LPUT_BioGel(R).Shot=S;
    if(LPBioGlob(R)!=None) LPBioGlob(R).Shot=S;
    if(LPBioSplash(R)!=None) LPBioSplash(R).Shot=S;
    if(LPRazor2(R)!=None) LPRazor2(R).Shot=S;
    if(LPRazor2Alt(R)!=None) LPRazor2Alt(R).Shot=S;
    if(LPWarShell(R)!=None) LPWarShell(R).Shot=S;
    if(LPGuidedWarshell(R)!=None) LPGuidedWarshell(R).Shot=S;
    if(LPShockWave(R)!=None) LPShockWave(R).Shot=S;
    if(LPUTChunk1(R)!=None) LPUTChunk1(R).Shot=S;
    if(LPUTChunk2(R)!=None) LPUTChunk2(R).Shot=S;
    if(LPUTChunk3(R)!=None) LPUTChunk3(R).Shot=S;
    if(LPUTChunk4(R)!=None) LPUTChunk4(R).Shot=S;
    A.Destroy();return R;
}
defaultproperties
{
    ActorClass=Class'Engine.Actor'
    RemoteRole=ROLE_None
}
