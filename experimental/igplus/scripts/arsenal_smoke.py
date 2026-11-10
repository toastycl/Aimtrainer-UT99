#!/usr/bin/env python3
"""Real-client primary-fire matrix for all 11 weapons, local or actual IGPlus."""
import argparse,asyncio,subprocess,time
from pathlib import Path
from start_aimtrainer import prepare,stop,ROOT,WEAPONS
from net_relay import Relay

async def case(a,key,index):
    system,client,ucc,env=prepare(a.ut_root.resolve(),a.offscreen)
    config=(system/'UTATMenu.ini').read_text().replace('LocalMap=CityIntro.unr','LocalMap=Entry.unr')
    (system/'UTATMenu.ini').write_text(config)
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    label=('arsenal-local-' if a.local else 'arsenal-net-')+key.lower()+('-alt' if a.alt else '')
    server=relay=player=None
    with (folder/(label+'-server.log')).open('w') as serverlog,(folder/(label+'-console.log')).open('w') as clientlog:
        try:
            if a.local:
                url=f'DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?AutoStart=1?LabWeapon={index}?LabSeconds=5?ArsenalTest=1'
                if a.alt:url+='?AltTest=1'
            else:
                url=f'DM-UTAT-Room?Game=UTATNetLab.UTATRoundGame?Mutator=InstaGibPlus_11.UTPure,InstaGibPlus_11.ST_Mutator?LabWeapon={key}?AddedRTT={a.rtt_ms}?Duration=7?RoundTest=2'
                if a.alt:url+='?AltTest=1'
                server=await asyncio.create_subprocess_exec(str(ucc),'server',url,'-ini=UTATMenu.ini','-nohomedir','-lanplay','-nosound','-port=17777','-multihome=127.0.0.1','-FORCELOGFLUSH',cwd=system,env=env,stdout=serverlog,stderr=subprocess.STDOUT)
                relay,_=await asyncio.get_running_loop().create_datagram_endpoint(lambda:Relay(17777,a.rtt_ms),local_addr=('127.0.0.1',18777))
                await asyncio.sleep(1);url='127.0.0.1:18777'
            (system/'UnrealTournament.log').unlink(missing_ok=True)
            player=await asyncio.create_subprocess_exec(str(client),url,'-ini=UTATMenu.ini','-userini=UTATArsenalUser.ini','-nohomedir','-log','-windowed','-nosound','-FORCELOGFLUSH',cwd=system,env=env,stdout=clientlog,stderr=subprocess.STDOUT)
            deadline=time.monotonic()+25;text=''
            while time.monotonic()<deadline:
                log=system/'UnrealTournament.log'
                if log.exists():text=log.read_text(errors='replace')
                if ('ARSENAL PASS' if a.local else 'ROUNDTEST PASS weapon') in text or ('ARSENAL FAIL' if a.local else 'ROUNDTEST FAIL') in text or player.returncode is not None:break
                await asyncio.sleep(.2)
            (folder/(label+'-engine.log')).write_text(text)
            lines=[l for l in text.splitlines() if 'ARSENAL ' in l or 'ROUNDTEST ' in l];print('\n'.join(lines),flush=True)
            return ('ARSENAL PASS' if a.local else 'ROUNDTEST PASS weapon') in text and 'ROUNDTEST FAIL' not in text
        finally:
            await stop(player)
            if relay is not None:relay.close()
            await stop(server)
async def run(a):
    failed=[]
    for index,key in enumerate(WEAPONS):
        if a.weapon and a.weapon!=key:continue
        print('Testing',('Local' if a.local else 'IGPlus'),key,flush=True)
        if not await case(a,key,index):failed.append(key)
    if failed:raise SystemExit('Arsenal failures: '+', '.join(failed))
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--alt',action='store_true');p.add_argument('--offscreen',action='store_true');p.add_argument('--local',action='store_true');p.add_argument('--rtt-ms',type=int,default=85);p.add_argument('--weapon',choices=WEAPONS)
    a=p.parse_args()
    if not 0<=a.rtt_ms<=300:p.error('Use 0-300 ms')
    asyncio.run(run(a))
if __name__=='__main__':main()
