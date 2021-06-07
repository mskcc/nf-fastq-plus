/**
 * Creates the sample BAMs for a specific run
 */
include { generate_run_params_wkflw } from './generate_run_params';
include { create_sample_lane_jobs_wkflw } from './create_sample_lane_jobs';
include { align_to_reference_wkflw } from './align_to_reference';
include { merge_sams_wkflw } from './merge_sams';
include { mark_duplicates_wkflw } from './mark_duplicates';

workflow create_run_bams_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    STATSDONEDIR

  main:
    generate_run_params_wkflw( DEMUXED_DIR, SAMPLESHEET, RUN_PARAMS_FILE )
    create_sample_lane_jobs_wkflw( generate_run_params_wkflw.out.SAMPLE_FILE_CH, RUN_PARAMS_FILE )
    align_to_reference_wkflw( create_sample_lane_jobs_wkflw.out.LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE,
      BWA, PICARD, config.executor.name )
    merge_sams_wkflw( align_to_reference_wkflw.out.PARAMS, align_to_reference_wkflw.out.SAM_CH, align_to_reference_wkflw.out.OUTPUT_ID,
      RUN_PARAMS_FILE, CMD_FILE, PICARD, STATS_DIR )
    // mark_duplicates_wkflw will output the input BAM if MD=no, otherwise it will output the MD BAM
    mark_duplicates_wkflw( merge_sams_wkflw.out.PARAMS, merge_sams_wkflw.out.BAM_CH, merge_sams_wkflw.out.OUTPUT_ID,
      RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR, STATS_DIR )

  emit:
    BAM_CH = mark_duplicates_wkflw.out.BAM_CH
    OUTPUT_ID = mark_duplicates_wkflw.out.OUTPUT_ID
    PARAMS = mark_duplicates_wkflw.out.PARAMS
    METRICS_FILE = mark_duplicates_wkflw.out.METRICS_FILE
    RUNNAME = generate_run_params_wkflw.out.RUNNAME
}
