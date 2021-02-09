include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env RUN
    env DEMUX_ALL
    env SEQUENCER_DIR
    env FASTQ_DIR

  output:
    stdout() 
    env RUNNAME, emit: RUNNAME
    env RUNPATH, emit: RUNPATH

  shell:
    template 'detect_runs.sh'
}

workflow detect_runs_wkflw {
  take:
    RUN
    DEMUX_ALL
    SEQUENCER_DIR
    FASTQ_DIR
  main:
    task( RUN, DEMUX_ALL, SEQUENCER_DIR, FASTQ_DIR )
    out( task.out[0], "detect_runs" )
  emit:
    RUNNAME = task.out.RUNNAME
    RUNPATH = task.out.RUNPATH
}


