include { generate_run_params_wkflw } from './generate_run_params';
include { align_to_reference_wkflw } from './align_to_reference';
include { add_or_replace_read_groups_wkflw } from './add_or_replace_read_groups';
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
    RUN
    RUNNAME
    DEMUXED_DIR
    SAMPLESHEET

  main:
    generate_run_params_wkflw( RUNNAME, DEMUXED_DIR, SAMPLESHEET, RUN_PARAMS_FILE )
    align_to_reference_wkflw( generate_run_params_wkflw.out.LANE_PARAM_FILES, RUN_PARAMS_FILE, CMD_FILE )
    merge_sams_wkflw( align_to_reference_wkflw.out.PARAMS, align_to_reference_wkflw.out.SAM_CH, align_to_reference_wkflw.out.OUTPUT_ID )
    // mark_duplicates_wkflw will output the input BAM if MD=no, otherwise it will output the MD BAM
    mark_duplicates_wkflw( merge_sams_wkflw.out.PARAMS, merge_sams_wkflw.out.BAM_CH, merge_sams_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    alignment_summary_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    collect_hs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    collect_oxoG_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    collect_wgs_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    collect_rna_metrics_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    collect_gc_bias_wkflw( mark_duplicates_wkflw.out.PARAMS, mark_duplicates_wkflw.out.MD_BAM_CH, mark_duplicates_wkflw.out.OUTPUT_ID, SKIP_FILE_KEYWORD )
    upload_stats_wkflw( mark_duplicates_wkflw.out.METRICS_FILE, alignment_summary_wkflw.out.METRICS_FILE, collect_hs_metrics_wkflw.out.METRICS_FILE,
        collect_oxoG_metrics_wkflw.out.METRICS_FILE, collect_wgs_metrics_wkflw.out.METRICS_FILE, collect_rna_metrics_wkflw.out.METRICS_FILE, collect_gc_bias_wkflw.out.METRICS_FILE,
        RUN, STATSDONEDIR, SKIP_FILE_KEYWORD, IGO_EMAIL
    )
    fingerprint_wkflw( SAMPLESHEET, CROSSCHECK_DIR, upload_stats_wkflw.out.UPLOAD_DONE )
}
