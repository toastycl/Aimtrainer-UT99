// Preserve stock primary fire, cadence and trace. Count traces, not button presses.
class UTATShock extends ShockRifle;

function TraceFire(float Accuracy)
{
    local UTATGame G;
    G = UTATGame(Level.Game);
    if (G != None && Pawn(Owner) == G.Trainee)
        G.RegisterShot();
    Super.TraceFire(Accuracy);
}

function AltFire(float Value)
{
    if (PlayerPawn(Owner) != None)
        PlayerPawn(Owner).ClientMessage("This alpha measures Shock primary only. Combos are planned.");
}

defaultproperties
{
    ItemName="Aimtrainer Shock Rifle"
    bCanThrow=False
}
