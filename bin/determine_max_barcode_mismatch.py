#!/usr/bin/python
"""Determines whether there will be a barcode collision in the input sample sheet
Args:
    mismatch (-m), int:     Number of mismatches allowed
    sample_sheet (-s), str: path to samplesheet
Usage: python determine_max_barcode_mistmatch.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>
"""

import sys
import os
import getopt

DATA_HEADER = "[Data],,,,,"

def read_barcodes_from_sample_sheet(sample_sheet_file):
    f = open(sample_sheet_file, "r")
    sample_sheet_content = f.read().split()
    f.close()

    data_line_idx = 0
    for i in range(len(sample_sheet_content)):
        line = sample_sheet_content[i]
        if DATA_HEADER in line:
            data_line_idx = i
            break
    headers_idx = data_line_idx + 1
    headers_line = sample_sheet_content[headers_idx]
    sample_rows = sample_sheet_content[headers_idx + 1:]

    headers = headers_line.split(",")

    index_positions = [ idx for idx in range(0,len(headers)) if "index" in headers[idx] ]
    index_positions.sort()

    lane_positions = [ idx for idx in range(0,len(headers)) if "Lane" in headers[idx] ]
    assert len(lane_positions) == 1
    lane_idx = lane_positions[0]

    lanes = list(set([ row[lane_idx] for row in sample_rows ]))

    lane_barcodes_dic = {}
    for lane in lanes:
        lane_barcodes_dic[lane] = [ [] for idx in index_positions ]
        lane_rows = [ row for row in sample_rows if row[lane_idx] == lane ]
        for i in range(0, len(lane_rows)):
            sample_row = lane_rows[i]
            # We ignore 10xX requests
            if "10X_Genomics" in sample_row:
                continue
            values = sample_row.split(",")
            for index in range(len(index_positions)):
                index_pos = index_positions[index]
                lane_barcodes_dic[lane][index].append(values[index_pos])

    return lane_barcodes_dic

def get_min_hamming_distance(barcode_list):
    n = len(barcode_list)

    min_hd = 100
    min_pair = []
    for i1 in range(n):
        for i2 in range(i1+1,n):
            b1 = barcode_list[i1]
            b2 = barcode_list[i2]
            hd = calculate_hamming_distance(b1, b2)
            if hd < min_hd:
                # print("Updating min ham distance - HD: {}: {} & {}".format(hd, b1, b2))
                min_hd = hd
                min_pair = [b1, b2]

    return min_hd, min_pair

def get_min_hamming_distance_of_lists(barcode_lists, min_valid_hd):
    assert len(barcode_lists) == 2
    assert len(barcode_lists[0]) == len(barcode_lists[1])

    i7_list = barcode_lists[0]
    i5_list = barcode_lists[1]

    n = len(i7_list)

    min_hd = 100
    min_pair = []
    for i1 in range(n):
        for i2 in range(i1+1,n):
            b1 = i7_list[i1]
            b2 = i7_list[i2]
            hd = calculate_hamming_distance(b1, b2)

            if hd < min_valid_hd:
                print("\t\ti7 Index had invalid hamming distance - HD={} BARCODES={}+{}".format(hd, b1, b2))
                i5_b1 = i5_list[i1]
                i5_b2 = i5_list[i2]
                i5_hd = calculate_hamming_distance(i5_b1, i5_b2)
                if i5_hd > hd:
                    hd = i5_hd
                    b1 = i5_b1
                    b2 = i5_b2
                    print("\t\ti5 index is valid - HD={} BARCODES={}+{}".format(hd, b1, b2))
                else:
                    print("\t\terror - i5 index is also invalid - HD={} BARCODES={}+{}".format(i5_hd, i5_b1, i5_b2))

            if hd < min_hd:
                # print("Updating min ham distance - HD: {}: {} & {}".format(hd, b1, b2))
                min_hd = hd
                min_pair = [b1, b2]

    return min_hd, min_pair

def calculate_hamming_distance(barcode1, barcode2):
    len_b1 = len(barcode1)
    len_b2 = len(barcode2)

    if len_b1 != len_b2:
        print("{} (len: {}) has a different length from {} (len: {})".format(barcode1, len_b1, barcode2, len_b2))

    ct = 0
    for idx in range(len_b1):
        if barcode1[idx] != barcode2[idx]:
            ct += 1

    return ct


def main(argv):
    sample_sheet = ''
    mismatch = 20

    try:
        opts, args = getopt.getopt(argv,"hs:m:",["samplesheet=", "mismatch="])
    except getopt.GetoptError:
        print('usage: determine_max_barcode_mistmatch.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
        sys.exit(2)
    if(len(opts) < 2):
        print('usage: determine_max_barcode_mistmatch.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('usage: determine_max_barcode_mistmatch.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
            sys.exit()
        elif opt in ("-s", "--species"):
            sample_sheet = arg
        elif opt in ("-m", "--mismatch"):
            if not arg.isdigit():
                print("-m <BARCODE_MISMATCH_VALUE> should be a number")
                sys.exit(1)
            mismatch = int(arg)
        else:
            print('usage: determine_max_barcode_mistmatch.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
            sys.exit(2)

    ss_name = os.path.basename(sample_sheet)
    print("Determining if bcl2fastq barcode collision will occur: SAMPLE_SHEET={} barcode-mismatches={}'".format(ss_name, mismatch))
    index_barcodes_dic = read_barcodes_from_sample_sheet(sample_sheet)

    # From bcl2fastq - "Barcodes with too few mismatches are ambiguous ( less than 2 times the number of mismatches plus 1)"
    max_valid_hd = (2 * mismatch) + 1
    min_hd = 20
    min_pair = []
    min_lane = -1
    for lane_key in index_barcodes_dic:
        barcode_lists = index_barcodes_dic[lane_key]

        if len(barcode_lists) == 2:
            hd, pair = get_min_hamming_distance_of_lists(barcode_lists, max_valid_hd)
        elif len(barcode_lists) == 1:
            hd, pair = get_min_hamming_distance(barcode_lists[0])

        if hd < min_hd:
            min_hd = hd
            min_pair = pair
            min_lane = lane_key
            print("\tMIN_HAMMING_DISTANCE={} LANE={} BARCODES={}".format(min_hd, min_lane, ",".join(min_pair)))
    if min_hd < max_valid_hd:
        print("ERROR: Barcode collision will occur in Lane {} of {}: barcode-mismatches={} BARCODES={}".format(min_lane, ss_name, mismatch, " & ".join(min_pair)))
        sys.exit(1)

    print("SUCCESS: No barcode collision will occur in {}".format(ss_name))
    sys.exit(0)


if __name__ == "__main__":
    main(sys.argv[1:])

