include { log_out as out } from '../utils/log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  label 'simple_lsf_task'

  tag "$RUN_TAG"

  input:
    env DEMUXED_DIR
    env SAMPLESHEET
    val RUN_TAG
    env STATS_DIR
    env FILTER
  output:
    stdout()
    path "*${RUN_PARAMS_FILE}", optional: true, emit: PARAMS
    path "run_bams.txt", emit: RUN_BAMS_CH
    env RUNNAME, emit: RUNNAME
  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    FILTER
  main:
    task( DEMUXED_DIR, SAMPLESHEET, DEMUXED_DIR, STATS_DIR, FILTER )
    out( task.out[0], "generate_run_params" )
    task.out.PARAMS
      .flatten()
      .set{ SAMPLE_FILE_CH }
  emit:
    SAMPLE_FILE_CH = SAMPLE_FILE_CH
    RUN_BAMS_CH = task.out.RUN_BAMS_CH
    RUNNAME = task.out.RUNNAME
}
