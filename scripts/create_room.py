"""Generate a reproducible simple training room T3D and exact grid textures."""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[1]

def textures():
    for name,base,line in [('TrainingWall',(35,43,55),(65,79,94)),('TrainingFloor',(24,31,40),(57,70,85))]:
        im=Image.new('RGB',(128,128),base);d=ImageDraw.Draw(im)
        d.rectangle((0,0,127,127),outline=line,width=2)
        d.line((64,0,64,128),fill=line,width=1);d.line((0,64,128,64),fill=line,width=1)
        im.convert('P',palette=Image.Palette.ADAPTIVE,colors=256).save(ROOT/'UTAT'/'Textures'/(name+'.pcx'))

def main():
    textures()
    faces=[
       ('TrainingFloor',[(1536,-1024,0),(1536,1024,0),(-1536,1024,0),(-1536,-1024,0)],(0,0,-1)),
       ('TrainingWall',[(-1536,-1024,768),(-1536,1024,768),(1536,1024,768),(1536,-1024,768)],(0,0,1)),
       ('TrainingWall',[(-1536,-1024,0),(-1536,1024,0),(-1536,1024,768),(-1536,-1024,768)],(-1,0,0)),
       ('TrainingWall',[(1536,1024,0),(1536,-1024,0),(1536,-1024,768),(1536,1024,768)],(1,0,0)),
       ('TrainingWall',[(1536,-1024,0),(-1536,-1024,0),(-1536,-1024,768),(1536,-1024,768)],(0,-1,0)),
       ('TrainingWall',[(-1536,1024,0),(1536,1024,0),(1536,1024,768),(-1536,1024,768)],(0,1,0))]
    def v(x):return ','.join(f'{a:+013.6f}' for a in x)
    out=['Begin Map','Begin Actor Class=LevelInfo Name=LevelInfo0','    Title="UT99 Aimtrainer - Simple Room"','    Author="Aimtrainer UT99 contributors"','    DefaultGameType=Class\'UTAT.UTATGame\'','    AmbientBrightness=140','End Actor',
         'Begin Actor Class=Brush Name=Brush0','    Begin Brush Name=BuilderModel','        Begin PolyList','        End PolyList','    End Brush',"    Brush=Model'BuilderModel'",'End Actor','Begin Actor Class=Brush Name=TrainingRoom','    CsgOper=CSG_Subtract','    Begin Brush Name=RoomModel','        Begin PolyList']
    for i,(tex,verts,n) in enumerate(faces):
        verts=list(reversed(verts))  # Outward winding for a subtractive solid brush.
        u=(0,1,0) if n[0] else (1,0,0);t=(0,0,1) if n[0] or n[1] else (0,1,0)
        out += [f'            Begin Polygon Texture=UTAT.{tex} Flags=4194304 Link={i}', '                Origin '+v(verts[0]),'                Normal '+v(n),'                TextureU '+v(u),'                TextureV '+v(t)]
        out += ['                Vertex '+v(a) for a in verts];out += ['            End Polygon']
    out += ['        End PolyList','    End Brush',"    Brush=Model'RoomModel'",'End Actor']
    out += ['Begin Actor Class=PlayerStart Name=PlayerStart0','    Location=(X=-1100,Y=-480,Z=50)','    Rotation=(Pitch=0,Yaw=0,Roll=0)','End Actor',
        'Begin Actor Class=UTAT.UTATRoomInfo Name=RoomInfo0','    Location=(X=-1100,Y=0,Z=40)','End Actor']
    for i,x in enumerate([-1100,0,1100]):
        out += [f'Begin Actor Class=Light Name=Light{i}',f'    Location=(X={x},Y=0,Z=600)','    LightBrightness=200','    LightRadius=64','End Actor']
    out+=['End Map'];(ROOT/'maps'/'DM-UTAT-Room.t3d').write_text('\n'.join(out)+'\n')
if __name__=='__main__':main()
