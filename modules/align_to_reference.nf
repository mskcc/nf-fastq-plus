include { log_out as out } from './log_out'

// We specifically name it "align_to_reference_task" so that it can be identified in nextflow.config to run locally
// and submit to the LSF cluster outside of nextflow
process align_to_reference_task {
  input:
    path LANE_PARAM_FILES

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*.sam', emit: SAM_CH

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    LANE_PARAM_FILES
  main:
    task( LANE_PARAM_FILES )
    out( task.out[0], "align_to_reference" )

  emit:
    PARAMS = task.out.PARAMS
    SAM_CH = task.out.SAM_CH
}
