include { log_out as refr_out } from '../utils/log_out'
include { log_out as stat_out } from '../utils/log_out'
include { demultiplex_task as stat_demultiplex_task } from '../utils/demultiplex_task'
include { demultiplex_task as refr_demultiplex_task } from '../utils/demultiplex_task'

workflow demultiplex_wkflw {
  take:
    split_sample_sheets_path
    RUN_TO_DEMUX_DIR
    DEMUX_ALL
    EXECUTOR

  main:
    // splitText() will submit each line (a split sample sheet .csv) of @split_sample_sheets_path seperately
    split_sample_sheets_path
      .splitText()
      .branch {
        refr: it.contains("REFERENCE")
        stat: ! it.contains("REFERENCE")
      }
      .set { result }

    // stat_demux_ch continues to the statistics workflow
    result.stat
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ stat_demux_ch }
    stat_demultiplex_task( stat_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, stat_demux_ch.RUNNAME )
    stat_out( stat_demultiplex_task.out[0], "demultiplex_stat" )

    // refr_demux_ch will only be demultiplexed as reference, without stats
    result.refr
      .multiMap { it ->
        SAMPLE_SHEET: it                                    // /path/to/SampleSheet.csv
        RUNNAME: it.split('/')[-1].tokenize(".")[0]         // SampleSheet
      }
      .set{ refr_demux_ch }
    refr_demultiplex_task( refr_demux_ch.SAMPLE_SHEET, RUN_TO_DEMUX_DIR, DEMUX_ALL, EXECUTOR, refr_demux_ch.RUNNAME )
    refr_out( stat_demultiplex_task.out[0], "demultiplex_refr" )

  emit:
    DEMUXED_DIR = stat_demultiplex_task.out.DEMUXED_DIR
    SAMPLESHEET = stat_demultiplex_task.out.SAMPLESHEET
}
