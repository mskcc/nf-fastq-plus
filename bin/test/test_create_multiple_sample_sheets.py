#!/usr/bin/env python
import sys
import unittest
sys.path.append('..')
from create_multiple_sample_sheets import EXTENSIONS, DATA_SHEETS

class TestSplitSampleSheetConfig(unittest.TestCase):
    def test_unique_extensions(self):
        self.assertEquals(len(EXTENSIONS), len(list(set(EXTENSIONS))))

    def test_dataframes(self):
        self.assertEquals(len(EXTENSIONS), len(DATA_SHEETS))

if __name__ == '__main__':
    unittest.main()
