include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path BAM_FILES
    env BAITS
    env TARGETS
    env MSKQ
    env REFERENCE
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_oxoG_metric.sh'
}

workflow collect_oxoG_metrics_wkflw {
  take:
    BAM_CH
    BAITS
    TARGETS
    MSKQ
    REFERENCE
    RUNNAME
    RUN_TAG

  main:
    task( BAM_CH, BAITS, TARGETS, MSKQ, REFERENCE, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_oxoG_metrics" )
}
