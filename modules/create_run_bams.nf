include { generate_run_params_wkflw } from './workflows/generate_run_params';
include { bwa_picard_align_wkflw } from './alignment/bwa_picard_align';
include { dragen_align_wkflw } from './alignment/dragen_align';

workflow create_run_bams_wkflw {
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
    bwa_picard_align_wkflw( dir_to_align.bwa, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER,
        generate_run_params_wkflw.out.SAMPLE_FILE_CH )

    // COMBINE - Alignment Outputs
    bwa_picard_align_wkflw.out.PARAMS
        .mix( dragen_align_wkflw.out.PARAMS )
        .set{ PARAMS }
    bwa_picard_align_wkflw.out.BAM_CH
        .mix( dragen_align_wkflw.out.BAM_CH )
        .set{ BAM_CH }
    bwa_picard_align_wkflw.out.OUTPUT_ID
        .mix( dragen_align_wkflw.out.OUTPUT_ID )
        .set{ OUTPUT_ID }
    bwa_picard_align_wkflw.out.METRICS_FILE
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
