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
    DEMUXED_RUN_DIRS
  main:
    // splitText() will submit each line of @runs_to_demux_path seperately, i.e. allows for distributed tasks
    DEMUXED_RUN_DIRS.splitText().set{ sample_sheet_ch }
    task( sample_sheet_ch )
    out( task.out[1], "generate_run_params" )
  emit:
    task.out[0]
}


