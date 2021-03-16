import unittest
import sys
sys.path.append('..')
from detect_barcode_collision import main

class TestSetupStats(unittest.TestCase):
    def test_collision_on_single(self):
        self.assertRaises(Exception, main, ['-s', 'data/samplesheet_fail_single.csv', '-m', '1'])
        self.assertEquals(main(['-s', 'data/samplesheet_fail_single.csv', '-m', '0']), None)

    def test_collision_on_dual_fail(self):
        self.assertRaises(Exception, main, ['-s', 'data/samplesheet_fail_dual.csv', '-m', '1'])
        self.assertEquals(main(['-s', 'data/samplesheet_fail_dual.csv', '-m', '0']), None)

    def test_collision_on_dual_success(self):
        self.assertEquals(main(['-s', 'data/samplesheet_success_dual.csv', '-m', '0']), None)

if __name__ == '__main__':
    unittest.main()
