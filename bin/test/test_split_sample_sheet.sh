#/bin/bash

python ../create_multiple_sample_sheets.py --sample-sheet data/split_sampleSheet/original/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME.csv --processed-dir .
python ../create_multiple_sample_sheets.py --sample-sheet data/split_sampleSheet/original/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv --processed-dir .
