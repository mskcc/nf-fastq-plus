import unittest
import sys
from collections import OrderedDict
import json
sys.path.append('..')
from generate_run_params import main, get_sample_type_from_recipe, get_reference_configs, get_recipe_options
from run_param_config import GENOME, REFERENCE, REF_FLAT, RIBOSOMAL_INTERVALS, BAITS, TARGETS, TYPE

def get_debug_msg(recipe, species, d1, d2):
        return DEBUG_MSG

def parse_param(params, target):
    args = params.strip().split()
    for arg in args:
        opts = arg.split("=")
        if opts[0] == target:
            return opts[1]


def get_recipe_species_params(recipe, species):
    argv = [ "-r", recipe, "-s", species ]
    params = main(argv)
    return params

class TestSetupStats(unittest.TestCase):
    def test_get_sample_type_from_recipe(self):
        self.assertEqual(get_sample_type_from_recipe("MouseWholeGenome")[TYPE], "WGS")
        self.assertEqual(get_sample_type_from_recipe("ShallowWGS")[TYPE], "WGS")
        self.assertEqual(get_sample_type_from_recipe("10X_Genomics_WGS")[TYPE], "WGS")
        self.assertEqual(get_sample_type_from_recipe("thisRNAhello")[TYPE], "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloWorld96Well_SmartSeq2")[TYPE], "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloSMARTerWorld")[TYPE], "RNA")
        self.assertEqual(get_sample_type_from_recipe("FusionDiscoverySeq")[TYPE], "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloRiboWorld")[TYPE], "RNA")
        self.assertEqual(get_sample_type_from_recipe("test")[TYPE], "DNA")

    def test_get_reference_configs_human_dna(self):
        genome_configs_dna = get_reference_configs("", "DNA", "Human")
        self.assertEqual(genome_configs_dna[GENOME], "/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa")
        self.assertEqual(genome_configs_dna[REFERENCE], "/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa")

    def test_get_reference_configs_human_rna(self):
        genome_configs = get_reference_configs("", "RNA", "Human")
        self.assertEqual(genome_configs[GENOME], '/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa')
        self.assertEqual(genome_configs[REFERENCE], '/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa')
        self.assertEqual(genome_configs[REF_FLAT], '/igo/work/nabors/bed_files/GRCh38_100_Ensembl/Homo_sapiens.GRCh38.100.ref.flat')
        self.assertEqual(genome_configs[RIBOSOMAL_INTERVALS], '/igo/work/nabors/bed_files/GRCh38_100_Ensembl/SHORT__Homo_sapiens.GRCh38.100.rRNA.interval.list')

    def test_main_AmpliconSeq_Bacteria(self):
        argv = [ "-r", "AmpliconSeq", "-s", "Bacteria" ]
        params = main(argv)
        genome = parse_param(params, GENOME)
        ref = parse_param(params, REFERENCE)
        typ = parse_param(params, TYPE)
        self.assertEqual(genome, "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa")
        self.assertEqual(ref, "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa")
        self.assertEqual(typ, "DNA")

    def test_main_CRISPRSeq_Mouse(self):
        argv = [ "-r", "CRISPRSeq", "-s", "Mouse" ]
        params = main(argv)
        genome = parse_param(params, GENOME)
        ref = parse_param(params, REFERENCE)
        typ = parse_param(params, TYPE)
        self.assertEqual(typ, "DNA")
        self.assertEqual(genome, "/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa")
        self.assertEqual(ref, "/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa")

    def test_main_AmpliconSeq_Plasmid(self):
        argv = [ "-r", "AmpliconSeq", "-s", "Plasmid" ]
        params = main(argv)
        genome = parse_param(params, GENOME)
        ref = parse_param(params, REFERENCE)
        typ = parse_param(params, TYPE)
        self.assertEqual(typ, "DNA")
        self.assertEqual(genome, "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa")
        self.assertEqual(ref, "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa")

    def verify_params(self,params, expected_params, recipe, species):
        actual = params.strip().split(" ")
        expected = expected_params.strip().split(" ")

        actual_dic = {}
        expected_dic = {}
        for p in actual:
            kv = p.split("=")
            actual_dic[kv[0]] = kv[1]
        for p in expected:
            kv = p.split("=")
            expected_dic[kv[0]] = kv[1]
        actual_dic = OrderedDict(sorted(actual_dic.items()))
        expected_dic = OrderedDict(sorted(expected_dic.items()))

        DEBUG_MSG = "\nRecipe: {}, Species: {}\nACTUAL: {}\nEXPECTED: {}".format(recipe, species, json.dumps(actual_dic), json.dumps(expected_dic))
        for k,v in expected_dic.items():
            self.assertTrue(k in actual_dic, "Missing {}{}".format(k, DEBUG_MSG))
            self.assertEqual(v, actual_dic[k], "{} not equal to {}{}".format(k,v,DEBUG_MSG))

        # Since cell-ranger, we no longer care if there are more actual params than expected params because not all
        #   actual params will be used by the pipeline
        # self.assertEqual(len(actual_dic), len(expected_dic), DEBUG_MSG)

    def test_RNASeq(self):
        params = get_recipe_species_params("RNASeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq", "Mouse")

    def test_RNASeq_Poly(self):
        params = get_recipe_species_params("RNASeq_PolyA", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_PolyA", "Mouse")

        params = get_recipe_species_params("RNASeq_PolyA", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/Homo_sapiens.GRCh38.100.ref.flat RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/SHORT__Homo_sapiens.GRCh38.100.rRNA.interval.list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_PolyA", "Human")

    def test_RNASeq_RiboDeplete(self):
        params = get_recipe_species_params("RNASeq_RiboDeplete", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/Homo_sapiens.GRCh38.100.ref.flat RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/SHORT__Homo_sapiens.GRCh38.100.rRNA.interval.list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_RiboDeplete", "Human")

    def test_SMARTerAmpSeq(self):
        params = get_recipe_species_params("SMARTerAmpSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "SMARTerAmpSeq", "Mouse")

        params = get_recipe_species_params("SMARTerAmpSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/Homo_sapiens.GRCh38.100.ref.flat RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh38_100_Ensembl/SHORT__Homo_sapiens.GRCh38.100.rRNA.interval.list TYPE=RNA"
        self.verify_params(params, expected_params, "SMARTerAmpSeq", "Human")

    def test_ATACSeq(self):
        # SEE 11107 of JAX_0461
        params = get_recipe_species_params("ATACSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Human")

        params = get_recipe_species_params("ATACSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Mouse")

        params = get_recipe_species_params("ATACSeq", "Mouse_GeneticallyModified")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Mouse_GeneticallyModified")

    def test_AmpliconSeq(self):
        # See 07798_T of PITT_0496
        params = get_recipe_species_params("AmpliconSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "AmpliconSeq", "Human")

        params = get_recipe_species_params("AmpliconSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "AmpliconSeq", "Mouse")

    def test_ChIPSeq(self):
        # See 10123_H of JAX_0461
        params = get_recipe_species_params("ChIPSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ChIPSeq", "Human")

        params = get_recipe_species_params("ChIPSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ChIPSeq", "Mouse")

    def test_IMPACT468(self):
        params = get_recipe_species_params("IMPACT468", "Human")
        expected_params = "BAITS=/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_BAITS.interval_list GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=yes REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TARGETS=/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "IMPACT468", "Human")

    def test_IMPACT505(self):
        params = get_recipe_species_params("IMPACT505", "Human")
        expected_params = "BAITS=/igo/home/igo/resources/ilist/GRCh38.p13/IMPACT505/IMPACT505_GRCh38_BAITS.intervalList GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=yes REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TARGETS=/igo/home/igo/resources/ilist/GRCh38.p13/IMPACT505/IMPACT505_GRCh38_TARGETS.intervalList TYPE=DNA"
        self.verify_params(params, expected_params, "IMPACT505", "Human")

    def test_M_IMPACT_v1(self):
        params = get_recipe_species_params("M-IMPACT_v1", "Mouse")
        expected_params = "REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TARGETS=/home/igo/resources/BED-Targets/IMPACT/MM_IMPACT/mm_IMPACT_v1_mm10_TARGETS.iList GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa BAITS=/home/igo/resources/BED-Targets/IMPACT/MM_IMPACT/mm_IMPACT_v1_mm10_BAITS.iList GTAG=mm10 MSKQ=yes TYPE=DNA MD=yes"
        self.verify_params(params, expected_params, "M-IMPACT_v1", "Mouse")

    def test_ShallowWGS(self):
        params = get_recipe_species_params("ShallowWGS", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=WGS"
        self.verify_params(params, expected_params, "ShallowWGS", "Human")

    def test_IDT_Exome(self):
        params = get_recipe_species_params("IDT_Exome_v2_FP_Viral_Probes", "Human")
        expected_params = "BAITS=/igo/home/igo/resources/ilist/GRCh38.p13/IDT_Exome_v2/IDT_Exome_v2_GRCh38_BAITS.intervalList GTAG=GRCh38 GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TARGETS=/igo/home/igo/resources/ilist/GRCh38.p13/IDT_Exome_v2/IDT_Exome_v2_GRCh38_TARGETS.intervalList TYPE=DNA"
        self.verify_params(params, expected_params, "IDT_Exome_v2_FP_Viral_Probes", "Human")

    def test_IWG(self):
        params = get_recipe_species_params("IWG_v2", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/papaemme_IWG_OID43089_hg19_MHC_RNA_max10_20oct2015_BAITS.iList GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa TARGETS=/home/igo/resources/BED-Targets/papaemme_IWG_OID43089_hg19_MHC_RNA_max10_20oct2015_TARGETS.iList TYPE=DNA"
        self.verify_params(params, expected_params, "IWG_v2", "Human")

    def test_hg19_Overrides(self):
        hg19_override_recipes = [ "PCFDDR_v1", "PCFDDR_v2", "IWG_v2", "Twist_Exome", "IDT_Exome_v1", "ADCC1_v2", "RDM", "myTYPE_V1", "PanCancerV2", "MissionBio-Heme", "WholeExome_v4", "AmpliSeq", "HemeBrainPACT_v1" ]
        for recipe in hg19_override_recipes:
            params = get_recipe_species_params(recipe, "Human")
            expected_params = "GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa"
            self.verify_params(params, expected_params, recipe, "Human")

    def test_PCFDDR(self):
        # v1 & v2 should have same config
        params = get_recipe_species_params("PCFDDR_v1", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__BAITS.interval_list GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa TARGETS=/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "PCFDDR_v1", "Human")
        params = get_recipe_species_params("PCFDDR_v2", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__BAITS.interval_list GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa TARGETS=/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "PCFDDR_v2", "Human")

    def test_Agilent(self):
        params = get_recipe_species_params("Agilent_MouseAllExonV1", "Mouse")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_baits.ilist GTAG=grcm38 GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TARGETS=/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_targets.ilist TYPE=DNA"
        self.verify_params(params, expected_params, "Agilent_MouseAllExonV1", "Mouse")

    def test_CRISPRSeq(self):
        params = get_recipe_species_params("CRISPRSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRSeq", "Mouse")

        params = get_recipe_species_params("CRISPRSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRSeq", "Human")

    def test_CRISPRScreen(self):
        params = get_recipe_species_params("CRISPRScreen", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRScreen", "Human")

        params = get_recipe_species_params("CRISPRScreen", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=grcm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRScreen", "Mouse")

    def test_customCapture(self):
        params = get_recipe_species_params("CustomCapture", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CustomCapture", "Human")

    def test_MSK_ACCESS(self):
        params = get_recipe_species_params("MSK-ACCESS_v1", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_GRCh38.interval_list GTAG=GRCh38 GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa TARGETS=/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_GRCh38.interval_list TYPE=DNA HAPLOTYPE_MAP=/home/igo/fingerprint_maps/map_files/hg38_no_chr_ACCESS_unordered.map"
        self.verify_params(params, expected_params, "MSK-ACCESS_v1", "Human")

    def test_CH_v1(self):
        params = get_recipe_species_params("CH_v1", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/CH_v1/CH_v1_BAITS.interval_list GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa TARGETS=/home/igo/resources/BED-Targets/CH_v1/CH_v1_TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "CH_v1", "Human")

    def test_HumanWholeGenome(self):
        params = get_recipe_species_params("HumanWholeGenome", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/ncbi-genomes-2021-09-23/GCF_000001405.39_GRCh38.p13_genomic.fna GTAG=GRCh38 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/ncbi-genomes-2021-09-23/GCF_000001405.39_GRCh38.p13_genomic.fna TYPE=WGS DGN_REFERENCE=/staging/ref/GRCh38.p13___genBank_GCA_000001405.28"
        self.verify_params(params, expected_params, "HumanWholeGenome", "Human")

    def test_WholeGenomeSequencing_Bacteria(self):
        params = get_recipe_species_params("WholeGenomeSequencing", "Bacteria")
        expected_params = "GENOME=/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa GTAG=ecolik12 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa TYPE=WGS"
        self.verify_params(params, expected_params, "WholeGenomeSequencing", "Bacteria")

    def test_10xGeneExpression_Human(self):
        species = "Human"
        expected_params = "CELLRANGER_COUNT=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A CELLRANGER_ATAC=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 CELLRANGER_VDJ=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 CELLRANGER_CNV=/igo/work/nabors/10X_Genomics_references/CNV/refdata-GRCh38-1.0.0 REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MSKQ=no TYPE=DNA MD=yes"
        geneExpression_recipes = [ "10X_Genomics_GeneExpression", "10X_Genomics_GeneExpression-3", "10X_Genomics_GeneExpression-5", "10X_Genomics_NextGEM-GeneExpression", "10X_Genomics_NextGEM-GeneExpression-5", "10X_Genomics_NextGEM_GeneExpression-5" ]

        for recipe in geneExpression_recipes:
            params = get_recipe_species_params(recipe, species)
            self.verify_params(params, expected_params, recipe, species)

    def test_10xVDJ_Human(self):
        species = "Human"
        expected_params = "CELLRANGER_COUNT=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A CELLRANGER_ATAC=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 CELLRANGER_VDJ=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 CELLRANGER_CNV=/igo/work/nabors/10X_Genomics_references/CNV/refdata-GRCh38-1.0.0 REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MSKQ=no TYPE=DNA MD=yes"
        geneExpression_recipes = [ "10X_Genomics_NextGem_VDJ", "10X_Genomics_NextGEM_VDJ", "10X_Genomics_NextGEM-VDJ", "10X_Genomics_VDJ", "10X_Genomics-VDJ" ]

        for recipe in geneExpression_recipes:
            params = get_recipe_species_params(recipe, species)
            self.verify_params(params, expected_params, recipe, species)

    def test_10xVisium_Human(self):
        species = "Human"
        recipe = "10X_Genomics_Visium"
        expected_params = "CELLRANGER_COUNT=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A CELLRANGER_ATAC=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 CELLRANGER_VDJ=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 CELLRANGER_CNV=/igo/work/nabors/10X_Genomics_references/CNV/refdata-GRCh38-1.0.0 REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MSKQ=no TYPE=DNA MD=yes"
        params = get_recipe_species_params(recipe, species)
        self.verify_params(params, expected_params, recipe, species)

    def test_10xATAC_Human(self):
        species = "Human"
        recipe = "10X_Genomics_ATAC"
        expected_params = "CELLRANGER_COUNT=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A CELLRANGER_ATAC=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 CELLRANGER_VDJ=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 CELLRANGER_CNV=/igo/work/nabors/10X_Genomics_references/CNV/refdata-GRCh38-1.0.0 REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MSKQ=no TYPE=DNA MD=yes"
        params = get_recipe_species_params(recipe, species)
        self.verify_params(params, expected_params, recipe, species)

    def test_10xCNV_Human(self):
        species = "Human"
        recipe = "10X_Genomics_CNV"
        expected_params = "CELLRANGER_COUNT=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A CELLRANGER_ATAC=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 CELLRANGER_VDJ=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 CELLRANGER_CNV=/igo/work/nabors/10X_Genomics_references/CNV/refdata-GRCh38-1.0.0 REFERENCE=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GENOME=/igo/work/genomes/H.sapiens/GRCh38.p13/GRCh38.p13.dna.primary.assembly.fa GTAG=GRCh38 MSKQ=no TYPE=DNA MD=yes"
        params = get_recipe_species_params(recipe, species)
        self.verify_params(params, expected_params, recipe, species)

    def test_get_recipe_options(self):
        wes_options = get_recipe_options("WholeExomeSequencing")
        self.assertEqual(wes_options[BAITS], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list")
        self.assertEqual(wes_options[TARGETS], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list")

    def test_hMap_hg19(self):
        hg19_recipes = [ "CH_v1", "PCFDDR_v1", "PCFDDR_v2", "IWG_v2", "Twist_Exome", "IDT_Exome_v1", "ADCC1_v2", "RDM", "myTYPE_V1", "PanCancerV2", "MissionBio-Heme", "WholeExome_v4", "AmpliSeq", "HemeBrainPACT_v1" ]
        for recipe in hg19_recipes:
            params = get_recipe_species_params(recipe, "Human")
            expected_params = "HAPLOTYPE_MAP=/home/igo/fingerprint_maps/map_files/hg19_ACCESS.map"
            self.verify_params(params, expected_params, recipe, "Human")

    def test_hMap_GRCh38(self):
        grch38_recipes = [ "IMPACT505", "IDT_Exome_v2_FP_Viral_Probes", "IMPACT341", "HemePACT_v4", "WholeExomeSequencing", "Agilent_v4_51MB_Human", "ShallowWGS", "10X_Genomics_WGS", "AmpliconSeq" ]
        for recipe in grch38_recipes:
            params = get_recipe_species_params(recipe, "Human")
            expected_params = "HAPLOTYPE_MAP=/home/igo/fingerprint_maps/map_files/hg38_igo.map"
            self.verify_params(params, expected_params, recipe, "Human")

    def test_hMap_GRCh38_human_whole_genome(self):
        grch38_recipes = [ "HumanWholeGenome" ]
        for recipe in grch38_recipes:
            params = get_recipe_species_params(recipe, "Human")
            expected_params = "HAPLOTYPE_MAP="    # TODO - Create valid haplotype map for GRCh38 human whole genome
            self.verify_params(params, expected_params, recipe, "Human")

    def test_hMap_GRCh37(self):
        grch38_recipes = [ "ADCC1_v3" ]
        for recipe in grch38_recipes:
            params = get_recipe_species_params(recipe, "Human")
            expected_params = "HAPLOTYPE_MAP=/home/igo/fingerprint_maps/map_files/GRCh37_ACCESS.map"
            self.verify_params(params, expected_params, recipe, "Human")

    def test_10x_arc(self):
        recipe="10X_Genomics_Multiome"

        s1 = "Human"
        params = get_recipe_species_params(recipe, s1)
        expected_params = "CELLRANGER_ARC=/igo/work/nabors/genomes/10X_Genomics/ARC/refdata-cellranger-arc-GRCh38-2020-A-2.0.0"
        self.verify_params(params, expected_params, recipe, s1)

        s2 = "Mouse"
        params = get_recipe_species_params(recipe, s2)
        expected_params = "CELLRANGER_ARC=/igo/work/nabors/genomes/10X_Genomics/ARC/refdata-cellranger-arc-mm10-2020-A-2.0.0"
        self.verify_params(params, expected_params, recipe, s2)

    def test_recipe_overrides(self):
        default_human = "GRCh38"
        default_mouse = "grcm38"

        overriden_recipes_hg19 = [ "PCFDDR_.*", "IWG.*", "CH_v1", "Twist_Exome", "IDT_Exome_v1", "ADCC1_v2", "RDM", "myTYPE_V1", "PanCancerV2", "MissionBio-Heme", "WholeExome_v4", "AmpliSeq", "HemeBrainPACT_v1" ]
        overriden_recipes_grch37 = [ "ADCC1_v3" ]
        overriden_recipes_mm10 = [ "M-IMPACT_v1", "10X_Genomics_Multiome" ]

        # TEST that overrides only apply for recipes that are keys in the override_species dictionary

        # Test recipes where Human should have the overrides, not Mouse
        override_species = "Human"
        no_override_species = "Mouse"
        for recipe in overriden_recipes_hg19:
            params = get_recipe_species_params(recipe, override_species)
            expected_params = "GTAG=hg19"
            self.verify_params(params, expected_params, recipe, override_species)

            params = get_recipe_species_params(recipe, no_override_species)
            expected_params = "GTAG=%s" % default_mouse
            self.verify_params(params, expected_params, recipe, no_override_species)

        for recipe in overriden_recipes_grch37:
            params = get_recipe_species_params(recipe, override_species)
            expected_params = "GTAG=GRCh37"
            self.verify_params(params, expected_params, recipe, override_species)

            params = get_recipe_species_params(recipe, no_override_species)
            expected_params = "GTAG=%s" % default_mouse
            self.verify_params(params, expected_params, recipe, no_override_species)

        # Test recipes where Mouse should have the overrides, not Human
        override_species = "Mouse"
        no_override_species = "Human"
        for recipe in overriden_recipes_mm10:
            params = get_recipe_species_params(recipe, override_species)
            expected_params = "GTAG=mm10"
            self.verify_params(params, expected_params, recipe, override_species)

            params = get_recipe_species_params(recipe, no_override_species)
            expected_params = "GTAG=%s" % default_human
            self.verify_params(params, expected_params, recipe, no_override_species)


if __name__ == '__main__':
    unittest.main()


