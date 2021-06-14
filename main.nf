nextflow.preview.dsl=2

include { dependency_check_wkflw } from './modules/dependency_check';
include { detect_runs_wkflw } from './modules/detect_runs';
include { split_sample_sheet_wkflw } from './modules/split_sample_sheet';
include { demultiplex_wkflw } from './modules/demultiplex';
include { samplesheet_stats_wkflw } from './modules/samplesheet_stats';

/**
 * Processes input parameters that are booleans
 */
def process_bool(bool) {
  if( bool == null )
    return false
  return bool.toBoolean()
}

RUN=params.run
DEMUX_ALL=process_bool(params.force)	// Whether to demux all runs, including w/ FASTQs already generated
EXECUTOR=config.executor.name

println """\
                  I G O   P I P E L I N E
         ==========================================
         RUN=${RUN}
         DEMUX_ALL=${DEMUX_ALL}

         SEQUENCER_DIR="${SEQUENCER_DIR}"
         FASTQ_DIR=${FASTQ_DIR}
         STATS_DIR=${STATS_DIR}
         STATSDONEDIR=${STATSDONEDIR}

         DEMUX_LOG_FILE=${DEMUX_LOG_FILE}
         LOG_FILE=${LOG_FILE}
         CMD_FILE=${CMD_FILE}

         LAB_SAMPLE_SHEET_DIR=${LAB_SAMPLE_SHEET_DIR}
         PROCESSED_SAMPLE_SHEET_DIR=${PROCESSED_SAMPLE_SHEET_DIR}
         CROSSCHECK_DIR=${CROSSCHECK_DIR}

         DATA_TEAM_EMAIL=${DATA_TEAM_EMAIL}
         IGO_EMAIL=${IGO_EMAIL}

         BWA: ${BWA}
         PICARD: ${PICARD}
         CELL_RANGER_ATAC: ${CELL_RANGER_ATAC}
         """
         .stripIndent()

workflow {
  dependency_check_wkflw()
  detect_runs_wkflw( RUN, DEMUX_ALL, SEQUENCER_DIR, FASTQ_DIR, DATA_TEAM_EMAIL )
  split_sample_sheet_wkflw( detect_runs_wkflw.out.RUNPATH, COPIED_SAMPLE_SHEET_DIR, PROCESSED_SAMPLE_SHEET_DIR,
    LAB_SAMPLE_SHEET_DIR, SPLIT_SAMPLE_SHEETS )
  demultiplex_wkflw( split_sample_sheet_wkflw.out.SPLIT_SAMPLE_SHEETS, split_sample_sheet_wkflw.out.RUN_TO_DEMUX_DIR,
    BCL2FASTQ, CELL_RANGER_ATAC, FASTQ_DIR, DEMUX_ALL, DATA_TEAM_EMAIL, CMD_FILE, DEMUX_LOG_FILE, EXECUTOR, LOCAL_MEM )
  samplesheet_stats_wkflw( demultiplex_wkflw.out.DEMUXED_DIR, demultiplex_wkflw.out.SAMPLESHEET, STATS_DIR, STATSDONEDIR )
}
