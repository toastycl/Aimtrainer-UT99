class UTATNetProjectileNotify extends SpawnNotify;
simulated event Actor SpawnNotification(Actor A)
{
    local Pawn PreviousInstigator;
    local bool WasColliding,WasBlockingActors,WasBlockingPlayers;
    local Actor R;local class<Actor> WC;local UTATRoundGame G;local UTATNetShot S;
    G=UTATRoundGame(Level.Game);if(G==None || !G.Running || A.Instigator!=G.Trainee) return A;
    if(A.Class==class'InstaGibPlus_11.ST_PlasmaSphere') WC=class'NPPlasmaSphere';
    if(A.Class==class'InstaGibPlus_11.ST_RocketMk2') WC=class'NPRocketMk2';
    if(A.Class==class'InstaGibPlus_11.ST_UT_SeekingRocket') WC=class'NPUT_SeekingRocket';
    if(A.Class==class'InstaGibPlus_11.ST_UT_Grenade') WC=class'NPUT_Grenade';
    if(A.Class==class'InstaGibPlus_11.ST_ShockProj') WC=class'NPShockProj';
    if(A.Class==class'InstaGibPlus_11.ST_FlakSlug') WC=class'NPFlakSlug';
    if(A.Class==class'InstaGibPlus_11.ST_UT_BioGel') WC=class'NPUT_BioGel';
    if(A.Class==class'InstaGibPlus_11.ST_BioGlob') WC=class'NPBioGlob';
    if(A.Class==class'InstaGibPlus_11.ST_BioSplash') WC=class'NPBioSplash';
    if(A.Class==class'InstaGibPlus_11.ST_Razor2') WC=class'NPRazor2';
    if(A.Class==class'InstaGibPlus_11.ST_Razor2Alt') WC=class'NPRazor2Alt';
    if(A.Class==class'InstaGibPlus_11.ST_WarShell') WC=class'NPWarShell';
    if(A.Class==class'InstaGibPlus_11.ST_GuidedWarshell') WC=class'NPGuidedWarshell';
    if(A.Class==class'InstaGibPlus_11.ST_ShockWave') WC=class'NPShockWave';
    if(A.Class==class'InstaGibPlus_11.ST_UTChunk1') WC=class'NPUTChunk1';
    if(A.Class==class'InstaGibPlus_11.ST_UTChunk2') WC=class'NPUTChunk2';
    if(A.Class==class'InstaGibPlus_11.ST_UTChunk3') WC=class'NPUTChunk3';
    if(A.Class==class'InstaGibPlus_11.ST_UTChunk4') WC=class'NPUTChunk4';
    if(A.Class==class'InstaGibPlus_11.ST_StarterBolt') WC=class'NPStarterBolt';
    if(WC==None) return A;
    WasColliding=A.bCollideActors;WasBlockingActors=A.bBlockActors;WasBlockingPlayers=A.bBlockPlayers;
    A.SetCollision(False,False,False);
    PreviousInstigator=Instigator;Instigator=A.Instigator;
    R=Spawn(WC,A.Owner,,A.Location,A.Rotation);Instigator=PreviousInstigator;
    if(R==None) {A.SetCollision(WasColliding,WasBlockingActors,WasBlockingPlayers);return A;}
    R.SetCollision(WasColliding,WasBlockingActors,WasBlockingPlayers);R.SetCollisionSize(A.CollisionRadius,A.CollisionHeight);
    R.Instigator=A.Instigator;R.Velocity=A.Velocity;R.Acceleration=A.Acceleration;R.SetPhysics(A.Physics);
    S=G.ActiveShot;if(S==None && !A.IsA('ST_StarterBolt')) S=G.NewShot();
    if(NPPlasmaSphere(R)!=None) NPPlasmaSphere(R).Shot=S;
    if(NPRocketMk2(R)!=None) NPRocketMk2(R).Shot=S;
    if(NPUT_SeekingRocket(R)!=None) NPUT_SeekingRocket(R).Shot=S;
    if(NPUT_Grenade(R)!=None) NPUT_Grenade(R).Shot=S;
    if(NPShockProj(R)!=None) NPShockProj(R).Shot=S;
    if(NPFlakSlug(R)!=None) NPFlakSlug(R).Shot=S;
    if(NPUT_BioGel(R)!=None) NPUT_BioGel(R).Shot=S;
    if(NPBioGlob(R)!=None) NPBioGlob(R).Shot=S;
    if(NPBioSplash(R)!=None) NPBioSplash(R).Shot=S;
    if(NPRazor2(R)!=None) NPRazor2(R).Shot=S;
    if(NPRazor2Alt(R)!=None) NPRazor2Alt(R).Shot=S;
    if(NPWarShell(R)!=None) NPWarShell(R).Shot=S;
    if(NPGuidedWarshell(R)!=None) NPGuidedWarshell(R).Shot=S;
    if(NPShockWave(R)!=None) NPShockWave(R).Shot=S;
    if(NPUTChunk1(R)!=None) NPUTChunk1(R).Shot=S;
    if(NPUTChunk2(R)!=None) NPUTChunk2(R).Shot=S;
    if(NPUTChunk3(R)!=None) NPUTChunk3(R).Shot=S;
    if(NPUTChunk4(R)!=None) NPUTChunk4(R).Shot=S;
    A.Destroy();return R;
}
defaultproperties
{
    ActorClass=Class'Engine.Actor'
    RemoteRole=ROLE_None
}
