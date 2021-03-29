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
        self.assertEqual(genome_configs_dna[GENOME], "/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta")
        self.assertEqual(genome_configs_dna[REFERENCE], "/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta")

    def test_get_reference_configs_human_rna(self):
        genome_configs = get_reference_configs("", "RNA", "Human")
        self.assertEqual(genome_configs[GENOME], '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa')
        self.assertEqual(genome_configs[REFERENCE], '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa')
        self.assertEqual(genome_configs[REF_FLAT], '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt')
        self.assertEqual(genome_configs[RIBOSOMAL_INTERVALS], '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list')

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
        self.assertEqual(genome, "/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa")
        self.assertEqual(ref, "/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa")

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
        self.assertEqual(len(actual_dic), len(expected_dic), DEBUG_MSG)

    def test_RNASeq(self):
        params = get_recipe_species_params("RNASeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=GRCm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq", "Mouse")

    def test_RNASeq_Poly(self):
        params = get_recipe_species_params("RNASeq_PolyA", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=GRCm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_PolyA", "Mouse")

        params = get_recipe_species_params("RNASeq_PolyA", "Human")
        expected_params = "GENOME=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_PolyA", "Human")

    def test_RNASeq_RiboDeplete(self):
        params = get_recipe_species_params("RNASeq_RiboDeplete", "Human")
        expected_params = "GENOME=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "RNASeq_RiboDeplete", "Human")

    def test_SMARTerAmpSeq(self):
        params = get_recipe_species_params("SMARTerAmpSeq", "Mouse")
        expected_params = "GENOME=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa GTAG=GRCm38 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat RIBOSOMAL_INTERVALS=/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "SMARTerAmpSeq", "Mouse")

        params = get_recipe_species_params("SMARTerAmpSeq", "Human")
        expected_params = "GENOME=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa REF_FLAT=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt RIBOSOMAL_INTERVALS=/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list TYPE=RNA"
        self.verify_params(params, expected_params, "SMARTerAmpSeq", "Human")

    def test_ATACSeq(self):
        # SEE 11107 of JAX_0461
        params = get_recipe_species_params("ATACSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Human")

        params = get_recipe_species_params("ATACSeq", "Mouse")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Mouse")

        params = get_recipe_species_params("ATACSeq", "Mouse_GeneticallyModified")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ATACSeq", "Mouse_GeneticallyModified")

    def test_AmpliconSeq(self):
        # See 07798_T of PITT_0496
        params = get_recipe_species_params("AmpliconSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "AmpliconSeq", "Human")

        params = get_recipe_species_params("AmpliconSeq", "Mouse")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "AmpliconSeq", "Mouse")

    def test_ChIPSeq(self):
        # See 10123_H of JAX_0461
        params = get_recipe_species_params("ChIPSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "ChIPSeq", "Human")

        params = get_recipe_species_params("ChIPSeq", "Mouse")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "ChIPSeq", "Mouse")

    def test_IMPACT468(self):
        params = get_recipe_species_params("IMPACT468", "Human")
        expected_params = "BAITS=/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_BAITS.interval_list GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=yes REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TARGETS=/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "IMPACT468", "Human")

    def test_IMPACT505(self):
        params = get_recipe_species_params("IMPACT505", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/IMPACT505/IMPACT505_BAITS.intervalList GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=yes REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TARGETS=/home/igo/resources/BED-Targets/IMPACT505/IMPACT505_TARGETS.intervalList TYPE=DNA"
        self.verify_params(params, expected_params, "IMPACT505", "Human")

    def test_ShallowWGS(self):
        params = get_recipe_species_params("ShallowWGS", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=WGS"
        self.verify_params(params, expected_params, "ShallowWGS", "Human")

    def test_IDT_Exome(self):
        params = get_recipe_species_params("IDT_Exome_v1_FP_Viral_Probes", "Human")
        expected_params = "BAITS=/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list GTAG=GRCh37 GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TARGETS=/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "IDT_Exome_v1_FP_Viral_Probes", "Human")

    def test_Agilent(self):
        params = get_recipe_species_params("Agilent_MouseAllExonV1", "Mouse")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_baits.ilist GTAG=mm10 GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TARGETS=/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_targets.ilist TYPE=DNA"
        self.verify_params(params, expected_params, "Agilent_MouseAllExonV1", "Mouse")

    def test_CRISPRSeq(self):
        params = get_recipe_species_params("CRISPRSeq", "Mouse")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRSeq", "Mouse")

        params = get_recipe_species_params("CRISPRSeq", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRSeq", "Human")

    def test_CRISPRScreen(self):
        params = get_recipe_species_params("CRISPRScreen", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRScreen", "Human")

        params = get_recipe_species_params("CRISPRScreen", "Mouse")
        expected_params = "GENOME=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa GTAG=mm10 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa TYPE=DNA"
        self.verify_params(params, expected_params, "CRISPRScreen", "Mouse")

    def test_customCapture(self):
        params = get_recipe_species_params("CustomCapture", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=DNA"
        self.verify_params(params, expected_params, "CustomCapture", "Human")

    def test_MSK_ACCESS(self):
        params = get_recipe_species_params("MSK-ACCESS_v1", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_hg37_sort-BAITS.interval_list GTAG=GRCh37 GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TARGETS=/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_hg37_sort-TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "MSK-ACCESS_v1", "Human")

    def test_CH_v1(self):
        params = get_recipe_species_params("CH_v1", "Human")
        expected_params = "BAITS=/home/igo/resources/BED-Targets/CH_v1/CH_v1_BAITS.interval_list GTAG=hg19 GENOME=/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/hg19/human_hg19.fa TARGETS=/home/igo/resources/BED-Targets/CH_v1/CH_v1_TARGETS.interval_list TYPE=DNA"
        self.verify_params(params, expected_params, "CH_v1", "Human")

    def test_HumanWholeGenome(self):
        params = get_recipe_species_params("HumanWholeGenome", "Human")
        expected_params = "GENOME=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta GTAG=GRCh37 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta TYPE=WGS"
        self.verify_params(params, expected_params, "HumanWholeGenome", "Human")

    def test_WholeGenomeSequencing_Bacteria(self):
        params = get_recipe_species_params("WholeGenomeSequencing", "Bacteria")
        expected_params = "GENOME=/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa GTAG=ecolik12 MD=yes MSKQ=no REFERENCE=/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa TYPE=WGS"
        self.verify_params(params, expected_params, "WholeGenomeSequencing", "Bacteria")

    def test_get_recipe_options(self):
        wes_options = get_recipe_options("WholeExomeSequencing")
        self.assertEqual(wes_options[BAITS], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list")
        self.assertEqual(wes_options[TARGETS], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list")

if __name__ == '__main__':
    unittest.main()


