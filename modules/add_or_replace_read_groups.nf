include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_LARGE'

  input:
    path PARAMS
    path SAM_CH

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.sam', emit: SAM_CH

  shell:
    template 'add_or_replace_read_groups.sh'
}

workflow add_or_replace_read_groups_wkflw {
  take:
    PARAMS
    SAM_CH
  main:
    task( PARAMS, SAM_CH )
    out( task.out[0], "add_or_replace_read_groups" )
  emit:
    PARAMS = task.out.PARAMS
    SAM_CH = task.out.SAM_CH
}