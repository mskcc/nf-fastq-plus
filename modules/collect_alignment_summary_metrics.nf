include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path BAM_FILES
    env REFERENCE
    env RUN_TAG
    env RUNNAME

  output:
    stdout()

  shell:
    template 'collect_alignment-summary_metrics.sh'
}

workflow alignment_summary_wkflw {
  take:
    BAM_FILES
    REFERENCE
    RUN_TAG
    RUNNAME

  main:
    task( BAM_FILES, REFERENCE, RUN_TAG, RUNNAME )
    out( task.out[0], "collect_alignment-summary_metrics" )
}

