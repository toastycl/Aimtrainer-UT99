#!/usr/bin/env python3
"""Build the optional experiment; IGPlus 11 is a separate runtime dependency."""
import argparse, os, shutil, subprocess, zipfile
from pathlib import Path
from build import build_ini, REPO

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True);a=p.parse_args()
    root=a.ut_root.resolve()
    compiler=next((d/n for d in (root/'System64',root/'System') for n in ('ucc.exe','ucc64.exe','ucc-bin-amd64','ucc-bin','ucc') if (d/n).is_file()),None)
    if compiler is None:p.error('UCC not found')
    system=compiler.parent
    for name in ('InstaGibPlus_11.u','InstaGibPlusAssets_v2.u'):
        if not any((d/name).is_file() for d in (system,root/'System')):p.error('Install official IGPlus 11 first: missing '+name)
    (REPO/'build').mkdir(exist_ok=True)
    shutil.copytree(REPO/'UTATNetLab',root/'UTATNetLab',dirs_exist_ok=True)
    defaults=system/'Default.ini'
    if not defaults.exists():defaults=root/'System'/'Default.ini'
    ini=build_ini(defaults.read_text(encoding='utf-8-sig')).replace('EditPackages=UTAT','EditPackages=UTAT\nEditPackages=InstaGibPlus_11\nEditPackages=UTATNetLab')
    (system/'UTATNetBuild.ini').write_text(ini)
    for d in (system,root/'System'):(d/'UTATNetLab.u').unlink(missing_ok=True)
    env=os.environ.copy();env['LD_LIBRARY_PATH']=str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    r=subprocess.run([str(compiler),'make','-ini=UTATNetBuild.ini','-nohomedir','-silent'],cwd=system,env=env,capture_output=True,text=True)
    (REPO/'build'/'net-compile.log').write_text(r.stdout+r.stderr);print(r.stdout+r.stderr)
    if r.returncode or '0 error' not in r.stdout.lower():raise SystemExit('Network lab compilation failed')
    binary=next(d/'UTATNetLab.u' for d in (system,root/'System') if (d/'UTATNetLab.u').is_file())
    dist=REPO/'dist';dist.mkdir(exist_ok=True)
    target=dist/'UTAT-network-lab-WIP.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as z:
        z.write(binary,'System/UTATNetLab.u')
        z.write(REPO/'docs'/'NETWORK_LAB.md','NETWORK_LAB.md')
        z.write(REPO/'docs'/'WIP_SELECTABLE_PING.md','WIP_SELECTABLE_PING.md')
        z.write(REPO/'docs'/'WIP_NETWORK_CHECKS.md','WIP_NETWORK_CHECKS.md')
    print('Built',target)
if __name__=='__main__':main()
