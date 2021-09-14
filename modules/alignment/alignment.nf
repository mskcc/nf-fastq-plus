include { create_run_bams_wkflw } from './create_run_bams';
include { create_sample_bams_wkflw } from './create_sample_bams';
include { alignment_summary_wkflw } from './workflows/collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw } from './workflows/collect_hs_metrics';
include { collect_oxoG_metrics_wkflw } from './workflows/collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw } from './workflows/collect_wgs_metrics';
include { collect_rna_metrics_wkflw } from './workflows/collect_rna_metrics';
include { collect_gc_bias_wkflw } from './workflows/collect_gc_bias_metrics';
include { upload_stats_wkflw } from './workflows/upload_stats';
include { fingerprint_wkflw } from './workflows/fingerprint';
include { cellranger_wkflw } from './workflows/cellranger';
include { upload_cellranger_wkflw } from './workflows/upload_cellranger';
include { generate_run_params_wkflw } from './workflows/generate_run_params';
include { dragen_align_wkflw } from './workflows/dragen_align';

workflow alignment_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    STATSDONEDIR
    FILTER

  main:
    generate_run_params_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, FILTER )

    // BRANCH - Alignment Jobs
    Channel.from( DEMUXED_DIR ).branch {
            bwa: ! it.toString().contains("_WGS")
            dgn: it.toString().contains("_WGS")
        }
        .set { dir_to_align }
    dragen_align_wkflw( generate_run_params_wkflw.out.SAMPLE_FILE_CH, dir_to_align.dgn )
    create_run_bams_wkflw( dir_to_align.bwa, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER,
        generate_run_params_wkflw.out.SAMPLE_FILE_CH )

    // COMBINE - Alignment Outputs
    create_run_bams_wkflw.out.PARAMS
        .mix( dragen_align_wkflw.out.PARAMS )
        .set{ PARAMS }
    create_run_bams_wkflw.out.BAM_CH
        .mix( dragen_align_wkflw.out.BAM_CH )
        .set{ BAM_CH }
    create_run_bams_wkflw.out.OUTPUT_ID
        .mix( dragen_align_wkflw.out.OUTPUT_ID )
        .set{ OUTPUT_ID }
    create_run_bams_wkflw.out.METRICS_FILE
        .mix( dragen_align_wkflw.out.METRICS_FILE )
        .set{ METRICS_FILE }

  emit:
    RUNNAME = generate_run_params_wkflw.out.RUNNAME
    RUN_BAMS_CH = generate_run_params_wkflw.out.RUN_BAMS_CH
    PARAMS = PARAMS
    BAM_CH = BAM_CH
    OUTPUT_ID = OUTPUT_ID
    METRICS_FILE = METRICS_FILE
}
