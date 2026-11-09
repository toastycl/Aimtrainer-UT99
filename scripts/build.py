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
        target = dist/'UTAT-alpha-0.1.0.zip'
        with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
            z.write(binary, 'System/UTAT.u')
            z.write(REPO/'System'/'UTAT.int', 'System/UTAT.int')
            z.write(REPO/'docs'/'QUICKSTART_ES.md', 'LEEME.md')
        print('Built',target)
    except BaseException:
        for path, backup in previous:
            shutil.copy2(backup,path)
        raise

if __name__ == '__main__':
    main()
