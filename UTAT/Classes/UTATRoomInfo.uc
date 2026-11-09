// Map marker: fixed training origin/yaw. Own neutral grid textures only.
class UTATRoomInfo extends Info;
var() vector TargetOrigin;
#exec TEXTURE IMPORT NAME=TrainingWall FILE=Textures\TrainingWall.pcx GROUP="" MIPS=ON
#exec TEXTURE IMPORT NAME=TrainingFloor FILE=Textures\TrainingFloor.pcx GROUP="" MIPS=ON
defaultproperties
{
    TargetOrigin=(X=300,Y=0,Z=40)
    bStatic=True
    bHidden=True
}
