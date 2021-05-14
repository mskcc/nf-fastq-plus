include { generate_run_params_wkflw } from './generate_run_params';
include { create_sample_lane_jobs_wkflw } from './create_sample_lane_jobs';
include { align_to_reference_wkflw } from './align_to_reference';
include { merge_sams_wkflw } from './merge_sams';
include { mark_duplicates_wkflw } from './mark_duplicates';
include { alignment_summary_wkflw } from './collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw } from './collect_hs_metrics';
include { collect_oxoG_metrics_wkflw } from './collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw } from './collect_wgs_metrics';
include { collect_rna_metrics_wkflw } from './collect_rna_metrics';
include { collect_gc_bias_wkflw } from './collect_gc_bias_metrics';
include { upload_stats_wkflw } from './upload_stats';
include { fingerprint_wkflw } from './fingerprint';

workflow samplesheet_stats_wkflw {
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
    alignment_summary_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_hs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_oxoG_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_wgs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_rna_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_gc_bias_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    upload_stats_wkflw( mark_duplicates_wkflw.out.METRICS_FILE.collect(), alignment_summary_wkflw.out.METRICS_FILE.collect(),
        collect_hs_metrics_wkflw.out.METRICS_FILE.collect(), collect_oxoG_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_wgs_metrics_wkflw.out.METRICS_FILE.collect(), collect_rna_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_gc_bias_wkflw.out.METRICS_FILE.collect(), generate_run_params_wkflw.out.RUNNAME, STATSDONEDIR,
        IGO_EMAIL
    )
    fingerprint_wkflw( SAMPLESHEET, CROSSCHECK_DIR, upload_stats_wkflw.out.UPLOAD_DONE, CMD_FILE )
}
