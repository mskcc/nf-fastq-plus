# nf-fastq-plus
Generate IGO fastqs, bams, stats and fingerprinting

## Run
### Run Pipeline
```
$ nextflow run main.nf
N E X T F L O W  ~  version 19.10.0
Launching `main.nf` [ridiculous_mendel] - revision: 32a294cd4c
WARN: DSL 2 IS AN EXPERIMENTAL FEATURE UNDER DEVELOPMENT -- SYNTAX MAY CHANGE IN FUTURE RELEASE
         I G O   P I P E L I N E
==========================================
SEQUENCER_DIR="/igo/sequencers"
RUNS_TO_DEMUX_FILE="Run_to_Demux.txt"

VERSIONS
BWA: /opt/common/CentOS_7/bwa/bwa-0.7.17/bwa
PICARD: /home/igo/resources/picard2.21.8

Output=./pipeline_out
Log=/home/streidd/work/nf-fastq-plus/igo-pipeline.log

executor >  local (4)
[04/539326] process > get_software_versions_wkflw:get_software_versions [100%] 1 of 1 ✔
[df/6fd847] process > get_software_versions_wkflw:log_out               [100%] 1 of 1 ✔
[46/54abf0] process > detect_runs_wkflw:detect_runs                     [100%] 1 of 1 ✔
[d1/b30dac] process > detect_runs_wkflw:log_out                         [100%] 1 of 1 ✔
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
SEQUENCER_DIR="/igo/sequencers" RUN_AGE=6000 RUNS_TO_DEMUX_FILE="Run_to_Demux.txt" ./templates/detect_runs.sh
Detected 10 new runs
Outputting new runs to
Processing RUN=200807_JOHNSAWYERS_0241_000000000-J72K7 RUNNAME=JOHNSAWYERS_0241_000000000-J72K7 RUNPATH=/igo/sequencers/johnsawyers/200807_JOHNSAWYERS_0241_000000000-J72K7 DEMUX_TYPE=
Processing RUN=200811_JOHNSAWYERS_0242_000000000-CYF3M RUNNAME=JOHNSAWYERS_0242_000000000-CYF3M RUNPATH=/igo/sequencers/johnsawyers/200811_JOHNSAWYERS_0242_000000000-CYF3M DEMUX_TYPE=
Processing RUN=200807_JOHNSAWYERS_0241_000000000-J72K7 RUNNAME=JOHNSAWYERS_0241_000000000-J72K7 RUNPATH=/igo/sequencers/johnsawyers/200807_JOHNSAWYERS_0241_000000000-J72K7 DEMUX_TYPE=
Processing RUN=200811_JOHNSAWYERS_0242_000000000-CYF3M RUNNAME=JOHNSAWYERS_0242_000000000-CYF3M RUNPATH=/igo/sequencers/johnsawyers/200811_JOHNSAWYERS_0242_000000000-CYF3M DEMUX_TYPE=
Processing RUN=200807_TOMS_5396_000000000-J746K RUNNAME=TOMS_5396_000000000-J746K RUNPATH=/igo/sequencers/toms/200807_TOMS_5396_000000000-J746K DEMUX_TYPE=
Processing RUN=200811_MICHELLE_0247_AHL53KDRXX RUNNAME=MICHELLE_0247_AHL53KDRXX RUNPATH=/igo/sequencers/michelle/200811_MICHELLE_0247_AHL53KDRXX DEMUX_TYPE=
Processing RUN=200807_PITT_0490_AHHWV7BBXY RUNNAME=PITT_0490_AHHWV7BBXY RUNPATH=/igo/sequencers/pitt/200807_PITT_0490_AHHWV7BBXY DEMUX_TYPE=
Processing RUN=200807_PITT_0491_BHHY5VBBXY RUNNAME=PITT_0491_BHHY5VBBXY RUNPATH=/igo/sequencers/pitt/200807_PITT_0491_BHHY5VBBXY DEMUX_TYPE=
Processing RUN=200811_SCOTT_0196_AHJ5VFBGXF RUNNAME=SCOTT_0196_AHJ5VFBGXF RUNPATH=/igo/sequencers/scott/200811_SCOTT_0196_AHJ5VFBGXF DEMUX_TYPE=
Processing RUN=200807_AYYAN_0032_000000000-J7464 RUNNAME=AYYAN_0032_000000000-J7464 RUNPATH=/igo/sequencers/ayyan/200807_AYYAN_0032_000000000-J7464 DEMUX_TYPE=
```

## DEV
To add a new process, please follow the following steps.

### Project Structure
```
.
├── README.md
├── main.nf
├── modules
│   └── process.nf
├── nextflow.config
└── templates
    └── process.sh
```
* `templates`: Where all scripts (bash, python, etc.) will go. Don't rename this directory because nextflow is seutp to look for a directory of this name where the nextflow script is run
* `modules`: Directory containing nextflow modules that can be imported into `main.nf`

1) Add module
```
├── modules
│   └── process.nf
```
```
process {PROCESS_NAME} {
  [ directives ]

  output:
  ...
  stdout()

  shell:
  template '{PROCESS_SCRIPT}'
}
```
* You don't need to import the template script. From the documentation, "Nextflow looks for the template file in the directory templates that must exist in the same folder where the Nextflow script file is located"
* Note: Add the stdout() as an output if you would like to log the out to the configured log file

2) Add template
```
└── templates
    └── process.sh
```
* Write whatever script with the appropriate header (e.g. `#!/bin/bash`) that includes the following
	* `Nextflow Inputs`: Inputs defined as nextflow `Input` values. Add (Input) if defined in process `Input` or (Config) if defined in `nextflow.config
	* `Nextflow Outputs`: Outputs that will be defined in the execution context
	* `Run`: A sample command of how to run the script
```
#!/bin/bash
# Submits demultiplexing jobs
# Nextflow Inputs:
#   RUN_TO_DEMUX_DIR: Absolute path to directory of the Run to demux (Defined as input in nextflow process)
# Nextflow Outputs:
#   DEMUXED_RUN: Name of run to demux, given by the name of @RUN_TO_DEMUX_DIR
# Run:
#   RUN_TO_DEMUX_DIR=/igo/sequencers/michelle/200814_MICHELLE_0249_AHMNCJDRXX ./demultiplex.sh
```

3) (Optional) Add logging

In the modules, convert the exported member to a workflow that calls an included `log_out` process to log everything sent to stdout by the process. See below,
```
include log_out as out from './log_out'

process task {
  output:
  stdout()		// Add this to your outputs
  ...

  shell:
  '''
  echo "Hello World" 	// Example sent to STD OUT
  ...
  '''
}

workflow task_wkflw { 	// This is what will actually be exported
  main:
    task | out
}
```
