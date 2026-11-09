class UTATWeaponCatalog extends Object;
static function string Key(int I)
{
    switch(I)
    {
        case 0:return "Shock"; case 1:return "Sniper"; case 2:return "Minigun";
        case 3:return "Pulse"; case 4:return "Rocket"; case 5:return "Flak";
        case 6:return "Enforcer"; case 7:return "Bio"; case 8:return "Ripper";
        case 9:return "Hammer"; case 10:return "Redeemer";
    }
    return "Shock";
}
static function string Label(int I)
{
    if(I<6) return class'UTATGame'.static.WeaponLabel(I);
    switch(I) { case 6:return "Enforcer";case 7:return "Bio Rifle";case 8:return "Ripper";case 9:return "Impact Hammer";case 10:return "Redeemer"; }
    return "Unknown";
}
