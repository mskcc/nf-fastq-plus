# nf-fastq-plus
Generate IGO fastqs, bams, stats and fingerprinting

## Run
### Run Pipeline
```
$ make run
nextflow run main.nf
N E X T F L O W  ~  version 19.10.0
Launching `main.nf` [small_bernard] - revision: ceee417140
WARN: DSL 2 IS AN EXPERIMENTAL FEATURE UNDER DEVELOPMENT -- SYNTAX MAY CHANGE IN FUTURE RELEASE
WARN: The access of `config` object is deprecated
WARN: The access of `config` object is deprecated
WARN: The access of `config` object is deprecated
WARN: The access of `config` object is deprecated
WARN: The access of `config` object is deprecated
WARN: The access of `config` object is deprecated
I G O  P I P E L I N E
===================================
SEQUENCER_DIR="/igo/sequencers"
RUNS_TO_DEMUX_FILE="Run_to_Demux.txt"

Output=./pipeline_out

executor >  local (2)
[f9/45603c] process > DETECT_RUNS  [100%] 1 of 1 ✔
[b2/c65b52] process > process_runs [100%] 1 of 1 ✔
```

### Clean outputs
```
$ make clean
rm -rf work && rm -rf pipeline_out
```
