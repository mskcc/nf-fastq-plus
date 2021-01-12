include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    path BAM_FILES
    env REFERENCE
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_alignment-summary_metrics.sh'
}

workflow alignment_summary_wkflw {
  take:
    BAM_FILES
    REFERENCE
    RUNNAME
    RUN_TAG

  main:
    task( BAM_FILES, REFERENCE, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_alignment-summary_metrics" )
}

