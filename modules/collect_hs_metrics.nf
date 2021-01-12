include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_SMALL'

  input:
    path BAM_FILES
    env BAITS
    env TARGETS
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_hs_metrics.sh'
}

workflow collect_hs_metrics_wkflw {
  take:
    BAM_CH
    BAITS
    TARGETS
    RUNNAME
    RUN_TAG

  main:
    task( BAM_CH, BAITS, TARGETS, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_hs_metrics" )
}
