#!/usr/bin/python
"""Determines whether there will be a barcode collision in the input sample sheet

   NOTE: A collision occurs if 2 barcodes are ambiguous, which means that their number of mismatches is too little an
   index w/ an error to be confidently mapped to its correct index. From bcl2fastq, ambiguity is calculated as "Barcodes
   with too few mismatches are ambiguous ( less than 2 times the number of mismatches plus 1)"
Args:
    mismatch (-m), int:     Number of mismatches allowed
    sample_sheet (-s), str: path to samplesheet
Usage: python detect_barcode_collision.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>
"""

import sys
import os
import getopt

DATA_HEADER = "[Data],,,,,"
MIN_HAMMING_DISTANCE = 100  # Number larger than any number of possible mismatches

def generate_lane_idx_barcode_dic(sample_sheet_file):
    """ Returns a dictionary from the samplesheet mapping lanes to the barcodes of each index
    :param sample_sheet_file, str: absolute path to sample sheet
    :return: dic
        lane_barcodes_dic: {
            LANE: [
                [ 'GATTACCA', ... ]     # First will be the i7 indices
                [ 'ACCATTAG', ... ]     # Second will be the i5 indices
            ]
        }
    """
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
            if "10X_Genomics" in sample_row:        # We ignore 10xX requests, they should be demuxed w/ cellranger
                continue
            values = sample_row.split(",")
            for index in range(len(index_positions)):
                index_pos = index_positions[index]
                lane_barcodes_dic[lane][index].append(values[index_pos])

    return lane_barcodes_dic

def get_single_index_min_hamming_distance(barcode_list):
    """ Returns the minimum hamming distance from a list of single-index barcodes
    :param barcode_list, str[]: list of indices, e.g. [ 'GATTACCA', ... ]
    :return: int, str[]     - Minimum hamming distance and the indices with that distance
            e.g. 2, [GTAAGGTG, GTAAATTG]
    """
    n = len(barcode_list)
    min_hd = MIN_HAMMING_DISTANCE
    min_pair = []

    # Compare all barcodes and find the minimum hamming distance
    for i1 in range(n):
        for i2 in range(i1+1,n):
            b1 = barcode_list[i1]
            b2 = barcode_list[i2]
            hd = calculate_hamming_distance(b1, b2)
            if hd < min_hd:
                min_hd = hd
                min_pair = [b1, b2]

    return min_hd, min_pair

def get_dual_index_mismatches_and_barcodes(barcode_lists, min_valid_hd):
    """ Returns the minimum hamming distance of dual-index barcodes
        Note - I'm pretty sure that the i5 index is only considered if the i7 is ambiguous. I think this because I've
        seen the following,
            - i5 indices that are identical not throwing collision because their i7s were not ambiguous
            - ambiguous i7 indicies not throwing collisions when their i5 indices aren't ambiguous
            - collisions thrown when both i5 & i7 are ambiguous

        REAL EXAMPLES
            GATCAGAT+AGATCTCG & TAGCTTAT+AGATCTCG: No collision     (mismatches=1)      non-ambiguous i7, Same i5
            GCGGTATT+GGTAACAA & CCGGAATT+ACCGAATG: No collision     (mismatches=1)      ambiguous i7, non-ambiguous i5
            CTTCCTTC+GAAGGAAG & CGTCTTCA+TGAAGACG: Collision Error  (mismatches=2)      ambiguous i5 & i7

    :param barcode_lists, str[][]: list of lists of indices, e.g. [ [ 'GATTACCA', ... ], [ 'ACCATTAG', ... ] ]
    :param min_valid_hd, int:   Minimum valid hamming distance based on user input - this determines if the i7 is
                                ambiguous and the i5 should be considered
    :return: int, str[]     - Minimum hamming distance and the indices with that distance
            e.g. 2, [GTAAGGTG, GTAAATTG]
    """

    assert len(barcode_lists) == 2
    i7_list = barcode_lists[0]
    i5_list = barcode_lists[1]
    assert len(i7_list) == len(i5_list)

    # Compare each barcode and determine its minimum hamming distance
    min_hd = MIN_HAMMING_DISTANCE
    n = len(i7_list)
    min_pair = []
    for i1 in range(n):
        for i2 in range(i1+1,n):
            b1 = i7_list[i1]
            b2 = i7_list[i2]
            hd = calculate_hamming_distance(b1, b2)

            i7_is_ambiguous = hd < min_valid_hd # Only consider i5 index if the hamming distance of the i7 is ambiguous
            if i7_is_ambiguous:
                i5_b1 = i5_list[i1]
                i5_b2 = i5_list[i2]
                i5_hd = calculate_hamming_distance(i5_b1, i5_b2)
                if i5_hd > hd:
                    # If the i5 has a greater hamming distance, it might not be ambiguous
                    hd = i5_hd
                    b1 = i5_b1
                    b2 = i5_b2
            if hd < min_hd:
                min_hd = hd
                min_pair = [b1, b2]

    return min_hd, min_pair

