#!/usr/bin/env python3
"""Developer-only native standalone checks. Players do not need Python."""
import argparse,os,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
WEAPONS=('Shock','Sniper','Minigun','Pulse','Rocket','Flak','Enforcer','Bio','Ripper','Hammer','Redeemer')
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--system',default='System64');p.add_argument('--offscreen',action='store_true');p.add_argument('--alt',action='store_true');p.add_argument('--weapon',choices=WEAPONS)
    a=p.parse_args();system=a.ut_root.resolve()/a.system
    game=next((system/n for n in ('UnrealTournament.exe','ut-bin-amd64','ut-bin','UnrealTournament') if (system/n).is_file()),None)
    if game is None:p.error('Client not found')
    source=system/'UTATMapBuild.ini'
    if not source.exists():p.error('Build the mod/map first')
    config='\n'.join(l for l in source.read_text(encoding='utf-8-sig').splitlines() if not l.startswith(('ServerPackages=','ServerActors=')))
    config+='\n[SDLDrv.SDLClient]\nStartupFullscreen=False\nWindowedViewportX=1280\nWindowedViewportY=720\n'
    (system/'UTATArsenalCheck.ini').write_text(config)
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    if a.offscreen:env.update(SDL_VIDEODRIVER='offscreen',LIBGL_ALWAYS_SOFTWARE='1')
    folder=ROOT/'build';folder.mkdir(exist_ok=True);failed=[]
    for index,key in enumerate(WEAPONS):
        if a.weapon and key!=a.weapon:continue
        label='standalone-'+key.lower()+('-alt' if a.alt else '')
        url=f'DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?AutoStart=1?LabWeapon={index}?LabSeconds=5?ArsenalTest=1'
        if a.alt:url+='?AltTest=1'
        engine=system/'UnrealTournament.log';engine.unlink(missing_ok=True)
        with (folder/(label+'-console.log')).open('w') as output:
            process=subprocess.Popen([str(game),url,'-ini=UTATArsenalCheck.ini','-userini=UTATArsenalUser.ini','-nohomedir','-nosound','-windowed','-log','-FORCELOGFLUSH'],cwd=system,env=env,stdout=output,stderr=subprocess.STDOUT)
            try:
                deadline=time.monotonic()+25;text=''
                while time.monotonic()<deadline:
                    if engine.exists():text=engine.read_text(errors='replace')
                    if 'ARSENAL PASS' in text or 'ARSENAL FAIL' in text or process.poll() is not None:break
                    time.sleep(.2)
                (folder/(label+'-engine.log')).write_text(text)
                print('\n'.join(l for l in text.splitlines() if 'ARSENAL ' in l),flush=True)
                if 'ARSENAL PASS' not in text or 'ARSENAL FAIL' in text:failed.append(key)
            finally:
                if process.poll() is None:process.terminate()
                try:process.wait(timeout=5)
                except subprocess.TimeoutExpired:process.kill();process.wait()
    if failed:raise SystemExit('Failed: '+', '.join(failed))
if __name__=='__main__':main()
