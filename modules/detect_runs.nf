include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
  env DEMUX_ALL
  env IS_READY

  output:
  path "${RUNS_TO_DEMUX_FILE}"
  stdout()

  shell:
  template 'detect_runs.sh'
}

workflow detect_runs_wkflw {
  take:
    DEMUX_ALL
    IS_READY	// Dependency input, used to make previous workflow go first
  main:
    task( DEMUX_ALL, IS_READY )
    out( task.out[1] )
  emit:
    task.out[0]
}


