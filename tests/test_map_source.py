from pathlib import Path
import re
import unittest

class RoomGeometry(unittest.TestCase):
    def test_subtractive_brush_has_consistent_outward_winding(self):
        text=(Path(__file__).resolve().parents[1]/'maps'/'DM-UTAT-Room.t3d').read_text()
        polygons=re.findall(r'Begin Polygon(.*?)End Polygon',text,re.S)
        self.assertEqual(len(polygons),6)
        for poly in polygons:
            def vector(s): return tuple(float(x) for x in s.split(','))
            n=vector(re.search(r'Normal\s+([^\n]+)',poly)[1])
            vertices=[vector(x) for x in re.findall(r'Vertex\s+([^\n]+)',poly)]
            a=tuple(vertices[1][i]-vertices[0][i] for i in range(3))
            b=tuple(vertices[2][i]-vertices[0][i] for i in range(3))
            cross=(a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
            self.assertGreater(sum(cross[i]*n[i] for i in range(3)),0)
            # The center must lie behind every outward-facing room plane.
            center=(0,0,384)
            self.assertLess(sum((center[i]-vertices[0][i])*n[i] for i in range(3)),0)
