include { demultiplex_bcl2fastq_task as stats_demultiplex_task }        from '../tasks/demultiplex_bcl2fastq_task'
include { log_out as stats_out }                                        from '../utils/log_out'

include { demultiplex_bcl2fastq_task as reference_demultiplex_task }    from '../tasks/demultiplex_bcl2fastq_task'
include { log_out as reference_out }                                    from '../utils/log_out'

include { demultiplex_dragen_task as demultiplex_wgs_task }             from '../tasks/demultiplex_dragen_task'
include { log_out as dragen_wgs_out }                                   from '../utils/log_out'

include { demultiplex_dragen_task as dgn_ppg_demultiplex_task }         from '../tasks/demultiplex_dragen_task'
include { log_out as dragen_ppg_out }                                   from '../utils/log_out'

workflow demultiplex_wkflw {
  take:
    split_sample_sheets_path
    RUN_TO_DEMUX_DIR
    DEMUX_ALL
    EXECUTOR

  main:
    // BRANCH - Demultiplex jobs. Input file is scattered w/ splitText() to DEMUX options - stats, dragen, or reference
    //
    //         [STANDARD]
    //            stats:        bcl2fastq demultiplexing for stats (most cases)
    //         [SPECIAL CASES]
    //            wgs:          DRAGEN demultiplexing for WGS-stats
    //            dgn_ppg:      DRAGEN demultiplexing for PED-PEG stats ("_PPG.csv" should go through stats)
    //            reference:    bcl2fastq demultiplexing, NOT for stats
    //
    //         * NOTE - Order matters, make sure "stats" is the last "catch-all" one
    //
    // @param path, split_sample_sheets_path: A line-delimited file of paths to samplesheets
    split_sample_sheets_path
      .splitText()
      .branch {
        wgs: it.contains("_WGS.csv")
        dgn_ppg: it.contains("_DGNPPG.csv")
        reference: it.contains("REFERENCE")
        stats: ! it.contains("REFERENCE")
      }
      .set { samplesheet_ch }

    samplesheet_ch.stats                                    // Most Samplesheets should go through this
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ stats_demux_ch }
    stats_demultiplex_task( stats_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, stats_demux_ch.RUNNAME )
    stats_out( stats_demultiplex_task.out[0], "demultiplex_stats" )

    samplesheet_ch.dgn_ppg                                  // [SPECIAL] Copy of "_PPG.csv" to get DRAGEN stats quickly
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ dgn_ppg_demux_ch }
    dgn_ppg_demultiplex_task( dgn_ppg_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, dgn_ppg_demux_ch.RUNNAME )
    dragen_ppg_out( dgn_ppg_demultiplex_task.out[0], "demultiplex_dragen_ppg" )

    samplesheet_ch.wgs                                      // [SPECIAL] We send WGS to DRAGEN for demultiplexing
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ wgs_demux_ch }
    demultiplex_wgs_task( wgs_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, wgs_demux_ch.RUNNAME )
    dragen_wgs_out( demultiplex_wgs_task.out[0], "demultiplex_dragen_wgs" )

    samplesheet_ch.reference                                // [SPECIAL] Reference demux will NOT proceed to stats
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ refr_demux_ch }
    reference_demultiplex_task( refr_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, refr_demux_ch.RUNNAME )
    reference_out( reference_demultiplex_task.out[0], "demultiplex_reference" )

    // COMBINE - Demultiplex Outputs
    stats_demultiplex_task.out.DEMUXED_DIR
      .mix( demultiplex_wgs_task.out.DEMUXED_DIR )
      .mix( dgn_ppg_demultiplex_task.out.DEMUXED_DIR )
      .set{ DEMUXED_DIR }
    stats_demultiplex_task.out.SAMPLESHEET
      .mix( demultiplex_wgs_task.out.SAMPLESHEET )
      .mix( dgn_ppg_demultiplex_task.out.SAMPLESHEET )
      .set{ SAMPLESHEET }

  emit:
    DEMUXED_DIR = DEMUXED_DIR
    SAMPLESHEET = SAMPLESHEET
}
