// Map marker: fixed training origin/yaw. Own neutral grid textures only.
class UTATRoomInfo extends Info;
var() vector TargetOrigin;
var() vector PlayerSpawnMin, PlayerSpawnMax, TargetSpawnMin, TargetSpawnMax;
#exec TEXTURE IMPORT NAME=TrainingWall FILE=Textures\TrainingWall.pcx GROUP="" MIPS=ON
#exec TEXTURE IMPORT NAME=TrainingFloor FILE=Textures\TrainingFloor.pcx GROUP="" MIPS=ON
defaultproperties
{
    TargetOrigin=(X=300,Y=0,Z=40)
    PlayerSpawnMin=(X=-1250,Y=-550,Z=40)
    PlayerSpawnMax=(X=-950,Y=550,Z=40)
    TargetSpawnMin=(X=-200,Y=-700,Z=40)
    TargetSpawnMax=(X=1150,Y=700,Z=40)
    bStatic=True
    bHidden=True
}
