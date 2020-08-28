import getopt, sys
# import random  # TODO - delete once reading sample_sheet

def is_alignment(line):
    return "/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem" in line

def get_alignment_params(line):
    segments = line.split(" ")
    bwa_cmd_idx = segments.index("\"/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa")

    # [ ..., '"/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa', 'mem', '-M', '-t', '36', '/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta', ... ]
    return segments[bwa_cmd_idx + 5]
    
def is_rna_seq_metrics(line):
    return "CollectRnaSeqMetrics" in line

def get_rna_seq_metrics(line):
    segments = line.split(" ")
    RIBO_INT=""
    REF_FLAT=""
    for seg in segments:
        if "RIBOSOMAL_INTERVALS" in seg:
            RIBO_INT=seg.split("=")[1]
        if "REF_FLAT"in seg:
            REF_FLAT=seg.split("=")[1]
    return RIBO_INT, REF_FLAT

def is_collect_hs_metrics(line):
    return "CollectHsMetrics" in line

def get_collect_hs_metrics(line):
    segments = line.split(" ")
    baits = ""
    target = ""
    for seg in segments:
        if "BI=" in seg:
            baits = seg.split("=")[1]
        if "TI=" in seg:
            target = seg.split("=")[1]
    return baits, target

def is_alignment_metrics(line):
    return "CollectAlignmentSummaryMetrics MAX_INSERT_SIZE=" in line

def is_CollectWgsMetrics(line):
    return "CollectWgsMetrics I=" in line

def get_reference_from_opts(line):
    opts = line.split(" ")
    REFERENCE = ""
    for opt in opts:
        if "R=" in opt:
            return opt.split("=")[1].rstrip("\"")
    return reference


def is_mskq_and_md_and_type(line):
    return "--md" in line and "--mskq" in line and "--type" in line

def get_mskq_and_md_and_type(line):
    opts = line.split(" ")
    mskq = ""
    md = ""
    type = ""
    for i in range(len(opts)):
        opt = opts[i]
        if "--md" in opt:
            md = opts[i+1]
        if "--mskq" in opt:
            mskq = opts[i+1]
        if "--type" in opt:
            type = opts[i+1]    
    return mskq, md, type

# TODO - this is determined by the samplesheet PE/SE - one or two FASTQs

def is_data_dir(line):
    """ Is line with data-dir, this tells us whether to switch to a different project
    """
    return "datadir: " in line

def get_recipe_species(line, sample_sheet_path):
    # datadir: /igo/work/FASTQ/KIM_0767_AHC2HVBCX3/Project_05605_I/Sample_HEC59_1-4_IGO_05605_I_1/
    line = line.split("/")
    project = line[5]

    # return random.randint(0, 10), random.randint(0, 10)
    try:
        f = open(sample_sheet_path, "r")
    except IOError:
        return "", ""
    contents = f.read()
    header_data = contents.split("[Data],,,,,,,")
    data = header_data[1]
    lines = data.split("\n")
    header = lines[1]
    header = header.split(",")
    recipe_idx = header.index("Sample_Well")
    species_idx = header.index("Sample_Plate")
    for line in lines:
        if project in line:
            vals = line.split(",")
            f.close()
            return vals[recipe_idx], vals[species_idx]
    f.close()
    return "ERROR", "ERROR"

def get_expected_params_str(GENOME, REFERENCE, RIBO_INT, REF_FLAT, BAITS, TARGETS, MSKQ, MD, TYPE):
    expected_params_str = "" 
    if BAITS != "":
        expected_params_str += " BAITS={}".format(BAITS)
    if GENOME != "":
        expected_params_str += " GENOME={}".format(GENOME)
    if MD != "":
        expected_params_str += " MD={}".format(MD)
    if MSKQ != "":
        expected_params_str += " MSKQ={}".format(MSKQ)
    if REFERENCE != "":
        expected_params_str += " REFERENCE={}".format(REFERENCE)
    if REF_FLAT != "":
        expected_params_str += " REF_FLAT={}".format(REF_FLAT)
    if RIBO_INT != "":
        expected_params_str += " RIBOSOMAL_INTERVALS={}".format(RIBO_INT)
    if TARGETS != "":
        expected_params_str += " TARGETS={}".format(TARGETS)
    if TYPE != "":
        expected_params_str += " TYPE={}".format(TYPE)
    return "        expected_params = \"{}\"".format(expected_params_str.strip())

