include { align_bwa_picard_wkflw }      from './workflows/align_bwa_picard';
include { generate_run_params_wkflw }   from './tasks/generate_run_params';
include { align_dragen_wkflw }          from './tasks/align_dragen';

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
            bwa: it.toString() =~ /^((?!DGN___.).)*$/
        }
        .set { sample_file_ch }
    align_dragen_wkflw( sample_file_ch.dgn )
    align_bwa_picard_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER, sample_file_ch.bwa )

    // COMBINE - Alignment Outputs
    align_bwa_picard_wkflw.out.PARAMS
        .mix( align_dragen_wkflw.out.PARAMS )
        .set{ PARAMS }
    align_bwa_picard_wkflw.out.BAM_CH
        .mix( align_dragen_wkflw.out.BAM_CH )
        .set{ BAM_CH }
    align_bwa_picard_wkflw.out.OUTPUT_ID
        .mix( align_dragen_wkflw.out.OUTPUT_ID )
        .set{ OUTPUT_ID }
    align_bwa_picard_wkflw.out.METRICS_FILE
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
