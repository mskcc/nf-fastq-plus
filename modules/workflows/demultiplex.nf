include { log_out as reference_out } from '../utils/log_out'
include { log_out as stats_out } from '../utils/log_out'
include { log_out as dragen_out } from '../utils/log_out'
include { demultiplex_task as stats_demultiplex_task } from '../utils/demultiplex_task'
include { demultiplex_task as reference_demultiplex_task } from '../utils/demultiplex_task'
include { dgn_demultiplex_task } from '../utils/dgn_demultiplex_task'

workflow demultiplex_wkflw {
  take:
    split_sample_sheets_path
    RUN_TO_DEMUX_DIR
    DEMUX_ALL
    EXECUTOR

  main:

    // BRANCH - Demultiplex jobs. Input file is scattered w/ splitText() to DEMUX options - stats, dragen, or reference
    //            stats:        Standard method of demultiplexing for stats
    //            dragen:       DRAGEN method of demultiplexing for stats
    //            reference:    Standard method of demultiplexing, NOT for stats
    //
    // @param path, split_sample_sheets_path: A line-delimited file of paths to samplesheets
    split_sample_sheets_path
      .splitText()
      .branch {
        reference: it.contains("REFERENCE")
        stats: ! it.contains("REFERENCE") && ! it.contains("_WGS.csv")
        dragen: it.contains("_WGS.csv")
      }
      .set { samplesheet_ch }
    samplesheet_ch.stats
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ stats_demux_ch }
    stats_demultiplex_task( stats_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, stats_demux_ch.RUNNAME )
    stats_out( stats_demultiplex_task.out[0], "demultiplex_stats" )

    samplesheet_ch.dragen
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ dgn_demux_ch }
    dgn_demultiplex_task( dgn_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, EXECUTOR, dgn_demux_ch.RUNNAME )
    dragen_out( dgn_demultiplex_task.out[0], "demultiplex_dragen" )

    samplesheet_ch.reference
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // Absolute path to SampleSheet     /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // Filename minus extension         SampleSheet
      }
      .set{ refr_demux_ch }

    reference_demultiplex_task( refr_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, refr_demux_ch.RUNNAME )
    reference_out( reference_demultiplex_task.out[0], "demultiplex_reference" )

    // BRANCH - Demultiplex Outputs
    stats_demultiplex_task.out.DEMUXED_DIR
      .mix( dgn_demultiplex_task.out.DEMUXED_DIR )
      .set{ DEMUXED_DIR }
    stats_demultiplex_task.out.SAMPLESHEET
      .mix( dgn_demultiplex_task.out.SAMPLESHEET )
      .set{ SAMPLESHEET }

  emit:
    DEMUXED_DIR = DEMUXED_DIR
    SAMPLESHEET = SAMPLESHEET
}
