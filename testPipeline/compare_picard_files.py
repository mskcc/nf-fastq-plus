from os import path
import sys
import getopt

def get_metrics_table(fname):
    f = open(fname, "r")
    lines = f.readlines()

    start_idx = None
    end_idx = None

    for idx, l in enumerate(lines):
        if l.startswith("## METRICS CLASS"):
            start_idx = idx + 1
        if start_idx and idx > start_idx and l.strip() == "":
            end_idx = idx - 1
        if start_idx and end_idx:
            break

    table_fields = lines[start_idx: end_idx + 1]
    cleaned = [ line.strip() for line in table_fields ]

    return cleaned

def extract_values_dic(headers, lines):
    values_dic = {}
    header_values = headers.split('\t')

    for l in lines:
        vals = l.split('\t')
        hv_stack = header_values[:]
        while hv_stack and vals:
            values_dic[ hv_stack.pop() ] = vals.pop()

    return values_dic

def get_values_dic(f):
    metrics_table = get_metrics_table(f)
    values_dic = extract_values_dic(metrics_table[0], metrics_table[1:])

    return values_dic

def main(argv):
    type = ''
    try:
        opts, args = getopt.getopt(argv,"ht:",["type="])
    except getopt.GetoptError:
        print('usage: compare.py -t <type>')
        sys.exit(2)

    if(len(argv) == 0):
        print('usage: compare.py -t <type>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('usage: compare.py -t <type>')
            sys.exit()
        elif opt in ("-t", "--type"):
            type = arg
        else:
            print('usage: compare.py -t <type>')
            sys.exit(2)

    valid = True
    files = args
    if not len(files) == 2:
        print("Please specify 2 files")
        valid = False
    for file in files:
        if not path.exists(file):
            print("File {} does not exist".format(file))
            valid = False
    if not valid:
        sys.exit(1)

    f1 = args[0]
    f2 = args[1]

    # print("Testing type {} with files {} & {}".format(type, f1, f2))

    f1_values_dic = get_values_dic(f1)
    f2_values_dic = get_values_dic(f1)

    mismatches = get_mismatches(f1_values_dic, f2_values_dic)

    f_name = path.basename(f1)

    if len(mismatches.values()) == 0:
        print("SUCCESS: {}".format(f_name))
        sys.exit(0)
    else:
        sys.exit(1)


def get_mismatches(d1, d2):
    h1 = d1.keys()
    h2 = d2.keys()

    if h1 != h2:
        print("mismatch of headers")

    # Assuming h1 is the same as h2, just take one
    headers = h1

    mismatches = {}
    for header in headers:
        if d1[header] != d2[header]:
            mismatches[header] = {
                1: d1[header],
                2: d2[header]
            }

    return mismatches

if __name__ == "__main__":
    main(sys.argv[1:])
