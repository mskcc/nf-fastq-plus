include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env DEMUXED_DIR
    env SAMPLESHEET
  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.fastq.gz', emit: FASTQ_CH

  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
  main:
    task( DEMUXED_DIR, SAMPLESHEET )
    out( task.out[0], "generate_run_params" )
  emit:
    PARAMS = task.out.PARAMS
    FASTQ_CH = task.out.FASTQ_CH
}