def calculate_hamming_distance(barcode1, barcode2):
    """
    Calculate the hamming distance between two barcodes
    :param barcode1, str - Nucleotide string of index
    :param barcode2, str - Nucleotide string of index
    """
    len_b1 = len(barcode1)
    len_b2 = len(barcode2)

    if len_b1 != len_b2:
        raise Exception("ERROR: {} (len: {}) has a different length from {} (len: {})".format(barcode1, len_b1, barcode2, len_b2))

    ct = 0
    for idx in range(len_b1):
        if barcode1[idx] != barcode2[idx]:
            ct += 1

    return ct


def main(argv):
    try:
        opts, args = getopt.getopt(argv,"hs:m:",["samplesheet=", "mismatch="])
    except getopt.GetoptError:
        raise Exception('usage: detect_barcode_collision.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
    if(len(opts) < 2):
        raise Exception('usage: detect_barcode_collision.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
    for opt, arg in opts:
        if opt == '-h':
            print('usage: detect_barcode_collision.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')
            sys.exit(0)
        elif opt in ("-s", "--species"):
            sample_sheet = arg
        elif opt in ("-m", "--mismatch"):
            if not arg.isdigit():
                raise Exception("-m <BARCODE_MISMATCH_VALUE> should be a number")
            mismatch = int(arg)
        else:
            raise Exception('usage: detect_barcode_collision.py -s <PATH_TO_SAMPLESHEET> -m <BARCODE_MISMATCH_VALUE>')

    ss_name = os.path.basename(sample_sheet)
    print("Determining if bcl2fastq barcode collision will occur: SAMPLE_SHEET={} barcode-mismatches={}'".format(ss_name, mismatch))
    index_barcodes_dic = generate_lane_idx_barcode_dic(sample_sheet)

    max_valid_hd = (2 * mismatch) + 1
    min_hd = MIN_HAMMING_DISTANCE
    min_pair = []
    min_lane = -1
    for lane_key in index_barcodes_dic:
        barcode_lists = index_barcodes_dic[lane_key]

        if len(barcode_lists) == 2:
            # Dual index samplesheets will parse out two lists of indices
            hd, pair = get_dual_index_mismatches_and_barcodes(barcode_lists, max_valid_hd)
        elif len(barcode_lists) == 1:
            # Single index samplesheets will only have parsed out one list of indices
            hd, pair = get_single_index_min_hamming_distance(barcode_lists[0])

        if hd < min_hd:
            min_hd = hd
            min_pair = pair
            min_lane = lane_key
            print("\tMIN_HAMMING_DISTANCE={} LANE={} BARCODES={}".format(min_hd, min_lane, ",".join(min_pair)))
    if min_hd < max_valid_hd:
        raise Exception("Barcode collision will occur in Lane {} of {}: barcode-mismatches={} BARCODES={}".format(min_lane, ss_name, mismatch, " & ".join(min_pair)))

    print("SUCCESS: No barcode collision will occur in {}".format(ss_name))

if __name__ == "__main__":
    main(sys.argv[1:])

