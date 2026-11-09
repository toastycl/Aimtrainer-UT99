#!/usr/bin/env python3
"""Launch UT and its localhost-only training helper. Choose settings inside UT."""
import argparse
import codecs
import asyncio
from contextlib import suppress
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
from net_relay import Relay
from network_config import NetworkSession,WEAPONS
ROOT=Path(__file__).resolve().parents[1]

def parse_request(text):
    parts=text.strip().split('|')
    if len(parts)!=6 or parts[0]!='START' or not re.fullmatch(r'[0-9]{1,9}',parts[1]):raise ValueError('Invalid helper request')
    if parts[2] not in WEAPONS:raise ValueError('Unknown weapon')
    if not all(re.fullmatch(r'[0-9]{1,3}',v) for v in parts[3:]):raise ValueError('Use whole numbers')
    rtt,exercise,duration=map(int,parts[3:])
    NetworkSession(parts[2],rtt)
    if exercise not in (0,1) or duration not in (0,30,60,120):raise ValueError('Invalid exercise or duration')
    return parts[1],parts[2],rtt,exercise,duration

async def stop(process):
    if process is None:return
    if process.returncode is None:
        with suppress(ProcessLookupError):process.terminate()
    try:await asyncio.wait_for(process.wait(),5)
    except asyncio.TimeoutError:
        with suppress(ProcessLookupError):process.kill()
        await process.wait()

class MenuService(asyncio.DatagramProtocol):
    def __init__(self,system,ucc,env,folder,test_mode=0):
        self.system=system;self.ucc=ucc;self.env=env;self.folder=folder;self.test_mode=test_mode
        self.server=None;self.relay=None;self.task=None;self.logfile=None;self.request=None;self.request_addr=None
    def connection_made(self,transport):self.transport=transport
    def datagram_received(self,data,addr):
        if addr[0]!='127.0.0.1' or len(data)>256:return
        if self.request is not None and addr==self.request_addr and data.decode('ascii',errors='replace').strip()=='CANCEL|'+self.request[0]:
            if self.task is not None:self.task.cancel()
            self.task=asyncio.create_task(self.cleanup_session());return
        try:request=parse_request(data.decode('ascii'))
        except (ValueError,UnicodeDecodeError):return
        if self.task is not None and not self.task.done():
            self.transport.sendto(f'ERROR|{request[0]}|Session startup already in progress'.encode(),addr);return
        self.request=request;self.request_addr=addr
        self.task=asyncio.create_task(self.start_session(request,addr))
    async def cleanup_session(self):
        if self.relay is not None:self.relay.close();self.relay=None
        await stop(self.server);self.server=None
        if self.logfile is not None:self.logfile.close();self.logfile=None
    async def start_session(self,request,addr):
        token,weapon,rtt,exercise,duration=request
        try:
            await self.cleanup_session()
            self.logfile=(self.folder/'menu-server.log').open('w')
            url=f'DM-UTAT-Room?Game=UTATNetLab.UTATRoundGame?Mutator=InstaGibPlus_11.UTPure,InstaGibPlus_11.ST_Mutator?LabWeapon={weapon}?AddedRTT={rtt}?Exercise={exercise}?Duration={duration}'
            if self.test_mode:url+=f'?RoundTest={self.test_mode}'
            self.server=await asyncio.create_subprocess_exec(str(self.ucc),'server',url,'-ini=UTATServer.ini','-nohomedir','-lanplay','-nosound','-port=17777','-multihome=127.0.0.1','-FORCELOGFLUSH',cwd=self.system,env=self.env,stdout=self.logfile,stderr=subprocess.STDOUT)
            self.relay,_=await asyncio.get_running_loop().create_datagram_endpoint(lambda:Relay(17777,rtt),local_addr=('127.0.0.1',18777))
            deadline=time.monotonic()+15
            while time.monotonic()<deadline:
                if self.server.returncode is not None:raise RuntimeError('IGPlus server failed; see build/menu-server.log')
                if 'Game engine initialized' in (self.folder/'menu-server.log').read_text(errors='replace'):
                    self.transport.sendto(f'READY|{token}'.encode(),addr)
                    print(f'Session ready: {weapon}, added RTT {rtt} ms, exercise {exercise}, duration {duration}',flush=True);return
                await asyncio.sleep(0.1)
            raise RuntimeError('Server startup timed out')
        except asyncio.CancelledError:raise
        except (OSError,RuntimeError) as error:
            self.transport.sendto(f'ERROR|{token}|{error}'.encode('ascii',errors='replace')[:240],addr)
            await self.cleanup_session()
    async def close(self):
        if self.task is not None:
            self.task.cancel()
            with suppress(asyncio.CancelledError):await self.task
        await self.cleanup_session();self.transport.close()

