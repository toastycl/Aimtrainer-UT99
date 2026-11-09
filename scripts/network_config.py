"""WIP network session contract. Values are added RTT, never a claimed measured ping."""
from dataclasses import asdict, dataclass
import json

@dataclass(frozen=True)
class NetworkSession:
    weapon: str = 'Shock'
    added_rtt_ms: int = 100

    def __post_init__(self):
        if self.weapon not in ('Shock','Sniper'):
            raise ValueError('Weapon must be Shock or Sniper in this WIP')
        if type(self.added_rtt_ms) is not int or not 0 <= self.added_rtt_ms <= 2000:
            raise ValueError('Added RTT must be a whole number from 0 to 2000 ms')

    def url_options(self):
        return f'?LabWeapon={self.weapon}?AddedRTT={self.added_rtt_ms}'

    def to_json(self):
        return json.dumps({'schema':1,'environment':'IGPlus11-OldNet-WIP',**asdict(self)},indent=2)+'\n'
