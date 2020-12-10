include { log_out as out } from './log_out'

process task {
  memory '2 GB'

  input:
    path BAM_FILES
    env RIBO_INTER
    env REF_FLAT
    env RUNNAME
    env RUN_TAG

  output:
    stdout()

  shell:
    template 'collect_rna_metrics.sh'
}

workflow collect_rna_metrics_wkflw {
  take:
    BAM_CH
    RIBO_INTER
    REF_FLAT
    RUNNAME
    RUN_TAG

  main:
    task( BAM_CH, RIBO_INTER, REF_FLAT, RUNNAME, RUN_TAG )
    out( task.out[0], "collect_rna_metrics" )
}
