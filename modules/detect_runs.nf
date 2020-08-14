include log_out as out from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'move'

  output:
  path "${RUNS_TO_DEMUX_FILE}"
  stdout()

  shell:
  template 'detect_runs.sh'
}

workflow detect_runs_wkflw {
  main:
    task()
    out( task.out[1] )
}


