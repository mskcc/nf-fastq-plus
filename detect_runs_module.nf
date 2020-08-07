RUN_AGE=60
RUNS_TO_DEMUX_FILE="Run_to_Demux.txt"
SEQUENCER_DIR="/igo/sequencers"

process DETECT_RUNS {
  output: 
  file "Run_to_Demux.txt"

  shell:
  '''
  sequencer_files=( !{SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
    !{SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
    !{SEQUENCER_DIR}/kim/*/RTAComplete.txt
    !{SEQUENCER_DIR}/momo/*/RTAComplete.txt
    !{SEQUENCER_DIR}/toms/*/RTAComplete.txt
    !{SEQUENCER_DIR}/vic/*/RTAComplete.txt
    !{SEQUENCER_DIR}/diana/*/CopyComplete.txt
    !{SEQUENCER_DIR}/michelle/*/CopyComplete.txt
    !{SEQUENCER_DIR}/jax/*/SequencingComplete.txt
    !{SEQUENCER_DIR}/pitt/*/SequencingComplete.txt
    !{SEQUENCER_DIR}/scott/*/RunCompletionStatus.xml
    !{SEQUENCER_DIR}/ayyan/*/RTAComplete.txt
  )
  
  for file in ${sequencer_files[@]}; do
    find $(ls $file) -mmin -!{RUN_AGE} >> !{RUNS_TO_DEMUX_FILE}
  done
  '''
}
