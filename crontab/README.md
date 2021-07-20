# Crontab Setup

```
0 0 * * * sh /PATH/TO/nf-fastq-plus/crontab/cleanup_working.sh >> /PATH/TO/nf-fastq-plus/crontab/cleanup_working.log 2>&1 
0 * * * * sh /PATH/TO/nf-fastq-plus/crontab/detect_copied_sequencers.sh >> /PATH/TO/nf-fastq-plus/crontab/detect_copied_sequencers.log 2>&1
```
