include { log_out as out } from './log_out'

process task {
  input:
    env DEMUXED_RUN
  output:
    stdout()

  shell:
    template 'launch_stats.sh'
}

workflow launch_stats_wkflw {
  take:
    DEMUXED_RUN
  main:
    task( DEMUXED_RUN )
    out( task.out )
}


