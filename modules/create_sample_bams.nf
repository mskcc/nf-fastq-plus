/**
 * Creates a Sample BAM by merging across all runs w/ FASTQs for that sample
 */
include { create_run_bams_wkflw }               from './create_run_bams';
include { retrieve_all_sample_runs_wkflw }      from './tasks/retrieve_all_sample_runs';
include { get_sample_merge_commands_wkflw }     from './tasks/get_sample_merge_commands';
include { wait_for_bams_to_finish_wkflw }       from './tasks/wait_for_bams_to_finish';
include { log_out as out }                      from './utils/log_out';

process task {
  label 'BSUB_OPTIONS_SMALL'

  tag "MERGE_$RUNNAME"

  input:
    env MERGE_CMD
    env CMD_FILE
    val RUNNAME

  output:
    stdout()

  shell:
    template 'run_merge_cmd.sh'
}

workflow create_sample_bams_wkflw {
  take:
    RUN_BAMS_CH
    RUNNAME
    DEMUXED_DIR
    ARCHIVED_DIR
    STATS_DIR
    STATSDONEDIR
    CMD_FILE
    SAMPLE_BAM_DIR
    FILTER
    UPLOAD_DONE

  main:
    retrieve_all_sample_runs_wkflw( DEMUXED_DIR, ARCHIVED_DIR, RUNNAME, UPLOAD_DONE )
    retrieve_all_sample_runs_wkflw.out.RUNS_TO_ALIGN_FILE
      .splitText()
      .multiMap { it ->
        RUN_DEMUX_DIR: it.split(' ')[0].trim()
        RUN_SAMPLE_SHEET: it.split(' ')[1].trim()
      }
      .set{ related_runs_ch }

    create_run_bams_wkflw( related_runs_ch.RUN_DEMUX_DIR, related_runs_ch.RUN_SAMPLE_SHEET, STATS_DIR, STATSDONEDIR, FILTER )
    create_run_bams_wkflw.out.RUN_BAMS_CH
      .splitText()
      .set{ legacy_bams_ch }
    RUN_BAMS_CH
      .splitText()
      .set{ run_bams_ch }

    run_bams_ch
      .concat( legacy_bams_ch )
      .collectFile(name: 'run_bams.txt', newLine: false)
      .set{ all_bams_file }

    wait_for_bams_to_finish_wkflw( all_bams_file )

    get_sample_merge_commands_wkflw( wait_for_bams_to_finish_wkflw.out.OUTPUT_BAMS, RUNNAME, SAMPLE_BAM_DIR )
    get_sample_merge_commands_wkflw.out.MERGE_COMMANDS
      .splitText()
      .set{ merge_cmd_ch }
    task( merge_cmd_ch, CMD_FILE, RUNNAME )
    out( task.out[0], "create_sample_bams" )
}
