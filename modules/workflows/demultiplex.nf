include { log_out as refr_out } from '../utils/log_out'
include { log_out as stat_out } from '../utils/log_out'
include { log_out as dgn_out } from '../utils/log_out'
include { demultiplex_task as stat_demultiplex_task } from '../utils/demultiplex_task'
include { demultiplex_task as refr_demultiplex_task } from '../utils/demultiplex_task'
include { dgn_demultiplex_task } from '../utils/dgn_demultiplex_task'

workflow demultiplex_wkflw {
  take:
    split_sample_sheets_path
    RUN_TO_DEMUX_DIR
    EXECUTOR

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path
      .splitText()
      .branch {
        refr: it.contains("REFERENCE")
        stat: ! it.contains("REFERENCE") && ! it.contains("_WGS.csv")
        dgn: it.contains("_WGS.csv")
      }
      .set { result }

    // stat_demux_ch continues to the statistics workflow
    result.stat
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ stat_demux_ch }
    stat_demultiplex_task( stat_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, EXECUTOR, stat_demux_ch.RUNNAME )
    stat_out( stat_demultiplex_task.out[0], "demultiplex_stat" )

    // Send WGS SampleSheets to be demultiplexed by DRAGEN
    result.dgn
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ dgn_demux_ch }
    dgn_demultiplex_task( dgn_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, EXECUTOR, dgn_demux_ch.RUNNAME )
    dgn_out( dgn_demultiplex_task.out[0], "demultiplex_dgn" )

    // refr_demux_ch will only be demultiplexed as reference, without stats
    result.refr
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ refr_demux_ch }
    refr_demultiplex_task( refr_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, EXECUTOR, refr_demux_ch.RUNNAME )
    refr_out( stat_demultiplex_task.out[0], "demultiplex_refr" )

    // Set outputs
    stat_demultiplex_task.out.DEMUXED_DIR
      .mix( dgn_demultiplex_task.out.DEMUXED_DIR )
      .set{ DEMUXED_DIR }
    stat_demultiplex_task.out.SAMPLESHEET
      .mix( dgn_demultiplex_task.out.SAMPLESHEET )
      .set{ SAMPLESHEET }

  emit:
    DEMUXED_DIR = DEMUXED_DIR
    SAMPLESHEET = SAMPLESHEET
}
