include { log_out as out } from '../utils/log_out'

process task {
  label 'DGN'
  tag "$DGN_DEMUX"

  input:
    path RUN_PARAMS
    env DGN_DEMUX
    val DGN_DEMUX

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.bam', emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "DRAGEN_STATS.txt", emit: METRICS_FILE

  shell:
    template 'align_dragen.sh'
}

workflow align_dragen_wkflw {
  take:
    RUN_PARAMS
    DGN_DEMUX
  main:
    task( RUN_PARAMS, DGN_DEMUX, DGN_DEMUX )
    out( task.out[0], "align_dragen" )

  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    METRICS_FILE = task.out.METRICS_FILE
}
