#!/usr/bin/env python3
"""Run an isolated IGPlus 11 client/server experiment. Never targets public servers.
Requires a built UTATNetLab, a full UT install, and separately installed IGPlus 11.
"""
import argparse, os, re, subprocess, time
from pathlib import Path
from network_config import NetworkSession
ROOT=Path(__file__).resolve().parents[1]
def stop_process(process):
    if process is None:return
    if process.poll() is None:process.terminate()
    try:process.wait(timeout=5)
    except subprocess.TimeoutExpired:process.kill();process.wait()

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--weapon',choices=['Shock','Sniper'],default='Shock');p.add_argument('--rtt-ms',type=int,default=100)
    p.add_argument('--offscreen',action='store_true')
    p.add_argument('--manual',action='store_true',help='WIP sandbox: no automatic aiming/fire/exit; close UT to stop')
    p.add_argument('--manual-check',action='store_true',help='Developer check: verify sandbox stays open without automatic firing')
    a=p.parse_args()
    if a.manual_check:a.manual=True
    try:session=NetworkSession(a.weapon,a.rtt_ms)
    except ValueError as e:p.error(str(e))
    root=a.ut_root.resolve();system=root/'System64'
    if not system.is_dir():system=root/'System'
    game=next((system/n for n in ['UnrealTournament.exe','ut-bin-amd64','ut-bin'] if (system/n).exists()),None)
    ucc=next((system/n for n in ['ucc.exe','ucc-bin-amd64','ucc-bin'] if (system/n).exists()),None)
    if game is None or ucc is None:p.error('Missing UT client/compiler')
    for name in ('InstaGibPlus_11.u','InstaGibPlusAssets_v2.u','UTATNetLab.u'):
        if not any((d/name).is_file() for d in (system,root/'System')):p.error('Missing dependency: '+name)
    if not (system/'UTATMapBuild.ini').is_file():p.error('Build the base room with scripts/build.py first')
    if not (root/'Maps'/'DM-UTAT-Room.unr').is_file():p.error('Missing training map; build or install the base room first')
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
    label=f'net-{a.weapon.lower()}-{a.rtt_ms}'+('-manual' if a.manual else '');serverlog=(folder/(label+'-server.log')).open('w')
    common=['-ini=UTATNetworkCheck.ini','-nohomedir','-nosound','-lanplay']
    url=f'DM-UTAT-Room?Game=UTATNetLab.UTATNetGame?Mutator=InstaGibPlus_11.UTPure,InstaGibPlus_11.ST_Mutator'+session.url_options()
    if a.manual:url+='?ManualLab=1'
    server=relay=None
    try:
        server=subprocess.Popen([str(ucc),'server',url,*common,'-port=17777','-multihome=127.0.0.1'],cwd=system,env=env,stdout=serverlog,stderr=subprocess.STDOUT)
        relay=subprocess.Popen([os.sys.executable,str(ROOT/'scripts'/'net_relay.py'),'--rtt-ms',str(a.rtt_ms)],stdout=subprocess.DEVNULL)
        time.sleep(2)
        if server.poll() is not None or relay.poll() is not None:
            raise SystemExit('WIP server/relay failed to start; check dependencies and ports 17777/18777')
        (system/'UnrealTournament.log').unlink(missing_ok=True)
        clientfile=(folder/(label+'-client.log')).open('w')
        client=subprocess.Popen([str(game),'127.0.0.1:18777',*common,'-userini=UTATNetworkUser.ini','-windowed','-log','-unattended','-FORCELOGFLUSH'],cwd=system,env=env,stdout=clientfile,stderr=subprocess.STDOUT)
        output=''
        try:
            deadline=time.monotonic()+45
            ready_at=None
            manual_verified=False
            print('WIP manual sandbox: close UT or press Ctrl+C here to stop.' if a.manual else 'Running automatic IGPlus check.',flush=True)
            while True:
                log=system/'UnrealTournament.log'
                if log.exists():output=log.read_text(errors='replace')
                if 'NETLAB FAIL' in output:break
                if client.poll() is not None:break
                if a.manual and 'NETLAB MANUAL ready' in output:
                    if ready_at is None:
                        ready_at=time.monotonic()
                        print('IGPlus sandbox ready. Requested added RTT:',a.rtt_ms,'ms',flush=True)
                    if a.manual_check and time.monotonic()-ready_at>=2:
                        serverlog.flush()
                        server_text=(folder/(label+'-server.log')).read_text(errors='replace')
                        manual_verified='NETLAB MANUAL status hits=0' in output and 'NETLAB server-hit' not in server_text
                        break
                if not a.manual and 'NETLAB PASS' in output:break
                if ready_at is None and time.monotonic()>=deadline:break
                if server.poll() is not None or relay.poll() is not None:break
                time.sleep(0.25)
            (folder/(label+'-engine.log')).write_text(output)
        finally:
            stop_process(client)
            clientfile.close()
        lines=[m.group(0) for l in output.splitlines() if (m:=re.search('NETLAB (RTT_ms|RESULT|PASS|FAIL|MANUAL).*',l))]
        print('\n'.join(dict.fromkeys(lines)))
        if a.manual_check:
            if not manual_verified:raise SystemExit('Manual sandbox regression failed; see build/'+label+' logs')
            print('NETLAB PASS manual sandbox stays open without automatic firing')
        elif a.manual:
            if ready_at is None or 'NETLAB FAIL' in output:raise SystemExit('Manual sandbox failed to initialize')
        elif 'NETLAB PASS' not in output:raise SystemExit('IGPlus check failed or timed out; see build/'+label+' logs')
    except KeyboardInterrupt:
        print('WIP lab stopped by user.')
    except subprocess.TimeoutExpired:raise SystemExit('IGPlus client timed out; see build/'+label+'-server.log and engine log')
    finally:
        for proc in (relay,server):stop_process(proc)
        serverlog.close()
if __name__=='__main__':main()