def parse(file_path):
    RUN_COMMAND_SEPARATOR = "script=[/igo/home/igo/Scripts/Automate-Stats]"         # Separates all run commands
    PROJECT_COMMAND_SEPARATOR = "script=[/igo/home/igo/Scripts/PicardScripts]"      # Separates all project commands

    recipe_species_pairs = set()  # Keep track of all unique recipe-species pairs

    f = open(file_path, "r")
    run_commands = f.read().split(RUN_COMMAND_SEPARATOR)
    for run_cmd in run_commands:
        project_commands = run_cmd.split(PROJECT_COMMAND_SEPARATOR)
        for project in project_commands:
            GENOME=""
            RIBO_INT=""
            REF_FLAT=""
            BAITS=""
            TARGETS=""
            MSKQ=""
            MD=""
            REFERENCE=""
            TYPE=""
            recipe = ""
            species = ""
            lines = project.split("\n")
            if len(lines) > 1:
                sample_sheet = lines[2].split(" ")[0]
                for l in lines:
                    if is_data_dir(l):
                        line_recipe, line_species = get_recipe_species(l, sample_sheet)
                        rs_element = "{}{}".format(recipe, species) # Only print new recipe-species combinations
                        if (line_recipe != recipe or line_species != species) and rs_element not in recipe_species_pairs:
                            recipe_species_pairs.add(rs_element)
                            expected_params_str = get_expected_params_str(GENOME, REFERENCE, RIBO_INT, REF_FLAT, BAITS, TARGETS, MSKQ, MD,TYPE)
                            print("        params = get_recipe_species_params(\"{}\", \"{}\")".format(recipe, species))
                            print(expected_params_str)
                            # print("        expected_params = \"GENOME={} REFERENCE={} RIBOSOMAL_INTERVALS={} REF_FLAT={} BAITS={} TARGETS={} MSKQ={} MD={}\"".format(GENOME, REFERENCE, RIBO_INT, REF_FLAT, BAITS, TARGETS, MSKQ, MD))
                            print("        self.verify_params(params, expected_params, \"{}\", \"{}\")\n".format(recipe, species))
                            # print("PARAMS (R: {}, S: {}):\nGENOME: {}, REFERENCE: {}, RIBO_INT: {}, REF_FLAT: {}, BAITS: {}, TARGETS: {}, MSKQ: {}, MD: {}".format(recipe, species, GENOME, REFERENCE, RIBO_INT, REF_FLAT, BAITS, TARGETS, MSKQ, MD))
                        species = line_species
                        recipe = line_recipe
                    if is_alignment(l):
                        GENOME = get_alignment_params(l)
                    if is_rna_seq_metrics(l):
                        RIBO_INT, REF_FLAT = get_rna_seq_metrics(l)
                    if is_collect_hs_metrics(l):
                        BAITS, TARGETS = get_collect_hs_metrics(l)
                    if is_mskq_and_md_and_type(l):
                        MSKQ,MD,TYPE = get_mskq_and_md_and_type(l)
                    if is_alignment_metrics(l) or is_CollectWgsMetrics(l):
                        REFERENCE=get_reference_from_opts(l)
    f.close()

def main(argv):
    file_path = ""
    try:
        opts, args = getopt.getopt(argv,"hf:",["file="])
    except getopt.GetoptError:
        print('usage: parse_launchStats.py -f <file>')
        sys.exit(2)
    if(len(argv) == 0):
        print('usage: parse_launchStats.py -f <file>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('usage: parse_launchStats.py -f <file>')
            sys.exit()
        elif opt in ("-f", "--file"):
            file_path = arg
        else:
            print('usage: parse_launchStats.py -f <file>')
            sys.exit(2)
    # print("Parsing: {}".format(file_path))
    parse(file_path)

if __name__ == "__main__":
    main(sys.argv[1:])
