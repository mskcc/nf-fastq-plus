from collections import OrderedDict

def get_ordered_dic(unordered_dic):
    """Returns a dictionary ordered by the length of its keys

    Args:
      unordered_dic: Dictionary of stuff to order

    Returns:
      type, OrderedDict: Ordered dictionary by key-length
    """
    return OrderedDict(sorted(unordered_dic.items(), key=lambda t: -len(t[0])))

""" Mapping of recipes to their type, default should be DNA """ 
recipe_type_mapping_UNORDERED = {
    "MouseWholeGenome": "WGS",
    "ShallowWGS": "WGS",
    "10X_Genomics_WGS": "WGS",
    ".*RNA.*": "RNA",
    ".*96Well_SmartSeq2": "RNA",
    ".*SMARTer.*": "RNA",
    "FusionDiscoverySeq": "RNA",
    ".*Ribo.*": "RNA",
    # FOR NEW ENTRIES
    # "{regex}": "{TYPE}"

    ".*": "DNA"      # DEFAULT
}
recipe_type_mapping = get_ordered_dic(recipe_type_mapping_UNORDERED)

""" Mapping of species to their genome-type """
species_genome_mapping_UNORDERED = {
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
    # FOR NEW ENTRIES
    # "{regex}": "{GENOME}"

    ".*": "INVALID"     # DEFAULT
}
species_genome_mapping = get_ordered_dic(species_genome_mapping_UNORDERED)

