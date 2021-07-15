#!/usr/bin/env python
"""Retrieves a newline separated list of samples for a request on a given run that have failed their Data QC

Args:
    run (--r), string:   Name of the sequencing run  (e.g. DIANA_0389_AHFL53DRXY)
    project (--p), str:  Name of the project/request (e.g. 12133)
Usage: python retrieve_failed_samples.py -r ${RUN_NAME} -p ${PROJECT}
"""

import json
import os
import re
import sys
import requests

import config

HELP_CMD = "python retrieve_failed_samples.py --r=${RUN_NAME} --p=${PROJECT} (--n=${FILE_NAME})"
LIMS_HOST = config.LIMS_HOST_PROD

def fail(err_msg = None):
    """ Exits Application and logs error message """
    print("Usage is %s" % HELP_CMD)
    if(err_msg):
        print("ERROR: " + err_msg)
    sys.exit(1)

def retrieve_failed_sample_list(prj, run):
    url = LIMS_HOST
    url = "https://%s/LimsRest/getProjectQc?project=%s" % (LIMS_HOST, prj)
    print("Retrieving Project QC Data: %s" % url)

    try:
        resp = requests.get(url, auth=(config.LIMS_USER, config.LIMS_PASSWORD), verify=False)
    except:
        print("Request Failed: %s" % url)
        return []

    """
    content = [
       {
          "samples":[
             {
                "baseId": IGO_ID,       e.g. "05240_W_6"
                ...
                "qc":{
                   "qcStatus": STATUS   e.g. "IGO-Complete"", ""Failed",
                   "run": RUN_ID        e.g. "PITT_0406_BHC5G7BBXY"
                   ...
                }
             }
          ]
       }
    ]
    """
    content = json.loads(resp.content)
    if (resp.status_code != 200 or len(content) == 0):
        # Warning
        print("getProjectQc failed to return data: %s. Service Response: %s" % (url, resp.status_code))
        return []

    failed_samples = set()
    samples = content[0]["samples"]
    for sample in samples:
        igo_id = sample["baseId"]
        qc = sample.get("qc", {})
        status = qc["qcStatus"]
        runId = qc["run"]
        if "failed" in status.lower() and run == runId:
            print("FOUND FAILED - run=%s prj=%s status=%s" % (runId, prj, status))
            failed_samples.add(igo_id)

    failed_samples_list = list(failed_samples)

    return failed_samples_list

def write_failed_sample_list(file_name, failed_sample_list):
    """ Writes @contents to @failed_sample_list
    :param failed_sample_list: str[]
    :return: None
    """
    failed_sample_list_file = open(file_name, "a")
    failed_sample_list_file.truncate(0)  # Delete any old data
    contents = "\n".join(failed_sample_list)
    failed_sample_list_file.write(contents)
    failed_sample_list_file.close()

def main():
    if len(sys.argv) < 3:
        fail("Missing RUN_NAME/PROJECT options")

    inputs = sys.argv[1:]

    run = None
    prj = None
    file_name = None
    opts = [ arg.lower() for arg in inputs if arg[0:2] == "--"]
    for opt in opts:
        opt_kv = opt[2:]
        if "=" in opt_kv:
            k,v = opt_kv.split('=')
            if k == 'r':
                run = v
            elif k == 'p':
                prj = v
            elif k == 'n':
                file_name = v
            else:
                print("Could not parse option: %s" % opt_kv)
    if not run or not prj:
        fail("Could not parse RUN_NAME & PROJECT")

    if not file_name:
        file_name = "failed_samples_%s_%s" % (upper_run, upper_prj)

    upper_run = run.upper()
    upper_prj = prj.upper()
    failed_samples = retrieve_failed_sample_list(upper_prj, upper_run)
    write_failed_sample_list(file_name, failed_samples)
    print("Wrote File: %s" % file_name)

if __name__ == '__main__':
    main()
