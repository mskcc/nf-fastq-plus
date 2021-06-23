#!/usr/bin/env python

import json
import os
import re
import sys
import requests

import config

MAPPED_FIELDS = ["cmoPatientId", "tumorOrNormal"]  # These will be joined in the bam. Order matters

# Delimiter for BAM name. Each field in the name can be parsed out on this unique string
BAM_DELIMITER = "___"
igoId_to_correctedCmoPatientId_map = {
    # { IGO_ID -> CORRECTED }
}
sample_id_manifests = {
    # IGO_ID -> { "igoId": IGO_ID, "cmoPatientId": {CMO_PATIENT_ID}, "tumorOrNormal": {"Tumor"/"Normal"} }
    "05841_N_1007": {
        "igoId": "05841_N_1007",
        "sampleName": "05841_N_1007",
        "cmoPatientId": "",     # We want this to be blank because we don't want the same name as the "05841_N_7" sample
        "tumorOrNormal": "Tumor"
    },
    "06457_E_10013": {
        "igoId": "06457_E_10013",
        "sampleName": "06457_E_10013",
        "cmoPatientId": "",     # We want this to be blank because we don't want the same name as the real sample
        "tumorOrNormal": "Tumor"
    },
    "09641_Z_10040": {
        "igoId": "09641_Z_10040",
        "sampleName": "09641_Z_10040",
        "cmoPatientId": "",     # We want this to be blank because we don't want the same name as the real sample
        "tumorOrNormal": "Tumor"
    },
    "09641_Z_10056": {
        "igoId": "09641_Z_10056",
        "sampleName": "09641_Z_10056",
        "cmoPatientId": "",     # We want this to be blank because we don't want the same name as the real sample
        "tumorOrNormal": "Tumor"
    },
    "09641_Z_10083": {
        "igoId": "09641_Z_10083",
        "sampleName": "09641_Z_10083",
        "cmoPatientId": "",     # We want this to be blank because we don't want the same name as the real sample
        "tumorOrNormal": "Tumor"
    }
}

def fail(err_msg = None):
    """ Exits Application and logs error message """
    print("Usage is 'python ./create_merge_commands ${FILE_TO_WRITE_COMMANDS} ${DIR_TO_WRITE_BAMS} [-options] ${BAM_FILES}'")
    if(err_msg):
        print("ERROR: " + err_msg)
    sys.exit(1)

def get_project_id(file_name):
    """ Extracts project ID from intput BAM filename.

    :param file_name: string 	e.g. "/PITT_0452_AHG2THBBXY_A1___P10344_C___13_cf_IGO_10344_C_20___hg19___MD.bam"
    :return: string				e.g. "P10344_C"
    """
    regex = "(?<=___)P[0-9]{5}[_A-Z,a-z]*(?=___)"  # Valid project ID is "P" + 5 numbers + (optional) [ "_" + 2 letters]
    matches = re.findall(regex, file_name)
    if len(matches) == 0:
        print("ERROR: Could not find IGO ID in filename: %s with regex: \"%s\"" % (file_name, regex))
        sys.exit(1)
    if len(matches) > 1:
        print("WARNING: More than one match: %s" % str(matches))

    return matches[0]

def get_igo_id(file_name):
    """ Extracts IGO ID from intput BAM filename.

    :param file_name: string 	e.g. "/PITT_0452_AHG2THBBXY_A1___P10344_C___13_cf_IGO_10344_C_20___hg19___MD.bam"
    :return: string				e.g. "10344_C"
    """
    regex = "IGO_([a-zA-Z0-9_.-]*?)___"
    matches = re.findall(regex, file_name)
    if len(matches) == 0:
        print("ERROR: Could not find IGO ID in filename: %s with regex: \"%s\"" % (file_name, regex))
        sys.exit(1)
    if len(matches) > 1:
        print("WARNING: More than one match: %s" % str(matches))

    return matches[0]


