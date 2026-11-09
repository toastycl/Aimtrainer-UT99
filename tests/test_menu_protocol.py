from pathlib import Path
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from start_aimtrainer import parse_request,WEAPONS
class MenuProtocol(unittest.TestCase):
    def test_all_weapons_and_latency_boundaries(self):
        for weapon in WEAPONS:
            for rtt in (0,37,85,143,300):
                self.assertEqual(parse_request(f'START|123|{weapon}|{rtt}|1|30'),('123',weapon,rtt,1,30))
    def test_malformed_and_out_of_range_requests(self):
        for request in ('START|123|Shock|301|0|30','START|123|Shock|-1|0|30','START|123|Shock|85.5|0|30','START|x|Shock|85|0|30','START|123|Unknown|85|0|30','START|123|Shock|85|2|30','START|123|Shock|85|0|15','START|123|Shock|85|0|30|extra'):
            with self.subTest(request=request),self.assertRaises(ValueError):parse_request(request)

class IniEncoding(unittest.TestCase):
    def test_preserves_unicode_practice_settings(self):
        import tempfile
        from start_aimtrainer import read_ini
        text='[User]\nName=Café\n'
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder)/'user.ini'
            for encoding in ('utf-8-sig','utf-16','cp1252'):
                path.write_bytes(text.encode(encoding));self.assertEqual(read_ini(path),text)

class InstallationDiscovery(unittest.TestCase):
    def test_falls_back_to_complete_system_if_system64_is_incomplete(self):
        import tempfile
        from start_aimtrainer import prepare
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder);(root/'System64').mkdir();system=root/'System';system.mkdir();(root/'Maps').mkdir()
            for name in ('UnrealTournament.exe','ucc.exe','UTAT.u','UTATNetLab.u','InstaGibPlus_11.u','InstaGibPlusAssets_v2.u'):(system/name).touch()
            (root/'Maps'/'DM-UTAT-Room.unr').touch()
            (system/'Default.ini').write_text('[Engine.GameEngine]\n')
            self.assertEqual(prepare(root,False)[0],system)
