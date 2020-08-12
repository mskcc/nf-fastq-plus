# nf-fastq-plus
Generate IGO fastqs, bams, stats and fingerprinting

## Run
### Run Pipeline
```
$ make run
nextflow run main.nf
N E X T F L O W  ~  version 19.10.0
Launching `main.nf` [insane_shockley] - revision: 74de403843
WARN: DSL 2 IS AN EXPERIMENTAL FEATURE UNDER DEVELOPMENT -- SYNTAX MAY CHANGE IN FUTURE RELEASE
         I G O   P I P E L I N E
==========================================
SEQUENCER_DIR="/igo/sequencers"
RUNS_TO_DEMUX_FILE="Run_to_Demux.txt"

Output=./pipeline_out

executor >  local (1)
[6b/a80b26] process > DETECT_RUNS  [100%] 1 of 1 ✔
[-        ] process > process_runs -
```

### Clean outputs
```
$ make clean
rm -rf work && rm -rf pipeline_out
```
## Templates
The templates folder contains the scripts that run the pipeline. To run an individual step, define all nextflow context variables (e.g. all variables specified in a process's `input`), and run call that script directly.

### Detect Runs
```
$ ls Run_to_Demux.txt 		# Should error, no file 
ls: cannot access Run_to_Demux.txt: No such file or directory

$ SEQUENCER_DIR="/igo/sequencers" RUN_AGE=6000 RUNS_TO_DEMUX_FILE="Run_to_Demux.txt" ./templates/detect_runs.sh
/igo/sequencers/johnsawyers/200807_JOHNSAWYERS_0241_000000000-J72K7/RTAComplete.txt
/igo/sequencers/johnsawyers/200811_JOHNSAWYERS_0242_000000000-CYF3M/RTAComplete.txt
/igo/sequencers/johnsawyers/200807_JOHNSAWYERS_0241_000000000-J72K7/RTAComplete.txt
/igo/sequencers/johnsawyers/200811_JOHNSAWYERS_0242_000000000-CYF3M/RTAComplete.txt
/igo/sequencers/toms/200807_TOMS_5396_000000000-J746K/RTAComplete.txt
/igo/sequencers/michelle/200811_MICHELLE_0247_AHL53KDRXX/CopyComplete.txt
/igo/sequencers/pitt/200807_PITT_0490_AHHWV7BBXY/SequencingComplete.txt
/igo/sequencers/pitt/200807_PITT_0491_BHHY5VBBXY/SequencingComplete.txt
/igo/sequencers/scott/200811_SCOTT_0196_AHJ5VFBGXF/RunCompletionStatus.xml
/igo/sequencers/ayyan/200807_AYYAN_0032_000000000-J7464/RTAComplete.txt
-bash-4.2$ ls Run_to_Demux.txt
Run_to_Demux.txt
``` 
