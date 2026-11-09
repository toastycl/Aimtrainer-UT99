// Small independent PRNG: recorded seeds allow a spawn sequence to be reproduced.
class UTATSpawnPlanner extends Object;
static function float Unit(out int Seed)
{
    Seed=(Seed*25173+13849) & 65535;
    return float(Seed)/65536.0;
}
static function vector InBox(out int Seed,vector Low,vector High)
{
    local vector P;
    P.X=Low.X+(High.X-Low.X)*Unit(Seed);
    P.Y=Low.Y+(High.Y-Low.Y)*Unit(Seed);
    P.Z=Low.Z;
    return P;
}
