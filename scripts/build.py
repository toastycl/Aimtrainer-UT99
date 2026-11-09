#!/usr/bin/env python3
"""Compile against an existing UT99 installation without editing its user ini."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

REPO = Path(__file__).resolve().parents[1]
PACKAGES = ('Core', 'Engine', 'Fire', 'Editor', 'UWindow', 'UnrealShare', 'UnrealI', 'UMenu', 'Botpack', 'UTAT')

def build_ini(text):
    lines = [line for line in text.splitlines() if not line.strip().lower().startswith('editpackages=')]
    index = next((i for i, line in enumerate(lines) if line.strip().lower() == '[editor.editorengine]'), None)
    if index is None:
        raise ValueError('Default.ini has no [Editor.EditorEngine] section')
    lines[index+1:index+1] = ['EditPackages='+p for p in PACKAGES]
    return '\n'.join(lines)+'\n'

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ut-root', type=Path, required=True)
    p.add_argument('--system', help='System, System64, or another compiler directory relative to UT root')
    args = p.parse_args()
    root = args.ut_root.resolve()
    folders = [root/args.system] if args.system else [root/'System64', root/'System']
    compiler = next((d/n for d in folders for n in ('ucc.exe', 'ucc-bin-amd64', 'ucc-bin', 'ucc') if (d/n).is_file()), None)
    if compiler is None:
        p.error('UCC not found; pass --system for your compiler directory')
    system = compiler.parent
    defaults = system/'Default.ini'
    if not defaults.is_file():
        defaults = root/'System'/'Default.ini'
    if not defaults.is_file():
        p.error('Default.ini not found in the installation')
    shutil.copytree(REPO/'UTAT', root/'UTAT', dirs_exist_ok=True)
    (system/'UTATBuild.ini').write_text(build_ini(defaults.read_text(encoding='utf-8-sig')), encoding='utf-8')
    work = REPO/'build'; work.mkdir(exist_ok=True)
    previous = []
    for i, path in enumerate(dict.fromkeys([root/'System'/'UTAT.u',system/'UTAT.u'])):
        if path.exists():
            backup = work/f'UTAT.previous.{i}.u'; shutil.copy2(path, backup)
            previous.append((path, backup)); path.unlink()
    env = os.environ.copy()
    env['LD_LIBRARY_PATH'] = str(system)+os.pathsep+env.get('LD_LIBRARY_PATH','')
    try:
        run = subprocess.run([str(compiler), 'make', '-ini=UTATBuild.ini', '-nohomedir', '-silent'], cwd=system, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = run.stdout.decode('utf-8', errors='replace')
        (work/'compile.log').write_text(output, encoding='utf-8'); print(output)
        binary = next((f for f in [root/'System'/'UTAT.u', system/'UTAT.u'] if f.is_file()), None)
        if run.returncode or binary is None or '0 error' not in output.lower():
            raise RuntimeError('Compilation did not report zero errors and produce UTAT.u. See build/compile.log')
        dist = REPO/'dist'; dist.mkdir(exist_ok=True)
        # Compile a real .unr from the included T3D source using UCC's editor commandlet.
        (root/'Maps').mkdir(exist_ok=True)
        room = root/'Maps'/'DM-UTAT-Room.unr'
        map_ini = build_ini(defaults.read_text(encoding='utf-8-sig'))
        if sys.platform != 'win32':
            map_ini = map_ini.replace('WinDrv.WindowsClient', 'SDLDrv.SDLClient')
        (system/'UTATMapBuild.ini').write_text(map_ini, encoding='utf-8')
        commands = system/'UTATMapBuild.exec'
        commands.write_text('MAP NEW\nMAP IMPORT FILE="'+str(REPO/'maps'/'DM-UTAT-Room.t3d')+'"\nMAP REBUILD\nMAP SAVE FILE="'+str(room)+'"\n', encoding='utf-8')
        env.setdefault('SDL_VIDEODRIVER','dummy')
        mapped = subprocess.run([str(compiler),'exec',str(commands),'-ini=UTATMapBuild.ini','-nohomedir','-silent','-nosound'], cwd=system, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        map_output=mapped.stdout.decode('utf-8',errors='replace')
        (work/'map-build.log').write_text(map_output,encoding='utf-8')
        print(map_output)
        if mapped.returncode or not room.is_file() or '0 error' not in map_output.lower() or 'Polys: 6 -> 6' not in map_output:
            raise RuntimeError('Training map did not build successfully. See build/map-build.log')
        target = dist/'UTAT-alpha-0.4.0.zip'
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
            z.write(binary, 'System/UTAT.u')
            z.write(room, 'Maps/DM-UTAT-Room.unr')
            z.write(REPO/'System'/'UTAT.int', 'System/UTAT.int')
            z.write(REPO/'docs'/'QUICKSTART_ES.md', 'LEEME.md')
        print('Built',target)
    except BaseException:
        for path, backup in previous:
            shutil.copy2(backup,path)
        raise

if __name__ == '__main__':
    main()
