#!/usr/bin/env python3
"""WIP interactive IGPlus sandbox launcher. Choose any integer added RTT, not presets.
Requires a test UT99 install, the base mod/map and separately installed IGPlus 11.
"""
import argparse
from pathlib import Path
import subprocess
import sys
from network_config import NetworkSession
ROOT=Path(__file__).resolve().parents[1]

def choose_session(weapon=None,rtt_ms=None,read=input):
    if weapon is None:
        while True:
            value=read('Weapon [Shock / Sniper, default Shock]: ').strip().lower() or 'shock'
            if value in ('shock','sniper'):
                weapon=value.title();break
            print('Choose Shock or Sniper.')
    if weapon not in ('Shock','Sniper'):raise ValueError('Weapon must be Shock or Sniper in this WIP')
    if rtt_ms is None:
        while True:
            value=read('Added round-trip delay in ms [0..300, default 100]: ').strip() or '100'
            try:
                rtt_ms=int(value);NetworkSession(weapon,rtt_ms);break
            except ValueError:
                print('Enter a whole number from 0 to 300, for example 37, 85, 112 or 143.')
    return NetworkSession(weapon,rtt_ms)

def build_command(ut_root,session,offscreen=False):
    command=[sys.executable,str(ROOT/'scripts'/'net_smoke.py'),'--ut-root',str(ut_root),
             '--weapon',session.weapon,'--rtt-ms',str(session.added_rtt_ms),'--manual']
    if offscreen:command.append('--offscreen')
    return command

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--weapon',choices=['Shock','Sniper'])
    p.add_argument('--rtt-ms',type=int)
    p.add_argument('--offscreen',action='store_true')
    a=p.parse_args()
    try:session=choose_session(a.weapon,a.rtt_ms)
    except (EOFError,KeyboardInterrupt):raise SystemExit('WIP setup cancelled.')
    except ValueError as e:p.error(str(e))
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    (folder/'network-session.json').write_text(session.to_json(),encoding='utf-8')
    print(f'WIP sandbox | {session.weapon} | added RTT {session.added_rtt_ms} ms')
    print('This adds delay, not a guaranteed scoreboard ping. No timed rounds or accuracy yet.')
    print('Close the game to stop; choose a different value by running this launcher again.',flush=True)
    try:raise SystemExit(subprocess.call(build_command(a.ut_root,session,a.offscreen)))
    except KeyboardInterrupt:raise SystemExit('WIP setup stopped.')
if __name__=='__main__':main()
