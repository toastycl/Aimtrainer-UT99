import sys
from pathlib import Path
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from analyze import parse_result, summarize
from build import build_ini

BASE='UTAT: RESULT|version=1|complete=True|protocol=shock-primary-v1|exercise=0|sequence=1|duration=60|elapsed=60|shots=10|hits=7|mean_ms=570|map=DM-Test|anchor=0,0,0|yaw=0|input=unverified|profile=0|sens=2|nosmooth=True|maxsmooth=False|threshold=0.07|fov=90'
class Results(unittest.TestCase):
    def test_metrics(self):
        r=parse_result(BASE);self.assertEqual(r['accuracy_pct'],70);self.assertEqual(r['hits_per_minute'],7)
    def test_no_hits_has_no_time(self):
        r=parse_result(BASE.replace('shots=10|hits=7','shots=0|hits=0'))
        self.assertEqual(r['accuracy_pct'],0);self.assertIsNone(r['time_to_hit_ms'])
    def test_incomplete_excluded(self):
        self.assertEqual(summarize([parse_result(BASE.replace('complete=True','complete=False'))]),[])
    def test_reject_impossible_and_nonfinite(self):
        for edit in [('hits=7','hits=11'),('elapsed=60','elapsed=nan'),('elapsed=60','elapsed=10'),('shots=10','shots=10.5')]:
            with self.subTest(edit=edit),self.assertRaises(ValueError):parse_result(BASE.replace(*edit))
    def test_separate_scenarios_and_configuration(self):
        rows=[parse_result(s) for s in [BASE,BASE,BASE.replace('fov=90','fov=100'),BASE.replace('sens=2','sens=1.8'),BASE.replace('anchor=0,0,0','anchor=10,0,0')]]
        groups=summarize(rows);self.assertEqual(len(groups),4);self.assertEqual(groups[0]['rounds'],2)
    def test_unrelated_log_ignored(self):self.assertIsNone(parse_result('Log: RESULT|shots=0'))
    def test_build_does_not_retain_unrelated_mods(self):
        s=build_ini('[Editor.EditorEngine]\nEditPackages=OtherMod\nFoo=Bar\n')
        self.assertNotIn('OtherMod',s);self.assertIn('EditPackages=UTAT',s);self.assertIn('Foo=Bar',s)

class VersionTwo(unittest.TestCase):
    def row(self, **changes):
        s=BASE.replace('version=1','version=2')+'|weapon=Flak Cannon|unit=fragment|kills=1|damage=100'
        for k,v in changes.items():
            import re
            s=re.sub(r'(?<=\|)'+k+r'=[^|]*',k+'='+str(v),s)
        return s
    def test_free_practice(self):
        row=parse_result(self.row(duration=0,elapsed=12))
        self.assertIsNone(row['time_to_hit_ms'])
        self.assertEqual(row['hits_per_minute'],35)
    def test_weapon_groups_separate(self):
        a=parse_result(self.row()); b=parse_result(self.row(weapon='Rocket Launcher',unit='projectile'))
        self.assertEqual(len(summarize([a,b])),2)
    def test_requires_weapon_metadata(self):
        with self.assertRaises(ValueError):parse_result(BASE.replace('version=1','version=2'))

    def test_reject_bad_damage_or_elimination_counts(self):
        for changes in [{'kills': -1}, {'kills': 1.5}, {'damage': 'nan'}]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                parse_result(self.row(**changes))

if __name__=='__main__':unittest.main()

class NativeAndBeam(unittest.TestCase):
    def test_native_warning_prefix_is_imported(self):
        row=parse_result(BASE.replace('UTAT: ','Warning: '))
        self.assertEqual(row['accuracy_pct'],70)
    def test_beam_only_round_has_contact_metric_not_zero_shot_accuracy(self):
        record=BASE.replace('version=1','version=2').replace('shots=10|hits=7','shots=0|hits=0')+'|weapon=Pulse|unit=beam-time|kills=0|damage=50|beam_active=10|beam_contact=8'
        row=parse_result(record)
        self.assertEqual(row['beam_contact_pct'],80)
        self.assertIsNone(row['accuracy_pct'])
        summary=summarize([row])[0]
        self.assertIsNone(summary['accuracy_mean']);self.assertEqual(summary['beam_contact_mean'],80)
        with self.assertRaises(ValueError):parse_result(record.replace('beam_contact=8','beam_contact=11'))

class TrainingConditions(unittest.TestCase):
    def test_history_exports_keep_geometry_and_fire_style_separate(self):
        variants=[BASE,BASE+'|distance=1',BASE+'|size=1',BASE+'|fire_style=2']
        self.assertEqual(len(summarize([parse_result(v) for v in variants])),4)
    def test_legacy_geometry_defaults_and_invalid_values(self):
        row=parse_result(BASE)
        self.assertEqual((row['distance'],row['size'],row['fire_style']),('0','0','unknown'))
        for extra in ('|distance=9','|size=-1','|fire_style=primary'):
            with self.subTest(extra=extra),self.assertRaises(ValueError):parse_result(BASE+extra)
