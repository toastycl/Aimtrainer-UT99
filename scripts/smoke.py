#!/usr/bin/env python3
"""Run opt-in map/weapon/session checks in an isolated dedicated UT engine (no UI)."""
import argparse
import os
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ut-root',type=Path,required=True)
    p.add_argument('--system',default='System64')
    a=p.parse_args();system=a.ut_root.resolve()/a.system
    compiler=next((system/n for n in ['ucc.exe','ucc-bin-amd64','ucc-bin','ucc'] if (system/n).is_file()),None)
    if compiler is None:p.error('Compiler not found')
    ini=system/'UTATMapBuild.ini'
    if not ini.is_file():p.error('Build with scripts/build.py first')
    # No uplinks/web actors or unrelated game package dependencies in the isolated test.
    text='\n'.join(l for l in ini.read_text(encoding='utf-8-sig').splitlines() if not l.startswith(('ServerPackages=','ServerActors=')))
    (system/'UTATSmoke.ini').write_text(text,encoding='utf-8')
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    cmd=[str(compiler),'server','DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0?SmokeTest=1','-ini=UTATSmoke.ini','-userini=UTATSmokeUser.ini','-nohomedir','-nosound','-lanplay','-port=17877','-multihome=127.0.0.1']
    try:run=subprocess.run(cmd,cwd=system,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=50)
    except subprocess.TimeoutExpired:p.error('Engine smoke test exceeded 50 seconds')
    output=run.stdout.decode('utf-8',errors='replace')
    folder=ROOT/'build';folder.mkdir(exist_ok=True)
    (folder/'smoke-console.log').write_text(output,encoding='utf-8')
    if (system/'ucc.log').exists():
        (folder/'smoke-engine.log').write_bytes((system/'ucc.log').read_bytes())
    checks=[line for line in output.splitlines() if line.startswith(('PASS ','FAIL ','DONE '))]
    print('\n'.join(checks))
    if run.returncode or 'DONE failures=0' not in output or any(line.startswith('FAIL ') for line in checks):
        raise SystemExit('Engine smoke test failed; see build/smoke-console.log')
    print('Engine checks passed. Rendered menu and real mouse input remain untested.')
if __name__=='__main__':main()
