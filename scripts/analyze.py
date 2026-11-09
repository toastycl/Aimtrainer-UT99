#!/usr/bin/env python3
"""Export UTAT RESULT records from a UT log. Incomplete runs never enter summaries."""
import argparse
import csv
import json
import math
from collections import defaultdict
from pathlib import Path
from statistics import mean, pstdev

REQUIRED = ('version','complete','protocol','exercise','sequence','duration','elapsed','shots','hits','mean_ms','map','anchor','yaw','input','sens','nosmooth','maxsmooth','threshold','fov','profile')
# Input remains unverified in alpha: do not infer backend from a profile name.
COHORT = ('protocol','weapon','unit','exercise','sequence','duration','map','anchor','yaw','fov')
CONFIG = ('profile','sens','nosmooth','maxsmooth','threshold','input')

def parse_result(line):
    if 'UTAT: RESULT|' not in line:
        return None
    body = line.split('UTAT: RESULT|', 1)[1].strip()
    row = dict(piece.split('=',1) for piece in body.split('|') if '=' in piece)
    missing = set(REQUIRED)-row.keys()
    if missing:
        raise ValueError('Missing fields: '+', '.join(sorted(missing)))
    if row['version'] not in ('1','2') or row['complete'].lower() not in ('true','false'):
        raise ValueError('Unsupported version or completion flag')
    if row['version']=='2' and not {'weapon','unit','kills','damage'}.issubset(row):
        raise ValueError('Version 2 needs weapon, unit, kills and damage')
    row.setdefault('weapon','Shock Rifle')
    row.setdefault('unit','trace')
    row.setdefault('kills','0')
    row.setdefault('damage','0')
    values = {key:float(row[key]) for key in ('elapsed','shots','hits','mean_ms','duration','sens','threshold','fov','kills','damage')}
    if not all(math.isfinite(v) for v in values.values()):
        raise ValueError('Non-finite result')
    if not (0 <= values['hits'] <= values['shots']) or min(values.values()) < 0:
        raise ValueError('Invalid counters or negative values')
    if not values['kills'].is_integer() or not values['shots'].is_integer() or not values['hits'].is_integer() or values['duration'] < 0 or (row['version']=='1' and values['duration']==0):
        raise ValueError('Invalid counters or duration')
    if row['complete'].lower() == 'true' and values['duration']>0 and abs(values['elapsed']-values['duration']) > 0.1:
        raise ValueError('Completed result has an inconsistent duration')
    row['accuracy_pct'] = 100*values['hits']/values['shots'] if values['shots'] else 0
    row['hits_per_minute'] = 60*values['hits']/values['elapsed'] if values['elapsed'] else 0
    # No hit is a missing time measurement, never zero-ms performance.
    row['time_to_hit_ms'] = values['mean_ms'] if values['hits'] and row['version']=='1' else None
    return row

def summarize(rows):
    groups=defaultdict(list)
    for row in rows:
        if row['complete'].lower() == 'true':
            groups[tuple(row[k] for k in COHORT+CONFIG)].append(row)
    result=[]
    for key, group in groups.items():
        times=[r['time_to_hit_ms'] for r in group if r['time_to_hit_ms'] is not None]
        result.append(dict(zip(COHORT+CONFIG,key), rounds=len(group),
            accuracy_mean=mean(r['accuracy_pct'] for r in group),
            accuracy_sd=pstdev(r['accuracy_pct'] for r in group),
            hits_per_minute_mean=mean(r['hits_per_minute'] for r in group),
            time_to_hit_ms_mean=mean(times) if times else None))
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('log',type=Path)
    p.add_argument('--out',type=Path,default=Path('results'))
    a=p.parse_args(); rows=[]
    for number,line in enumerate(a.log.read_text(encoding='utf-8-sig',errors='replace').splitlines(),1):
        try:
            row=parse_result(line)
        except (ValueError,KeyError) as e:
            p.error(f'Invalid UTAT record on line {number}: {e}')
        if row: rows.append(row)
    if not rows: p.error('No UTAT result records found')
    a.out.mkdir(parents=True,exist_ok=True)
    with (a.out/'sessions.csv').open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=list(REQUIRED)+['weapon','unit','kills','damage','accuracy_pct','hits_per_minute','time_to_hit_ms'])
        writer.writeheader();writer.writerows({k:r[k] for k in writer.fieldnames} for r in rows)
    (a.out/'summary.json').write_text(json.dumps({'warning':'Input backend unverified; times are game-clock measurements, not hardware latency. Compare repeated sessions, not single rounds.','groups':summarize(rows)},indent=2),encoding='utf-8')
    print(f'Exported {len(rows)} sessions. Completed rounds only in summary.')
if __name__=='__main__':main()
