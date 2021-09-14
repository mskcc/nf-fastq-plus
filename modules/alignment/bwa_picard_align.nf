/**
 * Creates the sample BAMs for a specific run
 */
include { create_sample_lane_jobs_wkflw } from '../workflows/create_sample_lane_jobs';
include { align_to_reference_wkflw } from '../workflows/align_to_reference';
include { merge_sams_wkflw } from '../workflows/merge_sams';
include { mark_duplicates_wkflw } from '../workflows/mark_duplicates';

workflow bwa_picard_align_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    STATSDONEDIR
    FILTER
    SAMPLE_FILE_CH

  main:
    create_sample_lane_jobs_wkflw( SAMPLE_FILE_CH )
    align_to_reference_wkflw( create_sample_lane_jobs_wkflw.out.LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE,
      BWA, PICARD, config.executor.name )
    merge_sams_wkflw( align_to_reference_wkflw.out.PARAMS, align_to_reference_wkflw.out.SAM_CH,
      align_to_reference_wkflw.out.OUTPUT_ID,
      RUN_PARAMS_FILE, CMD_FILE, PICARD, STATS_DIR )
    mark_duplicates_wkflw( merge_sams_wkflw.out.PARAMS, merge_sams_wkflw.out.BAM_CH, merge_sams_wkflw.out.OUTPUT_ID,
      RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR, STATS_DIR )

  emit:
    BAM_CH = mark_duplicates_wkflw.out.BAM_CH
    OUTPUT_ID = mark_duplicates_wkflw.out.OUTPUT_ID
    PARAMS = mark_duplicates_wkflw.out.PARAMS
    METRICS_FILE = mark_duplicates_wkflw.out.METRICS_FILE
}
