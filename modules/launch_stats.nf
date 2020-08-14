include log_out as out from './log_out'

process task {
  output:
  stdout()

  shell:
  template 'launch_stats.sh'
}

workflow launch_stats_wkflw {
  main:
    task | out
}

