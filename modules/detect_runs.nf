include log_out from './log_out'

process detect_runs {
  publishDir PIPELINE_OUT, mode:'move'

  output:
  path "${RUNS_TO_DEMUX_FILE}"
  stdout()

  shell:
  template 'detect_runs.sh'
}

workflow detect_runs_wkflw {
  main:
    detect_runs()
    log_out( detect_runs.out[1] )
}


