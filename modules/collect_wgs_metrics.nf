include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path BAM_FILES
    env GTAG
    env REFERENCE
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_wgs_metrics.sh'
}

workflow collect_wgs_metrics_wkflw {
  take:
    BAM_CH
    GTAG
    REFERENCE
    RUNNAME
    RUN_TAG

  main:
    task( BAM_CH, GTAG, REFERENCE, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_wgs_metrics" )
}
