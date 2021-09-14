include { generate_run_params_wkflw } from '../workflows/generate_run_params';
include { create_run_bams_wkflw } from '../create_run_bams';
include { dragen_align_wkflw } from '../workflows/dragen_align';

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
