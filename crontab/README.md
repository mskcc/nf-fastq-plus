# Crontab Setup

## Kickoff
`nf-fastq-plus/crontab/detect_copied_sequencers.sh`
* Runs every hour
* Identifies sequencing runs that are ready for demultiplexing and kicks of nextflow pipeline
* Writes to `working` directory

## Cleanup
* Runs every day at midnight
* Cleans `working` directory of old nextflow directories

```
0 0 * * * sh /PATH/TO/nf-fastq-plus/crontab/cleanup_working.sh >> /PATH/TO/nf-fastq-plus/crontab/cleanup_working.log 2>&1 
0 * * * * sh /PATH/TO/nf-fastq-plus/crontab/detect_copied_sequencers.sh >> /PATH/TO/nf-fastq-plus/crontab/detect_copied_sequencers.log 2>&1
```
