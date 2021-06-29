include { log_out as out } from '../utils/log_out'

// We specifically name it "align_to_reference_task" so that it can be identified in nextflow.config to run locally
// and submit to the LSF cluster outside of nextflow
process align_to_reference_task {
  input:
    path LANE_PARAM_FILES
    env RUN_PARAMS_FILE
    env CMD_FILE
    env BWA
    env PICARD
    env EXECUTOR

  output:
    stdout()
    path "${RUN_PARAMS_FILE}", emit: PARAMS
    path '*RGP.sam', optional: true, emit: SAM_CH

  shell:
    template 'align_to_reference.sh'
}

workflow align_to_reference_wkflw {
  take:
    LANE_PARAM_FILES
    RUN_PARAMS_FILE
    CMD_FILE
    BWA
    PICARD
    EXECUTOR
  main:
    align_to_reference_task( LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE, BWA, PICARD, EXECUTOR )
    out( align_to_reference_task.out[0], "align_to_reference" )

  emit:
    PARAMS = align_to_reference_task.out.PARAMS
    SAM_CH = align_to_reference_task.out.SAM_CH
}
