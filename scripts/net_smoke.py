#!/usr/bin/env python3
"""Run an isolated IGPlus 11 client/server experiment. Never targets public servers.
Requires a built UTATNetLab, a full UT install, and separately installed IGPlus 11.
"""
import argparse, os, re, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--weapon',choices=['Shock','Sniper'],default='Shock');p.add_argument('--rtt-ms',type=int,default=100)
    p.add_argument('--offscreen',action='store_true');a=p.parse_args()
    if not 0<=a.rtt_ms<=2000:p.error('RTT out of range')
    root=a.ut_root.resolve();system=root/'System64'
    if not system.is_dir():system=root/'System'
    game=next((system/n for n in ['UnrealTournament.exe','ut-bin-amd64','ut-bin'] if (system/n).exists()),None)
    ucc=next((system/n for n in ['ucc.exe','ucc-bin-amd64','ucc-bin'] if (system/n).exists()),None)
    if game is None or ucc is None:p.error('Missing UT client/compiler')
    for name in ('InstaGibPlus_11.u','InstaGibPlusAssets_v2.u','UTATNetLab.u'):
        if not any((d/name).is_file() for d in (system,root/'System')):p.error('Missing dependency: '+name)
    source=(system/'UTATMapBuild.ini').read_text(encoding='utf-8-sig')
    config='\n'.join(l for l in source.splitlines() if not l.startswith(('ServerPackages=','ServerActors=')))
    # Inject packages into the existing engine section, not the last ini section.
    config=config.replace('[Engine.GameEngine]','[Engine.GameEngine]\nServerPackages=UTAT\nServerPackages=UTATNetLab\nServerPackages=InstaGibPlus_11\nServerPackages=InstaGibPlusAssets_v2')
    config=config.replace('LocalMap=CityIntro.unr','LocalMap=Entry.unr')
    config+='\n[SDLDrv.SDLClient]\nStartupFullscreen=False\nWindowedViewportX=1280\nWindowedViewportY=720\n'
    (system/'UTATNetworkCheck.ini').write_text(config)
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    if a.offscreen:env.update(SDL_VIDEODRIVER='offscreen',LIBGL_ALWAYS_SOFTWARE='1')
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    label=f'net-{a.weapon.lower()}-{a.rtt_ms}';serverlog=(folder/(label+'-server.log')).open('w')
    common=['-ini=UTATNetworkCheck.ini','-nohomedir','-nosound','-lanplay']
    server=subprocess.Popen([str(ucc),'server',f'DM-UTAT-Room?Game=UTATNetLab.UTATNetGame?Mutator=InstaGibPlus_11.UTPure,InstaGibPlus_11.ST_Mutator?LabWeapon={a.weapon}',*common,'-port=17777','-multihome=127.0.0.1'],cwd=system,env=env,stdout=serverlog,stderr=subprocess.STDOUT)
    relay=subprocess.Popen([os.sys.executable,str(ROOT/'scripts'/'net_relay.py'),'--rtt-ms',str(a.rtt_ms)],stdout=subprocess.DEVNULL)
    try:
        time.sleep(2)
        (system/'UnrealTournament.log').unlink(missing_ok=True)
        clientfile=(folder/(label+'-client.log')).open('w')
        client=subprocess.Popen([str(game),'127.0.0.1:18777',*common,'-userini=UTATNetworkUser.ini','-windowed','-log','-unattended','-FORCELOGFLUSH'],cwd=system,env=env,stdout=clientfile,stderr=subprocess.STDOUT)
        output=''
        try:
            deadline=time.monotonic()+45
            while time.monotonic()<deadline:
                log=system/'UnrealTournament.log'
                if log.exists():output=log.read_text(errors='replace')
                if 'NETLAB PASS' in output or 'NETLAB FAIL' in output or client.poll() is not None:break
                time.sleep(0.25)
            (folder/(label+'-engine.log')).write_text(output)
        finally:
            if client.poll() is None:
                client.terminate()
                try:client.wait(timeout=5)
                except subprocess.TimeoutExpired:client.kill();client.wait()
            clientfile.close()
        lines=[m.group(0) for l in output.splitlines() if (m:=re.search('NETLAB (RTT_ms|RESULT|PASS|FAIL).*',l))]
        print('\n'.join(dict.fromkeys(lines)))
        if 'NETLAB PASS' not in output:raise SystemExit('IGPlus check failed or timed out; see build/'+label+' logs')
    except subprocess.TimeoutExpired:raise SystemExit('IGPlus client timed out; see build/'+label+'-server.log and engine log')
    finally:
        for proc in (relay,server):
            proc.terminate()
            try:proc.wait(timeout=5)
            except subprocess.TimeoutExpired:proc.kill();proc.wait()
        serverlog.close()
if __name__=='__main__':main()
