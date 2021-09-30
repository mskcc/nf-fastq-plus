# modules
Nextflow scripts executing pipeline

## Directory Structure
Modular nextflow scripts, composed of multiple workflows, are at the root of this directory. E.g. 
* `samplesheet_stats.nf`: Runs entire statistics workflow from a demuxed directory and samplesheet
* `create_run_bams.nf`: Creates BAM files for sample WITHIN A SINGLE RUN
* `create_sample_bams.nf`: Creates BAM files for sample ACROSS MULTIPLE RUNS 
```
modules/            # Standalone End-to-end pipeline (e.g. samplesheet_stats.nf)
├── m1.nf 
├── m2.nf
├── ...
├── utils           # Helper scripts (e.g. log_out.nf)
│   └── util.nf     
└── tasks           # Individual tasks (e.g. mark_duplicates.nf)
    ├── t1.nf
    ├── t2.nf
    └── ...
└── workflows       # Workflows composed of multiple tasks, but not standalone (e.g. bwa + picard, branching demuxes)
    ├── w1.nf
    ├── w2.nf
    └── ...
``` 
