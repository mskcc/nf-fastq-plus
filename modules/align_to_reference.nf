include { log_out as out } from './log_out'

process task {
  label 'BSUB_OPTIONS_BWA_MEM'

  input:
    path PARAMS

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.sam', emit: SAM_CH

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    PARAMS
  main:
    task( PARAMS )
    out( task.out[0], "align_to_reference" )

  emit:
    PARAMS = task.out.PARAMS
    SAM_CH = task.out.SAM_CH
}


