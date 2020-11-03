include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path BAM_FILES
    env BAITS
    env TARGETS
    env RUNNAME

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

  main:
    task( BAM_CH, BAITS, TARGETS, RUNNAME )
    out( task.out[0], "collect_alignment-summary_metrics" )
}
