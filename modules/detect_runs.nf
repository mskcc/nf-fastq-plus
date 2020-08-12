process DETECT_RUNS {
  output:
  stdout()

  shell:
  template 'detect_runs.sh'
}
