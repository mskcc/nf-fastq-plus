# nf-fastq-plus
Generate IGO fastqs, bams, stats and fingerprinting

## Run
There are two options for running the modules in this pipeline - 
* [End-to-End](#end-to-end): Includes all demultiplexing and stats for a sequencing run
* [Stats](#stats): Runs only the stats on a specified demultiplexed directory

### [Demultiplex and Stats](#end-to-end)
**Description**: Runs end-to-end pipeline of demultiplexing and stats. The input of this is the name of the sequencing run
```
# Basic
nextflow main.nf --run ${RUN}

# Skip demultiplexing
nextflow main.nf --run ${RUN} --force true

# Run in background
nohup nextflow main.nf --run ${RUN} --force true -bg
 
# Push pipeline updates to nf-dashboard
nohup nextflow main.nf --run ${RUN} --force true -with-weblog 'http://dlviigoweb1:4500/api/nextflow/receive-nextflow-event' -bg  
```

#### Arguments `(--arg)`
* `--run`: string (required), directory name of the sequencing directory 
  > Eg: `210406_JOHNSAWYERS_0277_000000000-G7H54`
* `--force`: string (optional), skips the demultiplexing if already completed
  > Eg: `true`,  `false`

#### Options `(-opt)`
* `-bg`: run process in background 
* `-with-weblog`: publish events to an API

### [Statistics on Demultiplex Output (Skips Demultiplexing)](#stats)
**Description**: Runs stats given a demultiplex output
```
# Basic
nextflow samplesheet_stats_main.nf --ss ${SAMPLE_SHEET} --dir ${DEMULTIPLEX_DIRECTORY} 

# Run in background
nohup nextflow samplesheet_stats_main.nf --ss ${SAMPLE_SHEET} --dir ${DEMULTIPLEX_DIRECTORY} -bg  
```

#### Arguments `(--arg)`
* `--dir`: string (required), Absolute path to the directory name of the demultiplexed directory 
  > Eg: `/igo/work/FASTQ/DIANA_0333_BH53GNDRXY_i7`
* `--ss`: string (required), Absolute path to the sample sheet that CREATED the value of `--dir`
  > Eg: `/home/igo/DividedSampleSheets/SampleSheet_210407_DIANA_0333_BH53GNDRXY_i7.csv`

#### Options `(-opt)`
* `-bg`: run process in background 
                                                  
### Example Output
```
$ nextflow /igo/work/streidd/nf-fastq-plus/main.nf --run 210406_SCOTT_0325_AH2VTCBGXJ
N E X T F L O W  ~  version 20.07.1
Launching `/igo/work/streidd/nf-fastq-plus/main.nf` [infallible_descartes] - revision: c24ecac024
WARN: DSL 2 IS AN EXPERIMENTAL FEATURE UNDER DEVELOPMENT -- SYNTAX MAY CHANGE IN FUTURE RELEASE
WARN: Access to undefined parameter `force` -- Initialise it to a default value eg. `params.force = some_value`
         I G O   P I P E L I N E
==========================================
RUN=210406_SCOTT_0325_AH2VTCBGXJ
DEMUX_ALL=false

SEQUENCER_DIR="/igo/sequencers"
FASTQ_DIR=/igo/stats/NF_TESTING/FASTQ
STATS_DIR=/igo/stats/NF_TESTING/stats
STATSDONEDIR="/igo/stats/DONE"

DEMUX_LOG_FILE=/igo/stats/NF_TESTING/commands/bcl2fastq.log
LOG_FILE=/igo/stats/NF_TESTING/log/nf_fastq_run.log
CMD_FILE=/igo/stats/NF_TESTING/commands/commands.log

LAB_SAMPLE_SHEET_DIR=/pskis34/LIMS/LIMS_SampleSheets
PROCESSED_SAMPLE_SHEET_DIR=/igo/stats/NF_TESTING/DividedSampleSheets
CROSSCHECK_DIR=/home/igo/nextflow/crosscheck_metrics

DATA_TEAM_EMAIL=streidd@mskcc.org
IGO_EMAIL=streidd@mskcc.org

BWA: /opt/common/CentOS_7/bwa/bwa-0.7.17/bwa
PICARD: java -jar /home/igo/resources/picard2.21.8/picard.jar
CELL_RANGER_ATAC: /home/nabors/cellranger-atac-1.1.0/cellranger-atac

executor >  lsf (304), local (16)
[92/fece7b] process > dependency_check_wkflw:task                                                [100%] 1 of 1 ✔
[95/694167] process > dependency_check_wkflw:out                                                 [100%] 1 of 1 ✔
[0c/b7e73e] process > detect_runs_wkflw:task                                                     [100%] 1 of 1 ✔
[ef/f3c804] process > detect_runs_wkflw:out                                                      [100%] 1 of 1 ✔
[80/62c568] process > split_sample_sheet_wkflw:split_sample_sheet_task                           [100%] 1 of 1 ✔
[4e/475c03] process > split_sample_sheet_wkflw:out                                               [100%] 1 of 1 ✔
[14/f1a2a3] process > demultiplex_wkflw:task (1)                                                 [100%] 1 of 1 ✔
[12/fffb67] process > demultiplex_wkflw:out (1)                                                  [100%] 1 of 1 ✔
[a9/a410ad] process > generate_run_params_wkflw:generate_run_params_task (SCOTT_0325_AH2VTCBGXJ) [100%] 1 of 1 ✔
[2d/e1dfb9] process > generate_run_params_wkflw:out (1)                                          [100%] 1 of 1 ✔
[18/005ef1] process > generate_run_params_wkflw:create_sample_lane_jobs (14)                     [100%] 14 of 14 ✔
[ac/227a3d] process > generate_run_params_wkflw:out2 (14)                                        [100%] 14 of 14 ✔
[6a/ff5d15] process > align_to_reference_wkflw:align_to_reference_task (14)                      [100%] 14 of 14 ✔
[a1/4d1cdf] process > align_to_reference_wkflw:out (14)                                          [100%] 14 of 14 ✔
[43/d25e3e] process > merge_sams_wkflw:task (R34_T0_1_IGO_11878_14)                              [100%] 14 of 14 ✔
[09/1c1205] process > merge_sams_wkflw:out (14)                                                  [100%] 14 of 14 ✔
[b5/19c7c3] process > mark_duplicates_wkflw:task (R34_GL_2_IGO_11878_8)                          [100%] 14 of 14 ✔
[36/117ba3] process > mark_duplicates_wkflw:out (14)                                             [100%] 14 of 14 ✔
[36/df72c9] process > alignment_summary_wkflw:task (R34_GL_2_IGO_11878_8)                        [100%] 14 of 14 ✔
[19/14f0b7] process > alignment_summary_wkflw:out (14)                                           [100%] 14 of 14 ✔
[92/148ae9] process > collect_hs_metrics_wkflw:task (R34_GL_2_IGO_11878_8)                       [100%] 14 of 14 ✔
[38/6909f2] process > collect_hs_metrics_wkflw:out (14)                                          [100%] 14 of 14 ✔
[b6/b9a14c] process > collect_oxoG_metrics_wkflw:task (R34_GL_2_IGO_11878_8)                     [100%] 14 of 14 ✔
[8e/69f233] process > collect_oxoG_metrics_wkflw:out (14)                                        [100%] 14 of 14 ✔
[1f/dacf9a] process > collect_wgs_metrics_wkflw:task (R34_GL_2_IGO_11878_8)                      [100%] 14 of 14 ✔
[a6/a02bbb] process > collect_wgs_metrics_wkflw:out (14)                                         [100%] 14 of 14 ✔
[e0/82ebfa] process > collect_rna_metrics_wkflw:task (R34_GL_2_IGO_11878_8)                      [100%] 14 of 14 ✔
[45/aca57a] process > collect_rna_metrics_wkflw:out (14)                                         [100%] 14 of 14 ✔
[9a/66f99a] process > collect_gc_bias_wkflw:task (R34_GL_2_IGO_11878_8)                          [100%] 14 of 14 ✔
[79/bf3f13] process > collect_gc_bias_wkflw:out (14)                                             [100%] 14 of 14 ✔
[f5/f25d51] process > upload_stats_wkflw:task (14)                                               [100%] 14 of 14 ✔
[e6/77ee93] process > upload_stats_wkflw:email                                                   [100%] 1 of 1 ✔
[d6/fea9e9] process > upload_stats_wkflw:out (14)                                                [100%] 14 of 14 ✔
[96/2bd792] process > fingerprint_wkflw:task (1)                                                 [100%] 1 of 1 ✔
Completed at: 07-Apr-2021 10:41:25
Duration    : 15m 14s
CPU hours   : 21.4
Succeeded   : 320
```

### Logging
There are three files that log information - 
* `LOG_FILE`: All output is logged here (except commands)
* `CMD_FILE`: All stat commands are logged to this file
* `DEMUX_LOG_FILE`: All demultiplexing commands are logged here

### Outputs
See `nextflow.config` to see where data is being written 
* `FASTQ_DIR`: Directory where all demultiplexing outputs are written to
* `STATS_DIR`: Directory where stats are written to while pipeline is running
* `STATSDONEDIR`: Directory where stats ready for upload are written (`STATS_DIR` may write stats that shouldn't be uploaded) 

## DEV

Notes:
* Create a `feature/{YOUR_CHANGE}` branch for new features or `hotfix/{YOUR_FIX}` for future development
* Before merging your branch into `master`, wait for the GitHub actions to run and verify that all checks pass. **Do not merge changes if there are failed tests**. Either talk to IGO Data Team or fix the tests.
* Passing parameters is done via a params file w/ `key=value` space-delimited values. To use this file, make sure that 
the following inputs are passed to a nextflow workflow,
    ```
    # PARAMS - path channel
    # RUN_PARAMS_FILE - env variable defined in nextflow.config that is the name of PARAMS
    next_wkflw( prev_wkflw.out.PARAMS, RUN_PARAMS_FILE )
    ```
    Note - make sure to use the `.out.PARAMS` of the workflow that the `next_wkflw` should be dependent on. I've noticed 
    that nextflow won't pass all outputs of a workflow together (e.g. BAM of one task and the run params
    folder of another task) 
* Follow the project structure below -


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

3) Emit PARAM file (Only if downstream processes are dependent on the output)
* If your process is a dependency of downstream processes, emit the PARAMS file (`nextflow.config` parameter 
`RUN_PARAMS_FILE`) so that it can be read directly by the receiving channel along w/ the process's value.
```
process task {
  ...

  input:
  path PARAMS
  path INPUT
 
  output:
  path "${RUN_PARAMS_FILE}", emit: PARAMS       # Emit the same params value passed into the task
  path '*.bam', emit: VALUE

  shell:
  template 'task.sh'
}

workflow wkflw {
  take:
    PARAMS
    INPUT

  main:
    task( PARAMS, INPUT )
  
  emit:
    PARAMS = task.out.PARAMS                    # Assign PARAMS so that it's available in the main.nf
    VALUE = task.out.VALUE
}
```
* **Why?** Nextflow channels emit asynchronously. This means that upstream processes will emit and pass to the next available 
process and not necessarily the expected one. For instance, if process A emits parameters used by all downstream 
processes and process B emits the value that will be transformed by that parameter, process C will not necessarily 
receive the proccess A parameters that apply to value emited by process B because each process has an independent, 
asynchronous channel.
 
4) (Optional) Add logging

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

