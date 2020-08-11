nextflow.preview.dsl=2

include DETECT_RUNS from './modules/detect_runs';

println """\
         I G O  P I P E L I N E
         ===================================
         SEQUENCER_DIR="${config.SEQUENCER_DIR}"
         RUNS_TO_DEMUX_FILE="${config.RUNS_TO_DEMUX_FILE}"

         Output=${config.RESULTS_DIR}
         """
         .stripIndent()

process process_runs {
  publishDir config.RESULTS_DIR, mode:'move'
 
  input:
  file "Run_to_Demux.txt"

  output:
  path "Run_to_Demux.txt"

  script:
  """
  cat Run_to_Demux.txt
  """
}


workflow {
  DETECT_RUNS()
  process_runs( DETECT_RUNS.out )
}
 
