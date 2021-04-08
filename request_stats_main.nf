nextflow.preview.dsl=2

include { request_stats_wkflw } from './request_stats';

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

println """\
                  I G O   P I P E L I N E
         ==========================================
         RUN=${RUN}
         DEMUX_ALL=${DEMUX_ALL}

         SEQUENCER_DIR="${SEQUENCER_DIR}"
         FASTQ_DIR=${FASTQ_DIR}
         STATS_DIR=${STATS_DIR}
         STATSDONEDIR="/igo/stats/DONE"

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
  request_stats_wkflw()
}