def get_sample_manifests(igo_ids, lims_host):
    """ Retrieves list of metadata (manifest) for the given IGO ID

    :param igo_ids: string[] List of target IGO IDs
    :return:
    """

    max_query = 10  # Maximum number of IDs that can be queried at one time
    idx = 0

    print("Retrieving sample manifests from %d igo_ids (max_query: %d)" % (len(igo_ids), max_query))

    sample_manifests = []
    while len(igo_ids) > idx:
        query_min = idx
        query_max = idx + max_query
        query_list = igo_ids[query_min:query_max]
        params = "igoSampleId=%s" % "&igoSampleId=".join(query_list)

        url = "https://%s/LimsRest/api/getSampleManifest?%s" % (lims_host, params)
        print("Retrieving manifests from samples [%d,%d): %s" % (query_min, query_max, ", ".join(query_list)))

        try:
            resp = requests.get(url, auth=(config.LIMS_USER, config.LIMS_PASSWORD), verify=False)
        except:
            print("Request Failed: %s" % url)
            return [ { id: '' } for id in igo_ids  ] # We need to return a list of mappings, even if empty
        content = json.loads(resp.content)
        if (resp.status_code != 200 or len(content) == 0):
            # Warning
            print("getSampleManifest failed to return data for IGO IDs: %s. Service Response: %s" %
                  (str(query_list), resp.status_code))

        # returned order of manifests should be the same as @query_list
        for resp_idx in range(len(query_list)):
            igo_id = query_list[resp_idx]
            manifest = content[resp_idx]
            if is_invalid_manifest(manifest) and igo_id in sample_id_manifests:
                overridden_manifest = sample_id_manifests[igo_id]
                content[resp_idx] = overridden_manifest

        sample_manifests.extend(content)
        idx += max_query

    return sample_manifests

def is_invalid_manifest(sample_manifest):
    """ Checks that the sample_manifest has valid values for the required fields

    :param sample_manifests: Object     entry from the getSampleManifest API response
    """
    if not sample_manifest[ "igoId" ]:
        return True
    for field in MAPPED_FIELDS:
        if not sample_manifest[ field ]:
            return True

    return False

def get_igo_id_mappings(sample_manifests, mapped_fields):
    """ Returns mapping of igoIds to relevant information contained in sample_manifests

    :param sample_manifests: Object[]	List of sample manifests for IGO IDs
    :param mapped_fields: string[]		List of relevant fields for IGO ID
    :return: mapping Object
        e.g. {
                'IGO_ID_1':{
                    'cmoPatientId':'ID',
                    'tumorOrNormal':'Tumor'
                },
                'IGO_ID_2':{
                    'cmoPatientId':'ID_2',
                    'tumorOrNormal':'Normal'
                },
                ...
        }
    """
    dic = {}

    for manifest in sample_manifests:
        key_value = manifest["igoId"]

        if key_value in dic:
            print("Warning: overwriting manifest entry for %s" % key_value)

        entry = {}
        for field in mapped_fields:
            entry[field] = manifest[field]

        if key_value in igoId_to_correctedCmoPatientId_map:
            entry["cmoPatientId"] = igoId_to_correctedCmoPatientId_map[key_value]

        if entry["cmoPatientId"] == "":
            # TODO - A bit confusing. "mapped_fields" isn't a good idea - can't handle this situation well, hard to read
            entry["cmoPatientId"] = manifest["sampleName"]

        dic[key_value] = entry

    return dic


def safe_extract(mapping, field):
    if field in mapping:
        return mapping[field]
    return "UNKNOWN"

def get_file_name(file, igo_id_mappings, bam_dir, mapped_fields):
    """Creates file for the merged bam name.
    """
    igo_id = get_igo_id(file)
    project_id = get_project_id(file)
    mapping = igo_id_mappings[igo_id]
    values = []
    for field in mapped_fields:
        values.append(safe_extract(mapping, field))

    values.insert(0, igo_id)
    file_name = "%s/%s/%s" % (bam_dir, project_id, BAM_DELIMITER.join(values) + '.bam')

    return file_name


