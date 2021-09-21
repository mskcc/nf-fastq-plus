nextflow.preview.dsl=2

include { samplesheet_stats_wkflw } from './modules/samplesheet_stats';
include { dependency_check_wkflw } from './modules/tasks/dependency_check';
include { detect_runs_wkflw } from './modules/tasks/detect_runs';
include { split_sample_sheet_wkflw } from './modules/tasks/split_sample_sheet';
include { demultiplex_wkflw } from './modules/workflows/demultiplex';

/**
 * Processes input parameters that are booleans
 */
def process_bool(bool) {
  if( bool == null )
    return false
  return bool.toBoolean()
}
def process_str(str) {
  if( str == null )
    return ""
  return str.toString()
}

RUN=params.run
DEMUX_ALL=process_bool(params.force)	// Whether to demux all runs, including w/ FASTQs already generated
FILTER=process_str(params.filter)
EXECUTOR=config.executor.name

println """\
                  I G O   P I P E L I N E
         ==========================================
         RUN=${RUN}
         DEMUX_ALL=${DEMUX_ALL}
         FILTER=${FILTER}

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
  detect_runs_wkflw( RUN, DEMUX_ALL )
  split_sample_sheet_wkflw( detect_runs_wkflw.out.RUNPATH )
  demultiplex_wkflw( split_sample_sheet_wkflw.out.SPLIT_SAMPLE_SHEETS, detect_runs_wkflw.out.RUNPATH, DEMUX_ALL, EXECUTOR )
  samplesheet_stats_wkflw( demultiplex_wkflw.out.DEMUXED_DIR, demultiplex_wkflw.out.SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER )
}
