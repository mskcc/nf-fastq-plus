include { generate_run_params_wkflw } from './workflows/generate_run_params';
include { bwa_picard_align_wkflw } from './alignment/bwa_picard_align';
include { align_dragen_wkflw } from './workflows/align_dragen';

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
    generate_run_params_wkflw.out.SAMPLE_FILE_CH
        .branch {
            // it: /path/to/DGN___SAMPLEID___sample_params.txt OR /path/to/SAMPLEID___sample_params.txt
            dgn: it.toString() =~ /.*\/DGN___.*/
            bwa: it.toString() =~ /^(?!DGN).*/
        }
        .set { sample_file_ch }
    align_dragen_wkflw( sample_file_ch.dgn, DEMUXED_DIR )
    bwa_picard_align_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER, sample_file_ch.bwa )

    // COMBINE - Alignment Outputs
    bwa_picard_align_wkflw.out.PARAMS
        .mix( align_dragen_wkflw.out.PARAMS )
        .set{ PARAMS }
    bwa_picard_align_wkflw.out.BAM_CH
        .mix( align_dragen_wkflw.out.BAM_CH )
        .set{ BAM_CH }
    bwa_picard_align_wkflw.out.OUTPUT_ID
        .mix( align_dragen_wkflw.out.OUTPUT_ID )
        .set{ OUTPUT_ID }
    bwa_picard_align_wkflw.out.METRICS_FILE
        .mix( align_dragen_wkflw.out.METRICS_FILE )
        .set{ METRICS_FILE }

  emit:
    RUNNAME = generate_run_params_wkflw.out.RUNNAME
    RUN_BAMS_CH = generate_run_params_wkflw.out.RUN_BAMS_CH
    PARAMS = PARAMS
    BAM_CH = BAM_CH
    OUTPUT_ID = OUTPUT_ID
    METRICS_FILE = METRICS_FILE
}
