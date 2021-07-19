#!/usr/bin/env python

import sys
import os
import json
import unittest
import mock
from unittest.mock import patch
from requests.models import Response

# Configurations
sys.path.insert(0, os.path.abspath("data"))
from mock_getProjectQc import MOCK_RESP
sys.path.append(os.path.abspath('..'))
from retrieve_failed_samples import retrieve_failed_sample_list

class TestSetupStats(unittest.TestCase):
    def mocked_request_get(*args, **kwargs):
        response = Response()
        response.status_code = 200
        response._content = str.encode(json.dumps(MOCK_RESP))
        return response

    @mock.patch('requests.get', side_effect=mocked_request_get)
    def test_filters_out_successful_samples(self, mock_get):
        failed_sample_list = retrieve_failed_sample_list("05240_W", "PITT_0406_BHC5G7BBXY")
        self.assertEqual(len(failed_sample_list), 0)

    @mock.patch('requests.get', side_effect=mocked_request_get)
    def test_finds_failed_samples(self, mock_get):
        failed_sample_list = retrieve_failed_sample_list("05240_W", "PITT_0415_BHFGNVBBXY")
        self.assertEqual(len(failed_sample_list), 4)
        self.assertEqual("05240_W_3" in failed_sample_list, True)
        self.assertEqual("05240_W_5" in failed_sample_list, True)
        self.assertEqual("05240_W_6" in failed_sample_list, True)
        self.assertEqual("05240_W_7" in failed_sample_list, True)

    @mock.patch('requests.get', side_effect=mocked_request_get)
    def test_finds_failed_samples(self, mock_get):
        failed_sample_list = retrieve_failed_sample_list("05240_W", "PITT_0415_BHFGNVBBXY")
        self.assertEqual(len(failed_sample_list), 4)
        self.assertEqual("05240_W_3" in failed_sample_list, True)
        self.assertEqual("05240_W_5" in failed_sample_list, True)
        self.assertEqual("05240_W_6" in failed_sample_list, True)
        self.assertEqual("05240_W_7" in failed_sample_list, True)

    @mock.patch('requests.get', side_effect=mocked_request_get)
    def test_filters_on_exact_sample_name(self, mock_get):
        failed_sample_list = retrieve_failed_sample_list("05240_W", "JAX_0374_BHFFHMBBXY_A1")
        self.assertEqual(len(failed_sample_list), 5)

        failed_sample_list = retrieve_failed_sample_list("05240_W", "JAX_0374_BHFFHMBBXY")
        self.assertEqual(len(failed_sample_list), 0)

if __name__ == '__main__':
    unittest.main()
