include { log_out as out } from '../utils/log_out'

// We specifically name it "align_bwa_task" so that it can be identified in nextflow.config to run locally
// and submit to the LSF cluster outside of nextflow
process align_bwa_task {
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
    path '*RGP.sam', emit: SAM_CH
    env SAMPLE_TAG, emit: SAMPLE_TAG

  shell:
    template 'align_bwa.sh'
}

workflow align_bwa_wkflw {
  take:
    LANE_PARAM_FILES
    RUN_PARAMS_FILE
    CMD_FILE
    BWA
    PICARD
    EXECUTOR
  main:
    align_bwa_task( LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE, BWA, PICARD, EXECUTOR )
    out( align_bwa_task.out[0], "align_bwa" )

  emit:
    PARAMS = align_bwa_task.out.PARAMS
    SAM_CH = align_bwa_task.out.SAM_CH
    OUTPUT_ID = align_bwa_task.out.SAMPLE_TAG
}
