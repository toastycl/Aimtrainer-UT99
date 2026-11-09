// Map marker: fixed training origin/yaw. Own neutral grid textures only.
class UTATRoomInfo extends Info;
#exec TEXTURE IMPORT NAME=TrainingWall FILE=Textures\TrainingWall.pcx GROUP="" MIPS=ON
#exec TEXTURE IMPORT NAME=TrainingFloor FILE=Textures\TrainingFloor.pcx GROUP="" MIPS=ON
defaultproperties
{
    bStatic=True
    bHidden=True
}
