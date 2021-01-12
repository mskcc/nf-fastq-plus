include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  input:
    path BAM_CH
    env REFERENCE
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_gc_bias_metrics.sh'
}

workflow collect_gc_bias_wkflw {
  take:
    BAM_CH
    REFERENCE
    RUNNAME
    RUN_TAG
  main:
    task( BAM_CH, REFERENCE, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_gc_bias" )
}


