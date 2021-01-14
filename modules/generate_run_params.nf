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

process splitParamsFile {
  input:
    env PARAM_LINE
  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
  script:
    cp $PARAM_LINE > !{RUN_PARAMS_FILE}
}

workflow generate_run_params_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
  main:
    task( DEMUXED_DIR, SAMPLESHEET )
    task.out.PARAMS.splitText().set{ params_ch }
    splitParamsFile( params_ch )
    out( task.out[0], "generate_run_params" )
    out( splitParamsFile.out[0], "generate_run_params" )
  emit:
    PARAMS = splitParamsFile.out.PARAMS
    FASTQ_CH = task.out.FASTQ_CH
}


