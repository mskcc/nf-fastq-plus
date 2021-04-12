nextflow.preview.dsl=2

include { samplesheet_stats_wkflw } from './modules/samplesheet_stats';

DEMUXED_DIR=params.dir
SAMPLESHEET=params.ss

println """\
          S A M P L E S H E E T    P I P E L I N E
         ==========================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         FASTQ_DIR=${FASTQ_DIR}
         STATS_DIR=${STATS_DIR}
         STATSDONEDIR=${STATSDONEDIR}

         LOG_FILE=${LOG_FILE}
         CMD_FILE=${CMD_FILE}

         DATA_TEAM_EMAIL=${DATA_TEAM_EMAIL}
         IGO_EMAIL=${IGO_EMAIL}

         BWA: ${BWA}
         PICARD: ${PICARD}
         CELL_RANGER_ATAC: ${CELL_RANGER_ATAC}
         """
         .stripIndent()



workflow {
  samplesheet_stats_wkflw( DEMUXED_DIR, SAMPLESHEET )
}
