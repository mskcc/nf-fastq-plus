include { log_out as out } from '../utils/log_out'

process task {
  label 'simple_lsf_task'

  input:
    path LAUNCHED_CELLRANGER

  output:
    stdout()

  shell:
    template 'upload_cellranger.sh'
}

workflow upload_cellranger_wkflw {
  take:
    LAUNCHED_CELLRANGER
  main:
    task( LAUNCHED_CELLRANGER )
    out( task.out[0], "upload_cellranger" )
}