def read_ini(path):
    data=path.read_bytes()
    if data.startswith((codecs.BOM_UTF16_LE,codecs.BOM_UTF16_BE)):return data.decode('utf-16')
    try:return data.decode('utf-8-sig')
    except UnicodeDecodeError:return data.decode('cp1252')

def prepare(root,offscreen):
    system=client=ucc=None
    for candidate in (root/'System64',root/'System'):
        game=next((candidate/n for n in ('UnrealTournament.exe','UnrealTournament64.exe','ut-bin-amd64','ut-bin','UnrealTournament') if (candidate/n).is_file()),None)
        server=next((candidate/n for n in ('ucc.exe','ucc64.exe','ucc-bin-amd64','ucc-bin','ucc') if (candidate/n).is_file()),None)
        if game is not None and server is not None:system,client,ucc=candidate,game,server;break
    if system is None:raise ValueError('UT99 client and UCC not found together in System / System64. Use a full UT99 469e test installation.')
    for name in ('UTAT.u','UTATNetLab.u','InstaGibPlus_11.u','InstaGibPlusAssets_v2.u'):
        if not any((d/name).is_file() for d in (system,root/'System')):raise ValueError('Missing System/'+name)
    if not (root/'Maps'/'DM-UTAT-Room.unr').is_file():raise ValueError('Missing Maps/DM-UTAT-Room.unr')
    source=next((d/name for name in ('UTATMenu.ini','UnrealTournament.ini','Default.ini') for d in (system,root/'System') if (d/name).is_file()),None)
    if source is None:raise ValueError('Missing UnrealTournament.ini / Default.ini')
    config='\n'.join(l for l in read_ini(source).splitlines() if not l.strip().lower().startswith(('serverpackages=','serveractors=')))
    config=config.replace('[Engine.GameEngine]','[Engine.GameEngine]\nServerPackages=UTAT\nServerPackages=UTATNetLab\nServerPackages=InstaGibPlus_11\nServerPackages=InstaGibPlusAssets_v2')
    if offscreen:
        config=config.replace('WinDrv.WindowsClient','SDLDrv.SDLClient')
        config+='\n[SDLDrv.SDLClient]\nStartupFullscreen=False\nWindowedViewportX=1280\nWindowedViewportY=720\n'
    (system/'UTATMenu.ini').write_text(config,encoding='utf-8-sig')
    (system/'UTATServer.ini').write_text(config,encoding='utf-8-sig')
    user=system/'UTATPracticeUser.ini'
    if not user.exists():
        original=next((d/'User.ini' for d in (system,root/'System') if (d/'User.ini').exists()),None)
        if original is not None:shutil.copyfile(original,user)
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    if offscreen:env.update(SDL_VIDEODRIVER='offscreen',LIBGL_ALWAYS_SOFTWARE='1')
    return system,client,ucc,env

async def run(a):
    system,client,ucc,env=prepare(a.ut_root.resolve(),a.offscreen)
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    service=MenuService(system,ucc,env,folder,1 if a.integration_check else 0)
    await asyncio.get_running_loop().create_datagram_endpoint(lambda:service,local_addr=('127.0.0.1',18778))
    process=None
    try:
        url='DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?OpenSetup=1'
        if a.integration_check:url+='?MenuNetworkTest=1'
        with (folder/'menu-client.log').open('w') as log:
            process=await asyncio.create_subprocess_exec(str(client),url,'-ini=UTATMenu.ini','-userini=UTATPracticeUser.ini','-nohomedir','-log','-FORCELOGFLUSH',*(['-windowed','-nosound'] if a.offscreen else []),cwd=system,env=env,stdout=log,stderr=subprocess.STDOUT)
            print('Aimtrainer helper ready. Choose environment, weapon and 0-300 ms inside UT.',flush=True)
            if a.integration_check:
                deadline=time.monotonic()+65
                while time.monotonic()<deadline and process.returncode is None:
                    engine=system/'UnrealTournament.log'
                    text=engine.read_text(errors='replace') if engine.exists() else ''
                    if 'MENUTEST DONE' in text:break
                    await asyncio.sleep(0.25)
                text=(system/'UnrealTournament.log').read_text(errors='replace')
                (folder/'menu-engine.log').write_text(text)
                lines=[l for l in text.splitlines() if any(tag in l for tag in ('MENUTEST ','ROUNDTEST '))]
                print('\n'.join(lines))
                if 'MENUTEST DONE failures=0' not in text or 'ROUNDTEST FAIL' in text:raise RuntimeError('Menu integration failed; see build/menu-engine.log')
            else:await process.wait()
    finally:
        await stop(process);await service.close()

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--offscreen',action='store_true');p.add_argument('--integration-check',action='store_true')
    a=p.parse_args()
    try:asyncio.run(run(a))
    except KeyboardInterrupt:print('Aimtrainer closed.')
    except (ValueError,RuntimeError,OSError) as error:p.exit(1,str(error)+'\n')
if __name__=='__main__':main()
