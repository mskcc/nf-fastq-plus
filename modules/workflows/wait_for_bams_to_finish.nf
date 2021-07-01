include { log_out as out } from '../utils/log_out'

process task {
  label 'simple_lsf_task'

  input:
    path RUN_BAMS_CH
    env STATSDONEDIR
  output:
    stdout()
    path "output_bams.txt", emit: OUTPUT_BAMS
  shell:
    template 'wait_for_bams_to_finish.sh'
}

workflow wait_for_bams_to_finish_wkflw {
  take:
    RUN_BAMS_CH
    STATSDONEDIR
  main:
    task( RUN_BAMS_CH, STATSDONEDIR )
    out( task.out[0], "wait_for_bams_to_finish" )
  emit:
    OUTPUT_BAMS = task.out.OUTPUT_BAMS
}
