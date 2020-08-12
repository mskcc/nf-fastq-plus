process detect_runs {
  publishDir PIPELINE_OUT, mode:'move'

  output:
  path "${RUNS_TO_DEMUX_FILE}"
  stdout()

  shell:
  template 'detect_runs.sh'
}