""" Mapping of genome-type to their reference files """
DEFAULT = "DEFAULT_TYPE"
GENOME = "GENOME"
REFERENCE = "REFERENCE"
REF_FLAT = "REF_FLAT"
RIBO_INTER = "RIBO_INTER"
GTAG = "GTAG"
genome_reference_mapping_UNORDERED = {
    "hg19": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/H.sapiens/hg19/BWA_0.7.5a/human_hg19.fa",
            REFERENCE: "/igo/work/genomes/H.sapiens/hg19/human_hg19.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/hg19-Ref_Flat.txt",
            RIBO_INTER: "/igo/work//bed-targets/ucsc_hg19_rRNA.iList"
        },
        "miRNA": {
            RIBO_INTER: "/home/igo/resources/BED-Targets/ucsc_hg19_rRNA.iList",
            REF_FLAT: "/home/igo/resources/BED-Targets/hg19-Ref_Flat.txt",
            GENOME: "/home/igo/resources/BED-Targets/human_Counting_miRNA_Genome.fasta",
            GTAG: "human_miRNA"
        }
    },
    "grch37": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta",
            REFERENCE: "/igo/work/genomes/H.sapiens/GRCh37/GRCh37.fasta"
        },
        "RNA": {
            GENOME: '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa',
            REFERENCE: '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa',
            REF_FLAT: '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/refFlat_ensembl.v75.txt',
            RIBO_INTER: '/igo/work/nabors/bed_files/GRCh37_RNA_Ensembl/Homo_sapiens.GRCh37.75.rRNA.interval_list'
        },
    },
    "grch38": {
        DEFAULT: {
            GENOME: "/igo/work/nabors/genomes/GRCh38_100/Homo_sapiens.GRCh38.dna.primary_assembly.fa",
            REFERENCE: "/igo/work/nabors/genomes/GRCh38_100/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
        },
        "RNA": {
            REF_FLAT: '/igo/work/nabors/bed_files/GRCh38_100_Ensembl/Homo_sapiens.GRCh38.100.ref.flat',
            RIBO_INTER: '/igo/work/nabors/bed_files/GRCh38_100_Ensembl/SHORT__Homo_sapiens.GRCh38.100.rRNA.interval.list'
        },
    },
    "grcm38": {
        DEFAULT: {
            GENOME: '/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa',
            REFERENCE: '/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.dna.primary_assembly.fa'
        },
        "RNA": {
            REF_FLAT: '/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.99.ref_flat',
            RIBO_INTER: '/igo/work/nabors/genomes/GRCm38/Mus_musculus.GRCm38.interval_list'
        },
    },
    "mm9": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/M.musculus/mm9/BWA_0.7.5a/mouse_mm9.fa",
            REFERENCE: "/igo/work/genomes/M.musculus/mm9/mouse_mm9.fa"
        },
        "RNA": {
                    REF_FLAT: "/home/igo/resources/BED-Targets/mm9-Ref_Flat.txt",
                    RIBO_INTER: "/home/igo/resources/BED-Targets/mm9.ribosomal.interval_file"
        },
        "miRNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/mm9-Ref_Flat.txt",
            GENOME: "/home/igo/resources/BED-Targets/mouse_Counting_miRNA_Genome.fasta",
            GTAG: "mouse_miRNA"
        }
    },
    "mm10": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa",
            REFERENCE: "/igo/work/genomes/M.musculus/mm10/BWA_0.7.5a/mouse_mm10__All.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/mm10-Ref_Flat.txt",
            RIBO_INTER: "/home/igo/resources/BED-Targets/mm10.ribosomal.interval_file"
        },
        "miRNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/mm10-Ref_Flat.txt",
            GENOME: "/home/igo/resources/BED-Targets/mouse_Counting_miRNA_Genome.fasta",
            GTAG: "mouse_miRNA"
        }
    },
    "rn6": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/R.norvegicus/Rnor_6.0/BWA_0.7.5a/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa",
            REFERENCE: "/igo/work/genomes/R.norvegicus/Rnor_6.0/Rattus_norvegicus.Rnor_6.0.dna.toplevel.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/Rattus_norvegicus.Rnor_6.0.94.ref_flat",
            RIBO_INTER: "/home/igo/resources/BED-Targets/Rattus_norvegicus.Rnor_6.0.94.interval_list"
        }
    },
    "dm3": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/D.melanogaster/dm3/BWA_0.7.5a/dm3.fa",
            REFERENCE: "/igo/work/genomes/D.melanogaster/dm3/BWA_0.7.5a/dm3.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/dm3-Ref_Flat.txt"
        }
    },
    "galGal4": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/G.gallus/BWA_0.7.5a/galGal4.fa",
            REFERENCE: "/igo/work/genomes/G.gallus/BWA_0.7.5a/galGal4.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/galGal4-Ref_Flat.txt"
        }
    },
    "sccer": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/S.cerevisiae/sacCer2/UCSC/BWA_0.7.5a/UCSC_sacCer2.fasta",
            REFERENCE: "/igo/work/genomes/S.cerevisiae/sacCer2/UCSC/BWA_0.7.5a/UCSC_sacCer2.fasta"
        }
    },
    "danrer7": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/D.rerio/danRer7/BWA_0.7.5a/danRer7.fa",
            REFERENCE: "/igo/work/genomes/D.rerio/danRer7/BWA_0.7.5a/danRer7.fa"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/danRer7-Ref_Flat.txt"
        }
    },
    "ce10": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/C.elegans/ce10/BWA_0.7.5a/ce10.fa",
            REFERENCE: "/igo/work/genomes/C.elegans/ce10/ce10.fa",
            REF_FLAT: "/home/igo/resources/BED-Targets/cel10-Ref_Flat.txt"
        }
    },
    "mtubf11": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/M.tuberculosis/f11/BWA_0.7.5a/mycobacterium_tuberculosis_f11__finished__4_contigs.fasta",
            REFERENCE: "/igo/work/genomes/M.tuberculosis/f11/BWA_0.7.5a/mycobacterium_tuberculosis_f11__finished__4_contigs.fasta"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/mycobacterium_tuberculosis_f11__RefFlat.txt"
        }
    },
    "mtubh37r": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/M.tuberculosis/h37rv_2/BWA_0.7.5a/mycobacterium_tuberculosis_h37rv2.fasta",
            REFERENCE: "/igo/work/genomes/M.tuberculosis/h37rv_2/BWA_0.7.5a/mycobacterium_tuberculosis_h37rv2.fasta"
        },
        "RNA": {
            REF_FLAT: "/home/igo/resources/BED-Targets/mycobacterium_tuberculosis_h37rv2_RefFlat.txt"
        }
    },
    "ecolik12": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa",
            REFERENCE: "/igo/work/genomes/E.coli/K12/MG1655/BWA_0.7.x/eColi__MG1655.fa"
        }
    },
    "pseudomonas": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/P.aeruginosa/BWA_0.7.5a/NC_002516.fa",
            REFERENCE: "/igo/work/genomes/P.aeruginosa/BWA_0.7.5a/NC_002516.fa"
        }
    },
    "pombe": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/S.pombe/Ensembl/BWA_0.7.5a/Schizosaccharomyces_pombe.ASM294v2.20.fa",
            REFERENCE: "/igo/work/genomes/S.pombe/Ensembl/Schizosaccharomyces_pombe.ASM294v2.20.fa"
        }
    },
    "ercc": {
        DEFAULT: {
            GENOME: "/home/igo/resources/BED-Targets/ERCC/BWA_0.7.5a/ERCC.fasta"
        }
    },
    "elambda": {
        DEFAULT: {
            GENOME: "/igo/work/genomes/viruses/LAMBDA/Enterobacteriophage_lambda.fa",
            REFERENCE: "/igo/work/genomes/viruses/LAMBDA/Enterobacteriophage_lambda.fa"
        }
    },
    "ct24": {
        DEFAULT: {
            GENOME: '/igo/work/nabors/C_thermophilum/C_thermophilum.annotation.v2.4/C_thermophilum.annotation.v2.4.scaff.fa',
            REFERENCE: '/igo/work/nabors/C_thermophilum/C_thermophilum.annotation.v2.4/C_thermophilum.annotation.v2.4.scaff.fa'
        },
        "RNA": {
            REF_FLAT: '/igo/work/nabors/C_thermophilum/C_thermophilum.annotation.v2.4/C_thermophilum.annotation.v2.4.ref_flat',
            RIBO_INTER: '/igo/work/nabors/C_thermophilum/C_thermophilum.annotation.v2.4/C_thermophilum.annotation.v2.4.interval_list'
        }
    },
    ".*": {
        DEFAULT: {
            GENOME: "INVALID",
            REFERENCE: "INVALID"
        }
    }
}
genome_reference_mapping = get_ordered_dic(genome_reference_mapping_UNORDERED)

