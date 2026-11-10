#!/usr/bin/env python3
"""Package project binaries, map and the standard-library menu helper; no IGPlus binaries."""
import argparse
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--ut-root',type=Path,required=True);a=p.parse_args()
    root=a.ut_root.resolve()
    def binary(name):
        found=next((d/name for d in (root/'System64',root/'System') if (d/name).is_file()),None)
        if found is None:p.error('Build first: missing '+name)
        return found
    dist=ROOT/'dist';dist.mkdir(exist_ok=True);target=dist/'UTAT-dev-0.4.0.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as z:
        z.write(binary('UTAT.u'),'System/UTAT.u');z.write(binary('UTATNetLab.u'),'System/UTATNetLab.u')
        z.write(ROOT/'System'/'UTAT.int','System/UTAT.int')
        z.write(root/'Maps'/'DM-UTAT-Room.unr','Maps/DM-UTAT-Room.unr')
        for name in ('start_aimtrainer.py','network_config.py','net_relay.py'):z.write(ROOT/'scripts'/name,'tools/'+name)
        for name in ('Start-Aimtrainer.cmd','Start-Aimtrainer.sh'):z.write(ROOT/'launchers'/name,name)
        z.write(ROOT/'docs'/'QUICKSTART_ES.md','LEEME.md')
        for document in ('QUICKSTART_ES.md','VALIDATION.md','DELIVERY_CHECK.md','INTEGRATION_SMOKE.md','CLIENT_SMOKE.md','ENGINE_SMOKE.md','ENTREGA_0.4.0_ES.md'):
            z.write(ROOT/'docs'/document,'docs/'+document)
    print(target)
if __name__=='__main__':main()
