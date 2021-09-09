// Takes the value of an input directory and outputs all sample sheets that should be individually processed
process dgn_demultiplex_task {
  label 'DGN'
  tag "$RUNNAME"

  input:
    env SAMPLESHEET
    env RUN_sTO_DEMUX_DIR
    env EXECUTOR
    val RUNNAME

  output:
    stdout()
    env DEMUXED_DIR, emit: DEMUXED_DIR
    env SAMPLESHEET, emit: SAMPLESHEET

  shell:
    template 'dgn_demultiplex.sh'
}