def get_merge_info(files, igo_id_mappings, bam_dir, mapped_fields):
    """ Generates a map of merged file_name to files to include in the merge

    :param files:
    :param igo_id_mappings: Object, e.g. {'IGO_ID': {'cmoPatientId': 'ID', 'tumorOrNormal': 'Tumor'}, ... }
    :param mapped_fields: String[], e.g. ["cmoPatientId", "tumorOrNormal"]
    :return: e.g. {
                'P04969__04969_N_1__C-000238__Tumor':[
                    '/ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P04969_N___NE5dpost_PD_IGO_04969_N_1___GRCh37.bam',
                    '/ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P04969_N___NE5epost_Erp_IGO_04969_N_5___GRCh37.bam',
                ],
                ...
             }
    """
    merge_info = {}
    for file in files:
        file_name = get_file_name(file, igo_id_mappings, bam_dir, mapped_fields)
        if file_name in merge_info:
            merge_info[file_name].append(file)
        else:
            merge_info[file_name] = [file]

    return merge_info


def create_merge_commands(merge_info):
    """ Writes the commands to merge bam files from the @merge_info mapping of files to their files to merge

    :param merge_info: { TARGET_FILE: [ FILE1, FILE2, ... ], ... }
    :return: string
    """
    bash_commands = ""
    for target_file, file_list in merge_info.items():
        mkdir_cmd="mkdir -p $(dirname %s)" % target_file  # Create parent directory for merged bam prior to writing it
        if len(file_list) == 1:
            # Don't merge a single file. Create directory for project, move it, and create a symbolic link from the moved to its original location
            bash_commands += "%s && cp %s %s && ln -s %s %s\n" % (mkdir_cmd, file_list[0], target_file, target_file, file_list[0])
        else:
            bash_commands += "%s && samtools merge %s %s\n" % (mkdir_cmd, target_file, ' '.join(file_list))
    return bash_commands


def write_file(file_name, contents):
    """ Writes @contents to @file_name
    :param file_name:
    :param contents:
    :return:
    """
    merge_commands_file = open(file_name, "a")
    merge_commands_file.truncate(0)  # Delete any old data
    merge_commands_file.write(contents)
    merge_commands_file.close()


def get_merge_commands(files, bam_dir, lims_host):
    """ Writes a text file of the merge commands that should be run to merge BAMS across runs

    :param files: string[] - List of absolute paths to files
    :param bam_dir:	string - Directory to write BAM files to
    :param output_file: string - file bash commands should be written to
    :return:
    """
    igo_ids = list(set(list(map(lambda file: get_igo_id(file), files))))
    sample_manifests = get_sample_manifests(igo_ids, lims_host)
    igo_id_mappings = get_igo_id_mappings(sample_manifests, MAPPED_FIELDS)
    merge_info = get_merge_info(files, igo_id_mappings, bam_dir, MAPPED_FIELDS)
    return create_merge_commands(merge_info)

def main():
    """
    Will be called as python ./create_merge_commands ${FILE_TO_WRITE_COMMANDS} ${DIR_TO_WRITE_BAMS} [-options] ${BAM_FILES}
    """

    if len(sys.argv) < 3:
        fail("Missing output_file & files.")

    inputs = sys.argv[1:]

    args = [ arg for arg in inputs if arg[0] != "-"]
    output_file = args[0]
    bam_dir = args[1]
    files = args[2:]

    if not os.path.isdir(bam_dir):
        fail("%s is not a valid directory" % bam_dir)

    opts = [ arg.lower() for arg in inputs if arg[0] == "-"]
    use_tango = "-t" in opts

    lims_host = config.LIMS_HOST_TANGO if use_tango else config.LIMS_HOST_PROD

    if len(files) < 1:
        fail("No Files specified")

    merge_commands = get_merge_commands(files, bam_dir, lims_host)
    write_file(output_file, merge_commands)

if __name__ == '__main__':
    main()
