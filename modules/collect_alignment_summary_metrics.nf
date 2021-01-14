include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    path PARAMS
    path BAM_FILES

  output:
    stdout()

  shell:
    template 'collect_alignment-summary_metrics.sh'
}

workflow alignment_summary_wkflw {
  take:
    PARAMS
    BAM_FILES

  main:
    task( PARAMS, BAM_FILES )
    out( task.out[0], "collect_alignment-summary_metrics" )
}

