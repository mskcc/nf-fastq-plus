nextflow.preview.dsl=2

include DETECT_RUNS from './detect_runs_module';
params.outdir = './results'

process process_runs {
  publishDir params.outdir, mode:'move'
 
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
 
