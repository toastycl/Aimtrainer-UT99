import json
from pathlib import Path
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from network_config import NetworkSession
from network_lab import choose_session,build_command

class SelectableLatency(unittest.TestCase):
    def test_arbitrary_values_survive_prompt_manifest_and_launch(self):
        for value in (0,37,85,112,143,2000):
            with self.subTest(value=value):
                answers=iter(['sniper',str(value)])
                session=choose_session(read=lambda prompt:next(answers))
                self.assertEqual(session.weapon,'Sniper')
                self.assertEqual(json.loads(session.to_json())['added_rtt_ms'],value)
                command=build_command(Path('/test-ut'),session)
                self.assertEqual(command[command.index('--rtt-ms')+1],str(value))
                self.assertIn('--manual',command)
                self.assertEqual(session.url_options(),f'?LabWeapon=Sniper?AddedRTT={value}')
    def test_invalid_values_cannot_be_saved_or_launched(self):
        for value in (-1,2001,True,85.5,'85',float('nan')):
            with self.subTest(value=value),self.assertRaises(ValueError):NetworkSession('Shock',value)
        with self.assertRaises(ValueError):NetworkSession('Rocket',100)
    def test_invalid_prompt_retries_without_silently_using_a_preset(self):
        answers=iter(['Shock','-1','abc','2001','85'])
        self.assertEqual(choose_session(read=lambda prompt:next(answers)).added_rtt_ms,85)
