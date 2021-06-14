include { create_run_bams_wkflw } from './create_run_bams';
include { alignment_summary_wkflw } from './collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw } from './collect_hs_metrics';
include { collect_oxoG_metrics_wkflw } from './collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw } from './collect_wgs_metrics';
include { collect_rna_metrics_wkflw } from './collect_rna_metrics';
include { collect_gc_bias_wkflw } from './collect_gc_bias_metrics';
include { upload_stats_wkflw } from './upload_stats';
include { fingerprint_wkflw } from './fingerprint';
include { cellranger_wkflw } from './cellranger';
include { create_sample_bams_wkflw } from './create_sample_bams';

workflow samplesheet_stats_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    STATSDONEDIR

  main:
    create_run_bams_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, STATSDONEDIR )
    alignment_summary_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_hs_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_oxoG_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_wgs_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_rna_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    collect_gc_bias_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR )
    cellranger_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH, create_run_bams_wkflw.out.OUTPUT_ID,
        CELL_RANGER_ATAC, CELL_RANGER, CELL_RANGER_CNV, RUN_PARAMS_FILE, CMD_FILE, PICARD, STATSDONEDIR  )
    upload_stats_wkflw( create_run_bams_wkflw.out.METRICS_FILE.collect(), alignment_summary_wkflw.out.METRICS_FILE.collect(),
        collect_hs_metrics_wkflw.out.METRICS_FILE.collect(), collect_oxoG_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_wgs_metrics_wkflw.out.METRICS_FILE.collect(), collect_rna_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_gc_bias_wkflw.out.METRICS_FILE.collect(), create_run_bams_wkflw.out.RUNNAME, STATSDONEDIR,
        IGO_EMAIL
    )
    create_sample_bams_wkflw( DEMUXED_DIR, ARCHIVED_DIR, STATS_DIR, STATSDONEDIR )
    fingerprint_wkflw( SAMPLESHEET, CROSSCHECK_DIR, upload_stats_wkflw.out.UPLOAD_DONE, CMD_FILE )
}
