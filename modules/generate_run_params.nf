include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env FASTQ_DIR
  output:
    path "${RUN_PARAMS_FILE}"
    stdout()

  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    FASTQ_DIR
  main:
    task( FASTQ_DIR )
    out( task.out[1], "generate_run_params" )
  emit:
    task.out[0]
}


