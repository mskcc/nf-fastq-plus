include { log_out as out } from '../utils/log_out'

process task {
  input:
    path RUN_PARAMS
    path DGN_DEMUX

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.bam', emit: BAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG
    path "DRAGEN_STATS.txt", emit: METRICS_FILE

  shell:
    template 'dragen_align.sh'
}

workflow dragen_align_wkflw {
  take:
    RUN_PARAMS
    DGN_DEMUX
  main:
    task( RUN_PARAMS, DGN_DEMUX )
    out( task.out[0], "dragen_align" )

  emit:
    PARAMS = task.out.PARAMS
    BAM_CH = task.out.BAM_CH
    OUTPUT_ID = task.out.SAMPLE_TAG
    METRICS_FILE = task.out.METRICS_FILE
}
