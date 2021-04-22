#/bin/bash

LOCATION=$(dirname "$0")

python ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${LOCATION}/../data/split_sampleSheet/original/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME.csv --processed-dir .
python ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${LOCATION}/../data/split_sampleSheet/original/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv --processed-dir .
