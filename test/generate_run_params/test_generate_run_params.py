import unittest
import sys
sys.path.append('../../templates')
from generate_run_params import get_sample_type_from_recipe, get_reference_configs, get_recipe_options
from run_param_config import GENOME, REFERENCE, REF_FLAT, RIBO_INTER, BAIT, TARGET, CAPTURE

class TestSetupStats(unittest.TestCase):
    def test_get_sample_type_from_recipe(self):
        self.assertEqual(get_sample_type_from_recipe("MouseWholeGenome"), "WGS")
        self.assertEqual(get_sample_type_from_recipe("ShallowWGS"), "WGS")
        self.assertEqual(get_sample_type_from_recipe("10X_Genomics_WGS"), "WGS")
        self.assertEqual(get_sample_type_from_recipe("thisRNAhello"), "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloWorld96Well_SmartSeq2"), "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloSMARTerWorld"), "RNA")
        self.assertEqual(get_sample_type_from_recipe("FusionDiscoverySeq"), "RNA")
        self.assertEqual(get_sample_type_from_recipe("helloRiboWorld"), "RNA")
        self.assertEqual(get_sample_type_from_recipe("test"), "DNA")

    def test_get_reference_configs(self):
        genome_configs = get_reference_configs("", "DNA", "Human")
        self.assertEqual(genome_configs[GENOME], "/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa")
        self.assertEqual(genome_configs[REFERENCE], "/igo/work/genomes/H.sapiens/hg19/human_hg19.fa")

        genome_configs = get_reference_configs("", "RNA", "Human")
        self.assertEqual(genome_configs[GENOME], "/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa")
        self.assertEqual(genome_configs[REFERENCE], "/igo/work/genomes/H.sapiens/hg19/human_hg19.fa")
        self.assertEqual(genome_configs[REF_FLAT], "/home/igo/resources/BED-Targets/hg19-Ref_Flat.txt")
        self.assertEqual(genome_configs[RIBO_INTER], "/igo/work//bed-targets/ucsc_hg19_rRNA.iList")

        ''' TODO - Add these
            "Human": "hg19",
            "Mouse": "mm10",
            "Mouse_GeneticallyModified": "mm10",
            "Drosophilia": "dm3",
            "Zebrafish": "danrer7",
            "Chicken": "galGal4",
            ".*uberculosis": "mtubf11",
            "S.Cerevisae": "sccer",
            "other": "sccer",
            "E.Coli": "ecolik12",
            "Bacteria": "ecolik12",
            "C.Elegans": "ce10",
            "S.Pombe": "pombe",
            "R.norvegicus": "rn6",
            "E.Lambda": "elambda",
        '''

    def test_get_recipe_options(self):
        wes_options = get_recipe_options("WholeExomeSequencing")
        self.assertEqual(wes_options[BAIT], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list")
        self.assertEqual(wes_options[TARGET], "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list")
        self.assertEqual(wes_options[CAPTURE], "True")

if __name__ == '__main__':
    unittest.main()
