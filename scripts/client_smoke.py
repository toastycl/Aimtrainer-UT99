#!/usr/bin/env python3
"""Exercise the real standalone viewport/UWindow callbacks and a 30-second round.
Requires a complete UT installation, a built mod/map and a working renderer.
"""
import argparse
import os
import re
import shutil
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--system',default='System64')
    p.add_argument('--offscreen',action='store_true',help='Linux SDL offscreen/Mesa rendering')
    a=p.parse_args();system=a.ut_root.resolve()/a.system
    game=next((system/n for n in ['UnrealTournament.exe','ut-bin-amd64','ut-bin','UnrealTournament'] if (system/n).is_file()),None)
    if game is None:p.error('Game client executable not found')
    source=system/'UTATMapBuild.ini'
    if not source.is_file():p.error('Build the mod/map first')
    text='\n'.join(l for l in source.read_text(encoding='utf-8-sig').splitlines() if not l.startswith(('ServerPackages=','ServerActors=')))
    text+='\n[Botpack.DeathMatchPlus]\nInitialBots=8\nMinPlayers=8\nbTournament=True\nTimeLimit=20\n'
    text+='\n[SDLDrv.SDLClient]\nStartupFullscreen=False\nWindowedViewportX=1280\nWindowedViewportY=720\n'
    (system/'UTATClientCheck.ini').write_text(text,encoding='utf-8')
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    if a.offscreen:env.update(SDL_VIDEODRIVER='offscreen',LIBGL_ALWAYS_SOFTWARE='1')
    shutil.copyfile(a.ut_root.resolve()/'Maps'/'DM-UTAT-Room.unr',a.ut_root.resolve()/'Maps'/'DM-UTAT-EntryCheck.unr')
    cmd=[str(game),'DM-UTAT-EntryCheck?Game=UTAT.UTATGame?Mutator=?ClientTest=1','-ini=UTATClientCheck.ini','-userini=UTATClientCheckUser.ini','-nohomedir','-nosound','-windowed','-log','-unattended','-FORCELOGFLUSH']
    try:r=subprocess.run(cmd,cwd=system,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
    except subprocess.TimeoutExpired:p.error('Client check timed out after 90 seconds')
    text=r.stdout.decode('utf-8',errors='replace')
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    (folder/'client-console.log').write_text(text,encoding='utf-8')
    log=system/'UnrealTournament.log'
    if log.exists():(folder/'client-engine.log').write_bytes(log.read_bytes())
    lines=[m.group(1) for l in text.splitlines() if (m:=re.search(r'(?:^|: )((?:PASS |FAIL |DONE ).*)$',l))]
    print('\n'.join(lines))
    if r.returncode or 'DONE failures=0' not in text or any(l.startswith('FAIL ') for l in lines):
        raise SystemExit('Standalone client test failed. See build/client-console.log')
    print('Viewport/UWindow integration passed. Manual hardware/input/visual acceptance remains separate.')
if __name__=='__main__':main()