""" Mapping of recipe to additional run options """
BAIT="BAIT"
TARGET="TARGET"
CAPTURE="CAPTURE"  # todo - delete this? Really just whether it has a bait & target
MSKQ="MSKQ"
MARKDUPLICATES="MARKDUPLICATES"
recipe_options_mapping_UNORDERED = {
    "IMPACT341": {
        BAIT: "/home/igo/resources/ilist/IMPACT341/b37/picard_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/IMPACT341/b37/picard_targets.interval_list",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IMPACT410.*": {
        BAIT: "/home/igo/resources/ilist/IMPACT410/b37/picard_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/IMPACT410/b37/picard_targets.interval_list",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IMPACT468": {
        # NOTE: interval list file name "IMPACT468_BAITS" is stored in LIMS and passed to pipelines, change file name with caution
        BAIT: "/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_BAITS.interval_list",
        TARGET: "/home/igo/resources/ilist/IMPACT468/b37/IMPACT468_TARGETS.interval_list",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IMPACT505": {
        # NOTE: interval list file name "IMPACT468_BAITS" is stored in LIMS and passed to pipelines, change file name with caution
        BAIT: "/home/igo/resources/BED-Targets/IMPACT505/IMPACT505_BAITS.intervalList",
        TARGET: "/home/igo/resources/BED-Targets/IMPACT505/IMPACT505_TARGETS.intervalList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*HemePACT.*v3.*": {
        BAIT: "/home/igo/resources/ilist/HemePACT_v3/b37/HemePACT_v3_b37_baits.ilist",
        TARGET: "/home/igo/resources/ilist/HemePACT_v3/b37/HemePACT_v3_b37_targets.ilist",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "HemePACT_v4": {
        BAIT: "/home/igo/resources/ilist/HemePACT_v4/b37/HemePACT_v4_BAITS.ilist",
        TARGET: "/home/igo/resources/ilist/HemePACT_v4/b37/HemePACT_v4_TARGETS.ilist",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IDT_Exome_V1_IMPACT468": {
        BAIT: "/home/igo/resources/BED-Targets/IMPACT-PLUS/IDT_Exome_V1_IMPACT468/IDT_Exome_V1_IMPACT468_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/IMPACT-PLUS/IDT_Exome_V1_IMPACT468/IDT_Exome_V1_IMPACT468_TARGETS.iList",
        CAPTURE: "True"
    },
    "OCCC": {
        BAIT: "/home/igo/resources/BED-Targets/OCCC_316_primary_targets.iList",
        TARGET: "/home/igo/resources/BED-Targets/OCCC_316_capture_targets.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "M-IMPACT_v1": {
        BAIT: "/home/igo/resources/BED-Targets/IMPACT/MM_IMPACT/mm_IMPACT_v1_mm10_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/IMPACT/MM_IMPACT/mm_IMPACT_v1_mm10_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "CHM": {
        BAIT: "/home/igo/resources/BED-Targets/HEMEPACT/HemePACT_v4_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/HEMEPACT/HemePACT_v4_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "WholeExomeSequencing": {
        BAIT: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list",
        CAPTURE: "True"
    },
    "Agilent_v4_51MB_Human": {
        BAIT: "/home/igo/resources/ilist/AgilentExon_51MB_b37_v3/b37/AgilentExon_51MB_b37_v3_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/AgilentExon_51MB_b37_v3/b37/AgilentExon_51MB_b37_v3_targets.interval_list",
        CAPTURE: "True"
    },
    "Agilent_MouseAllExonV1": {
        BAIT: "/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_baits.ilist",
        TARGET: "/home/igo/resources/BED-Targets/Agilent_MouseAllExonV1_mm10_v1_targets.ilist",
        CAPTURE: "True"
    },
    "IDT_Exome_v1_FP_Viral_Probes": {
        BAIT: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list",
        CAPTURE: "True"
    },
    "IDT_Exome_v1": {
        BAIT: "/home/igo/resources/BED-Targets/xgen-exome-research-panel-BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/xgen-exome-research-panel-TARGETS.iList",
        CAPTURE: "True"
    },
    "IDT_Exome_v1_FP": {
        BAIT: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_baits.interval_list",
        TARGET: "/home/igo/resources/ilist/IDT_Exome_v1_FP/b37/IDT_Exome_v1_FP_b37_targets.interval_list",
        CAPTURE: "True"
    },
    "WholeExome_v4": {
        BAIT: "/home/igo/resources/BED-Targets/IDT_Exome_v1_FP_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/IDT_Exome_v1_FP_TARGETS.iList",
        CAPTURE: "True"
    },
    "Twist_Exome": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/Twist/Twist_Exome_Hg19_TARGETS.iList",
        TARGET: "/home/igo/resources/BED-Targets/Twist/Twist_Exome_Hg19_TARGETS.iList",
        CAPTURE: "True"
    },
    "RF-OVARIAN_V2": {
        BAIT: "/home/igo/resources/BED-Targets/RF-OVARIAN_V2-BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/RF-OVARIAN_V2-TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "RF-BREAST_V2": {
        BAIT: "/home/igo/resources/BED-Targets/RF-BREAST_V2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/RF-BREAST_V2_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "RF-BREAST_V3": {
        BAIT: "/home/igo/resources/BED-Targets/RF-BREAST_V3_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/RF-BREAST_V3_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Kigham": {
        BAIT: "/home/igo/resources/BED-Targets/Kinghamt20150127spikein_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/Kinghamt20150127spikein_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Kinghamt20150202panel": {
        BAIT: "/home/igo/resources/BED-Targets/Kingham_cfDNA_5626_Updated_032015.iList",
        TARGET: "/home/igo/resources/BED-Targets/Kingham_cfDNA_5626_Updated_032015.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Ventura_Dec2015": {
        BAIT: "/home/igo/resources/BED-Targets/VENTURA_V1_designed-probe-coords-SORTED.iList",
        TARGET: "/home/igo/resources/BED-Targets/VENTURA_V1_designed-probe-coords-SORTED.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "CCND3": {
        BAIT: "/home/igo/resources/BED-Targets/CCND3.iList",
        TARGET: "/home/igo/resources/BED-Targets/CCND3.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "King_130502_276_EZ_HX3": {
        BAIT: "/home/igo/resources/BED-Targets/04731_King_130502_276_EZ_HX3.iList",
        TARGET: "/home/igo/resources/BED-Targets/04731_King_130502_276_EZ_HX3.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "ReisFilho_ESOP_EZ_HX3": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/130912_HG19_ReisFilho_ESOP_EZ_HX3_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/130912_HG19_ReisFilho_ESOP_EZ_HX3_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Dlevine_27gene_v1_BED": {
        BAIT: "/home/igo/resources/BED-Targets/DLevine_27gene_probe_coverage_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/DLevine_27gene_probe_coverage_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IDTCustom_18_20161108": {
        BAIT: "/home/igo/resources/BED-Targets/IMPACT-PLUS/IDTCustom_18_20161108_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/IMPACT-PLUS/IDTCustom_18_20161108_TARGETS.iList",
        CAPTURE: "True"
    },
    "BRAINPACT_v1": {
     	BAIT: "/home/igo/resources/BED-Targets/BRAINPACT_V1/BRAINPACT_V1_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/BRAINPACT_V1/BRAINPACT_V1_TARGETS.iList",
        CAPTURE: "True"
    },
    "ADCC1_v2": {
     	BAIT: "/home/igo/resources/BED-Targets/ADCC1_V2/ADCC1_V2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/ADCC1_V2/ADCC1_V2_TARGETS.iList",
        CAPTURE: "True"
    },
    "ADCC1_v3": {
        BAIT: "/igo/work/nabors/bed_files/ADCC1_v3/ADCC1_v3_capture_targets_BAITS.interval_list",
        TARGET: "/igo/work/nabors/bed_files/ADCC1_v3/ADCC1_v3_primary_targets_TARGETS.interval_list",
        CAPTURE: "True"
    },
     ".*IWG.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/papaemme_IWG_OID43089_hg19_MHC_RNA_max10_20oct2015_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/papaemme_IWG_OID43089_hg19_MHC_RNA_max10_20oct2015_TARGETS.iList",
        CAPTURE: "True"
    },
    "RDM": {
        BAIT: "/home/igo/resources/BED-Targets/Rdm_Final_BAIT.iList",
        TARGET: "/home/igo/resources/BED-Targets/Rdm_Final_TARGET.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "MTM_V2": {
        BAIT: "/home/igo/resources/BED-Targets/Mtm_V2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/Mtm_V2_TARGET.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "FH_MED12": {
        BAIT: "/home/igo/resources/BED-Targets/MED12_FH.iList",
        TARGET: "/home/igo/resources/BED-Targets/MED12_FH.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Reis-Filho_ATP_V1": {
        BAIT: "/home/igo/resources/BED-Targets/Reis-Filho_ATP_V1.iList",
        TARGET: "/home/igo/resources/BED-Targets/Reis-Filho_ATP_V1.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "FG-Lupus_V1": {
        BAIT: "/home/igo/resources/BED-Targets/FG-Lupus_V1.iList",
        TARGET: "/home/igo/resources/BED-Targets/FG-Lupus_V1.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "Treatome_V2": {
        BAIT: "/home/igo/resources/BED-Targets/Treatome_V2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/Treatome_V2_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "MERTK": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/hg19_MERTK_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/hg19_MERTK_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "myTYPE_V1": {
        BAIT: "/home/igo/resources/BED-Targets/MM_MSK_permiss_BAIT.iList",
        TARGET: "/home/igo/resources/BED-Targets/MM_MSK_permiss_TARGET.iList",
        CAPTURE: "True",
        MSKQ: "no"
    },
    "NR3C1": {
        BAIT: "/home/igo/resources/BED-Targets/mm10_NR3C1_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/mm10_NR3C1_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    "IonAmpliseqCancerHotspotv2": {
        BAIT: "/home/igo/resources/BED-Targets/IonAmpliseqCancerHotspotv2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/IonAmpliseqCancerHotspotv2_TARGETS.iList",
        CAPTURE: "True",
        MARKDUPLICATES: "no"
    },
    ".*06575_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/06575_Hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/06575_Hg19_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*07822_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/07822_Hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/07822_Hg19_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*08035_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/08035_hg19/08035_B_BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/08035_hg19/08035_B_TARGETS.interval_list",
        CAPTURE: "True"
    },
    ".*08129_Hg19.*": {
        BAIT: "/home/igo/resources/BED-Targets/08129_Hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/08129_Hg19_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*07220_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/07220_Hg19/07220_Hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/07220_Hg19/07220_Hg19_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*06605_F_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/06605_F_hg19/06605_F_hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/06605_F_hg19/06605_F_hg19_TARGETS.iList",
        CAPTURE: "True",
        MSKQ: "yes"
    },
    ".*08382_Hg19.*": {
        # TODO - Delete "Twist_Exome" or change interval lists to be GRCh37
        BAIT: "/home/igo/resources/BED-Targets/08382_Hg19/08382_Hg19_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/08382_Hg19/08382_Hg19_TARGETS.iList",
        CAPTURE: "True"
    },
    ".*08428_mm10.*": {
        BAIT: "/home/igo/resources/BED-Targets/8428_mm10/8428_mm10_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/8428_mm10/8428_mm10_TARGETS.iList",
        CAPTURE: "True"
    },
    "PanCancerV2": {
        BAIT: "/home/igo/resources/BED-Targets/PanCancerV2/PanCancerV2_BAITS.iList",
        TARGET: "/home/igo/resources/BED-Targets/PanCancerV2/PanCancerV2_TARGETS.iList",
        CAPTURE: "True"
    },
    "MSK-ACCESS_v1": {
        BAIT: "/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_hg37_sort-BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/MSK-ACCESS_v1/MSK-ACCESS-v1_0-probesAllwFP_hg37_sort-TARGETS.interval_list",
        CAPTURE: "True"
    },
    "CH_v1": {
        BAIT: "/home/igo/resources/BED-Targets/CH_v1/CH_v1_BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/CH_v1/CH_v1_TARGETS.interval_list",
        CAPTURE: "True"
    },
    "MissionBio-Heme": {
        BAIT: "/home/igo/resources/BED-Targets/Mission_Bio/AML_BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/Mission_Bio/AML_TARGETS.interval_list",
        CAPTURE: "True"
    },
    "AmpliSeq": {
        BAIT: "/home/igo/resources/BED-Targets/AmpliSeq.ComprehensiveCancerPanel/ComprehensiveCancer.dna_manifest.20180509.BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/AmpliSeq.ComprehensiveCancerPanel/ComprehensiveCancer.dna_manifest.20180509.TARGETS.interval_list",
        CAPTURE: "True"
    },
    "PCFDDR_v1": {
        BAIT: "/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/PCFDDR_v1/PCFDDR_v1__TARGETS.interval_list",
        CAPTURE: "True"
    },
    "HemeBrainPACT_v1": {
        BAIT: "/home/igo/resources/BED-Targets/HemeBrainPACT_v1/HemeBrainPACT_v1_BAITS.interval_list",
        TARGET: "/home/igo/resources/BED-Targets/HemeBrainPACT_v1/HemeBrainPACT_v1_TARGETS.interval_list",
        CAPTURE: "True"
    },
    # FOR NEW ENTRIES
    # "{regex}": { [KEY]: "{REFERENCE_FILE}", ... }

    ".*": {}     # DEFAULT
}
recipe_options_mapping = get_ordered_dic(recipe_options_mapping_UNORDERED)
