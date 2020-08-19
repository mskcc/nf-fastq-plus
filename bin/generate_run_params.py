#!/usr/bin/python
"""Determines run parameters to generate stats for input recipe & species
Args:
    recipe: Project recipe
    species: Project species
Usage: python generate_run_params.py -r HemeBrainPACT_v1 -s Human
"""

import re
import sys
import getopt
from collections import OrderedDict
from run_param_config import DEFAULT, get_ordered_dic, recipe_type_mapping, species_genome_mapping, genome_reference_mapping, recipe_options_mapping

def find_mapping(mapping, target):
    """Retrieves sample type from recipe

    Args:
      mapping (dic): regex-to-value mapping
      target (string): target match for regexes

    Returns:
      value (any): desired mapping of target
    """
    for key_re, val in mapping.items():
        expr = re.compile(key_re)
        if(expr.match(target)):
            return val
    return None

def get_sample_type_from_recipe(recipe):
    """Retrieves sample type from recipe

    Args:
      recipe: Recipe of the project

    Returns:
      type, String: Sample typeof the project
      For Example:
        "RNA", "DNA", "WGS"
    """
    return find_mapping(recipe_type_mapping, recipe)

def get_reference_configs(recipe, type, species):
    """Retrieves sample type from recipe

    Args:
      recipe: Project recipe
      type: Project sample type (E.g. "RNA", "DNA")
      species: Project species
    Returns:
      dic: Contains project params w/ following potential keys,
        DEFAULT
        GENOME
        REFERENCE
        REF_FLAT
        RIBO_INTER
        GTAG

      For Example:
        {'GENOME': '/path/to/hg19.fa', 'REFERENCE': '/path/to/hg19/hg19.fa'}
    """
    # TODO - This should be deleted so that this is just dependent on the recipe
    recipe_overrides = {
        "ADCC1_v3": "GRCh37",
    }
    genome = None
    if recipe in recipe_overrides:
        genome = recipe_overrides[recipe]
    else:
        genome = find_mapping(species_genome_mapping, species)

    mapping = find_mapping(genome_reference_mapping, genome)

    genome_configs = mapping[DEFAULT] # Base configuration for all recipes
    overrides = {} if type not in mapping else mapping[type]
    genome_configs.update(overrides)

    return genome_configs

def get_recipe_options(recipe):
    """Retrieves additional options for the given recipe

    Args:
      recipe: Project recipe
    Returns:
      dic: Contains recipe params w/ following potential keys,
        BAIT
        TARGET
        CAPTURE
        MSKQ
        MARKDUPLICATES

      For Example:
        {'CAPTURE': 'True', 'BAIT': '/path/to/HemeBrainPACT_v1_BAITS.interval_list',
         'TARGET': '/path/to/HemeBrainPACT_v1_TARGETS.interval_list'}
    """
    return find_mapping(recipe_options_mapping, recipe)


def main(argv):
    """
                      +-----------+
          +----------->   opts    +-------------+
          |           +-----------+             |
          |                                     |
    +-----+------+    +-----------+      +-----v------+
    |   recipe   +---->   type    +------> run_params |
    +-----+------+    +-----+-----+      +------^-----+
          |                 |                   |
          |           +-----v-----+             |
          +----------->   refr    +-------------+
                      +-----+-----+             |
                            ^                   |
    +------------+          |                   |
    |   species  +----------+-------------------+
    +------------+
    """
    recipe = ''
    species = ''
    try:
        opts, args = getopt.getopt(argv,"hr:s:",["recipe=","species="])
    except getopt.GetoptError:
        print('usage: setup_stats.py -r <recipe> -s <species>')
        sys.exit(2)
    if(len(argv) == 0):
        print('usage: setup_stats.py -r <recipe> -s <species>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('usage: setup_stats.py -r <recipe> -s <species>')
            sys.exit()
        elif opt in ("-r", "--recipe"):
            recipe = arg
        elif opt in ("-s", "--species"):
            species = arg
        else:
            print('usage: setup_stats.py -r <recipe> -s <species>')
            sys.exit(2)

    print('Recipe: {}'.format(recipe))
    print('Species: {}'.format(species))
    type = get_sample_type_from_recipe(recipe)
    refr = get_reference_configs(recipe, type, species)
    opts = get_recipe_options(recipe)

    # Consolidate options
    opts.update(refr)
    opts["TYPE"] = type

    run_params = get_ordered_dic(opts) # Want to print in same order
    for k,v in run_params.items():
        print("{}: {}".format(k, v))

if __name__ == "__main__":
    main(sys.argv[1:])

