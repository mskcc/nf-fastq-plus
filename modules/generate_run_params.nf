include { log_out as out } from './log_out'

process task {
  input:
    env DEMUXED_RUN
  output:
    stdout()

  shell:
    template 'generate_run_params.sh'
}

workflow generate_run_params_wkflw {
  take:
    DEMUXED_RUN
  main:
    task( DEMUXED_RUN )
    out( task.out, "generate_run_params" )
}


