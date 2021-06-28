# modules
Nextflow scripts executing pipeline

## Directory Structure
Modular nextflow scripts, composed of multiple workflows, are at the root of this directory. E.g. 
* `samplesheet_stats.nf`: Runs entire statistics workflow from a demuxed directory and samplesheet
* `create_run_bams.nf`: Creates BAM files for sample WITHIN A SINGLE RUN
* `create_sample_bams.nf`: Creates BAM files for sample ACROSS MULTIPLE RUNS 
```
modules/
├── m1.nf           # End-to-end pipeline (e.g. samplesheet_stats.nf) 
├── m2.nf
├── ...
├── utils
│   └── util.nf     # Helper scripts (e.g. log_out.nf)
└── workflows
    ├── w1.nf       # Individual workflow (e.g. align_to_reference.nf)
    ├── w2.nf
    └── ...
``` 
