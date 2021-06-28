# nf-fastq-plus
Generate IGO fastqs, bams, stats and fingerprinting

## Run
There are two options for running the modules in this pipeline - 
* [Demultiplex and Stats](#demultiplex-and-stats): Includes all demultiplexing and stats for a sequencing run
* [Stats Only](#stats-only): Runs only the stats on a specified demultiplexed directory

**Links for Developers**
* [Project Structure](#project-structure)
* [Testing](#testing)
* [Nextflow Config](#nextflow-config)
* [Crontab Setup](#crontab-setup)

### Demultiplex and Stats
**Description**: Runs end-to-end pipeline of demultiplexing and stats. The input of this is the name of the sequencing 
run
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

### Stats Only
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
                                                                                                   >
#### Options `(-opt)`
* `-bg`: run process in background 

## For Development

### Please Read:
* Create a `feature/{YOUR_CHANGE}` branch for new features or `hotfix/{YOUR_FIX}` for future development
* Before merging your branch into `master`, wait for the GitHub actions to run and verify that all checks pass. **Do not
 merge changes if there are failed tests**. Either talk to IGO Data Team or fix the tests.

### Project Structure
* Follow the project structure below -
```
.
├── README.md
├── main.nf
├── modules
│   └── m1.nf
├── nextflow.config
└── templates
    └── process.sh
```
* `templates`: Where all scripts (bash, python, etc.) will go. Don't rename this directory because nextflow is seutp to 
look for a directory of this name where the nextflow script is run
* `modules`: Directory containing nextflow modules that can be imported into `main.nf`

### Adding a new workflow
* Passing sample-specific parameters (e.g. Reference Genome, Recipe, etc.) is done via a params file w/ `key=value` 
space-delimited values. To use this file, make sure that a `{PREVIOUS_WORKFLOW}.out.PARAMS` file is passed to the 
workflow and specified as a path-type channel. Make sure to use the `.out.PARAMS` of the workflow that the `next_wkflw` 
should be dependent on. I've noticed that nextflow won't pass all outputs of a workflow together (e.g. BAM of one task 
and the run params folder of another task) 

**Steps for Adding a New Module**
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
* You don't need to import the template script. From the documentation, "Nextflow looks for the template file in the 
directory templates that must exist in the same folder where the Nextflow script file is located"
* Note: Add the stdout() as an output if you would like to log the out to the configured log file

2) Add template
```
└── templates
    └── process.sh
```
* Write whatever script with the appropriate header (e.g. `#!/bin/bash`) that includes the following
	* `Nextflow Inputs`: Inputs defined as nextflow `Input` values. Add (Input) if defined in process `Input` or 
	(Config) if defined in `nextflow.config
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
* **Why?** Nextflow channels emit asynchronously. This means that upstream processes will emit and pass to the next 
available process and not necessarily the expected one. For instance, if process A emits parameters used by all 
downstream processes and process B emits the value that will be transformed by that parameter, process C will not 
necessarily receive the proccess A parameters that apply to value emited by process B because each process has an 
independent, asynchronous channel.
 
4) (Optional) Add logging

In the modules, convert the exported member to a workflow that calls an included `log_out` process to log everything 
sent to stdout by the process. See below,
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

#### Logging
There are three files that log information - 
* `LOG_FILE`: All output is logged here (except commands)
* `CMD_FILE`: All stat commands are logged to this file
* `DEMUX_LOG_FILE`: All demultiplexing commands are logged here

### Testing 
Build the dockerfile from the root
```
docker image build -t nf-fastq-plus-playground .

# Test stats-only workflow
docker run --entrypoint /nf-fastq-plus/testPipeline/e2e/samplesheet_stats_main_test_hwg.sh -v $(pwd)/../nf-fastq-plus:/nf-fastq-plus nf-fastq-plus-playground

# Test e2e (demux & stats)
docker run --entrypoint /nf-fastq-plus/testPipeline/e2e/cellranger_demux_stats.sh -v $(pwd)/../nf-fastq-plus:/nf-fastq-plus nf-fastq-plus-playground
```

## Nextflow Config
Modify directory locations, binaries, etc. in the `nextflow.config` file

### Important Files
``` 
LOG_FILE        # Logs all output from the pipeline
CMD_FILE        # Logs all commands from the pipeline (e.g. was bcl2fastq run w/ 1 or 0 mistmaches?)
DEMUX_LOG_FILE  # Logs output of bcl2fastq commands
```

### Important Directories
```
STATS_DIR                   # Where final BAMS are written to
STATSDONEDIR                # Where stat (.txt) files & cellranger ouptut is written to
PROCESSED_SAMPLE_SHEET_DIR  # Where split samplesheets go (these are used for demuxing and stats)
LAB_SAMPLE_SHEET_DIR        # Original source of samplesheets
COPIED_SAMPLE_SHEET_DIR     # Where original samplesheets are copied to
CROSSCHECK_DIR              # Directory used for fingerprinting
SHARED_SINGLE_CELL_DIR      # Directory used by DLP process to create metadata.yaml (should happen automatically)
```

### Other
```
LOCAL_MEM                   # GB of memory to give a process (e.g. demultiplexing) if executor=local
```

## Crontab Setup
The pipeline can be kicked off automatically by the `crontab/detect_copied_sequencers.sh` script. Add the following
to enable the crontab
```
# crontab -e
SHELL=/bin/bash

# Add path to bsub executable
PATH=${PATH}:/igoadmin/lsfigo/lsf10/10.1/linux3.10-glibc2.17-x86_64/bin

# Load the LSF profile prior to running the command
* * * * * . /igoadmin/lsfigo/lsf10/conf/profile.lsf; lsload; bhosts; /PATH/TO/detect_copied_sequencers.sh >> /PATH/TO/nf-fastq-plus.log 2>&1
```
