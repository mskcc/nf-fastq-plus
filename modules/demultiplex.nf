include { log_out as out } from './log_out'

process task {
  input:
    env RUN_TO_DEMUX_DIR

  output:
    stdout()
    env DEMUXED_RUN

  shell:
    template 'demultiplex.sh'
}

workflow demultiplex_wkflw {
  take: 
    runs_to_demux_path

  main:
    // Submit each run seperately through the workflow so that each can execute independently
    runs_to_demux_path.splitText().set{ run_ch }
    task( run_ch ) 
    out( task.out[0] )

  emit:
    task.out[1]
}


