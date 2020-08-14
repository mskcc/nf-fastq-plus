nextflow.preview.dsl=2

include detect_runs_wkflw from './modules/detect_runs';
include get_software_versions_wkflw from './modules/get_software_versions';

println """\
                  I G O   P I P E L I N E
         ==========================================
         SEQUENCER_DIR="${SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${RUNS_TO_DEMUX_FILE}"

         VERSIONS
         BWA: ${bwa}
         PICARD: ${picard}

         Output=${PIPELINE_OUT}
         Log=${LOG_FILE}
         """
         .stripIndent()

workflow {
  main:
    get_software_versions_wkflw()
    detect_runs_wkflw( get_software_versions_wkflw.out )
}
