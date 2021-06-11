include { retrieve_all_sample_runs_wkflw } from './retrieve_all_sample_runs';

workflow create_sample_bams_wkflw {
  take:
    DEMUXED_DIR
    ARCHIVED_DIR

  main:
    retrieve_all_sample_runs_wkflw( DEMUXED_DIR, ARCHIVED_DIR )
    retrieve_all_sample_runs_wkflw.out.RUNS_TO_ALIGN_FILE
        .splitText()
        .multiMap { it ->
            RUN_DEMUX_DIR: it.split(' ')[0]
            RUN_SAMPLE_SHEET: it.split(' ')[1]
            BAM_DIR: it.split(' ')[2]
        }
        .set{ related_runs_ch }
}