### Options
To run locally (instead of via LSF), modify the `nextflow.config` to be blank instead of `LSF`
```
process {
  executor=""
}
...
```

## Crontab Setup
```
# crontab -e
SHELL=/bin/bash

# Add path to bsub executable
PATH=${PATH}:/igoadmin/lsfigo/lsf10/10.1/linux3.10-glibc2.17-x86_64/bin

# Load the LSF profile prior to running the command
* * * * * . /igoadmin/lsfigo/lsf10/conf/profile.lsf; lsload; bhosts; /PATH/TO/detect_copied_sequencers.sh >> /PATH/TO/nf-fastq-plus.log 2>&1
```

## nextflow.config
Modify directory locations, binaries, etc. in this file

### Important Files
```
/igo/work/working/${RUN_NAME}/nf_${RUN_NAME}.log                # Where crontab writes work and output to
 
LOG_FILE="/home/igo/log/nf_fastq_plus/nf_fastq_run.log"         # Logs all output from the pipeline
CMD_FILE="/home/igo/log/nf_fastq_plus/commands.log"             # Logs all commands from the pipeline (e.g. was bcl2fastq run w/ 1 or 0 mistmaches?)
DEMUX_LOG_FILE="/home/igo/log/nf_fastq_plus/bcl2fastq.log"      # Logs output of bcl2fastq commands
```

### Important Directories
```
/igo/work/working/                                           # Where crontab writes work and output to
 
STATS_DIR="/igo/stats"                                       # Where final BAMS are written to
STATSDONEDIR="/igo/stats/DONE"                               # Where stat (.txt) files & cellranger ouptut is written to
PROCESSED_SAMPLE_SHEET_DIR="/home/igo/DividedSampleSheets"   # Where split samplesheets go (these are used for demuxing and stats)
LAB_SAMPLE_SHEET_DIR="/pskis34/LIMS/LIMS_SampleSheets"       # Original source of samplesheets
COPIED_SAMPLE_SHEET_DIR="/home/igo/SampleSheetCopies"        # Where original samplesheets are copied to
CROSSCHECK_DIR="/home/igo/nextflow/crosscheck_metrics"       # Directory used for fingerprinting
SHARED_SINGLE_CELL_DIR="/home/igo/shared-single-cell"        # Directory used by DLP process to create metadata.yaml (should happen automatically)
```

### Other
```
LOCAL_MEM=1                                                  # GB of memory to give a process (e.g. demultiplexing) if executor=local
```
