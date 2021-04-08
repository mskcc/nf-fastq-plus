nextflow.preview.dsl=2

include { samplesheet_stats_wkflw } from './modules/samplesheet_stats';

RUN=params.RUN
RUNNAME=params.RUNNAME
DEMUXED_DIR=params.DEMUXED_DIR
SAMPLESHEET=params.SAMPLESHEET

println """\
          S A M P L E S H E E T    P I P E L I N E
         ==========================================
         RUN=${RUN}

         STATSDONEDIR="/igo/stats/DONE"

         LOG_FILE=${LOG_FILE}
         CMD_FILE=${CMD_FILE}

         CROSSCHECK_DIR=${CROSSCHECK_DIR}

         IGO_EMAIL=${IGO_EMAIL}

         BWA: ${BWA}
         PICARD: ${PICARD}
         CELL_RANGER_ATAC: ${CELL_RANGER_ATAC}
         """
         .stripIndent()



workflow {
  samplesheet_stats_wkflw( RUN, RUNNAME, DEMUXED_DIR, RUN_PARAMS_FILE, CMD_FILE, SKIP_FILE_KEYWORD, SAMPLESHEET,
    STATSDONEDIR, SKIP_FILE_KEYWORD, IGO_EMAIL )
}


