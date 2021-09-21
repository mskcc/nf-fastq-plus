// Takes the value of an input directory and outputs all sample sheets that should be individually processed
process demultiplex_dragen_task {
  label 'DGN'
  tag "$RUNNAME"

  input:
    env SAMPLESHEET
    env RUN_TO_DEMUX_DIR
    env DEMUX_ALL
    env EXECUTOR
    val RUNNAME

  output:
    stdout()
    env DEMUXED_DIR, emit: DEMUXED_DIR
    env SAMPLESHEET, emit: SAMPLESHEET

  shell:
    template 'demultiplex_dragen.sh'
}
