nextflow.preview.dsl=2

include { samplesheet_stats_wkflw } from './modules/samplesheet_stats';

/**
 * Processes input parameters if they are specified
 */
def process_param(pm, cValue) {
  if( pm == null )
    return cValue
  return pm
}

DEMUXED_DIR=params.dir
SAMPLESHEET=params.ss
STATS_DIR=process_param(params.stats_dir, STATS_DIR)
STATSDONEDIR=process_param(params.done_dir, STATSDONEDIR)
FILTER=process_param(params.filter, "")
EXECUTOR=config.executor.name

println """\
          S A M P L E S H E E T    P I P E L I N E
         ==========================================
         EXECUTOR=${EXECUTOR}

         STATS_DIR=${STATS_DIR}
         STATSDONEDIR=${STATSDONEDIR}

         LOG_FILE=${LOG_FILE}
         CMD_FILE=${CMD_FILE}

         DATA_TEAM_EMAIL=${DATA_TEAM_EMAIL}
         IGO_EMAIL=${IGO_EMAIL}

         BWA: ${BWA}
         PICARD: ${PICARD}
         CELL_RANGER: ${CELL_RANGER}
         CELL_RANGER_ATAC: ${CELL_RANGER_ATAC}
         CELL_RANGER_CNV: ${CELL_RANGER_CNV}
         """
         .stripIndent()



workflow {
  samplesheet_stats_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER )
}
