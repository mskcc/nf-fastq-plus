include { log_out as out } from './log_out'

process task {
  input:
    file runs_to_demux_file

  output:
    stdout()

  shell:
    template 'detect_runs.sh'
}

workflow demultiplex_wkflw {
  take: 
    runs_to_demux_file

  main:
    task( runs_to_demux_file ) 
    out( task.out )

  emit:
    task.out
}


