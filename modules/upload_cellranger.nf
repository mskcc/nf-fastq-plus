include { log_out as out } from './log_out'

process task {
  label 'simple_lsf_task'

  input:
    path LAUNCHED_CELLRANGER
    env CELLRANGER_WAIT_TIME

  output:
    stdout()

  shell:
    template 'upload_cellranger.sh'
}

workflow upload_cellranger_wkflw {
  take:
    LAUNCHED_CELLRANGER
    CELLRANGER_WAIT_TIME
  main:
    task( LAUNCHED_CELLRANGER, CELLRANGER_WAIT_TIME )
    out( task.out[0], "upload_cellranger" )
}
