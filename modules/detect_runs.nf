include { log_out as out } from './log_out'

process task {
  publishDir PIPELINE_OUT, mode:'copy'

  input:
    env RUNNAME
    env DEMUX_ALL

  output:
    stdout() 
    env RUNNAME, emit: RUNNAME
    env RUNPATH, emit: RUNPATH

  shell:
    template 'detect_runs.sh'
}

workflow detect_runs_wkflw {
  take:
    RUNNAME
    DEMUX_ALL
  main:
    task( RUNNAME, DEMUX_ALL )
    out( task.out[0], "detect_runs" )
  emit:
    RUNNAME = task.out.RUNNAME
    RUNPATH = task.out.RUNPATH
}


