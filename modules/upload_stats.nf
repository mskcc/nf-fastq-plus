include { log_out as out } from './log_out'

process task {
  label 'LOCAL'

  input:
    path MD_METRICS_FILE_CH
    path AM_METRICS_FILE_CH
    path HS_METRICS_FILE_CH
    path OXOG_METRICS_FILE_CH
    path WGS_METRICS_FILE_CH
    path RNA_METRICS_FILE_CH
    path GC_BIAS_METRICS_FILE_CH
    env RUN
    env STATSDONEDIR
    env SKIP_FILE_KEYWORD

  output:
    stdout()

  shell:
    template 'upload_stats.sh'
}

process email {
  label 'LOCAL'

  input:
    path MD_METRICS_FILE_CH
    path AM_METRICS_FILE_CH
    path HS_METRICS_FILE_CH
    path OXOG_METRICS_FILE_CH
    path WGS_METRICS_FILE_CH
    path RNA_METRICS_FILE_CH
    path GC_BIAS_METRICS_FILE_CH
    env RUN

  shell:
  '''
    echo ${RUN} | mail -s " Stats calculated for Run ${RUN} " streidd@mskcc.org # naborsd@mskcc.org mcmanamd@mskcc.org cobbsc@mskcc.org hubermak@mskcc.org vialea@mskcc.org 
  '''
}

workflow upload_stats_wkflw {
  take:
    MD_METRICS_FILE_CH
    AM_METRICS_FILE_CH
    HS_METRICS_FILE_CH
    OXOG_METRICS_FILE_CH
    WGS_METRICS_FILE_CH
    RNA_METRICS_FILE_CH
    GC_BIAS_METRICS_FILE_CH
    RUN
    STATSDONEDIR
    SKIP_FILE_KEYWORD

  main:
    task(
        MD_METRICS_FILE_CH,
        AM_METRICS_FILE_CH,
        HS_METRICS_FILE_CH,
        OXOG_METRICS_FILE_CH,
        WGS_METRICS_FILE_CH,
        RNA_METRICS_FILE_CH,
        GC_BIAS_METRICS_FILE_CH,
        RUN,
        STATSDONEDIR,
        SKIP_FILE_KEYWORD )
    email(
        MD_METRICS_FILE_CH.collect(),
        AM_METRICS_FILE_CH.collect(),
        HS_METRICS_FILE_CH.collect(),
        OXOG_METRICS_FILE_CH.collect(),
        WGS_METRICS_FILE_CH.collect(),
        RNA_METRICS_FILE_CH.collect(),
        GC_BIAS_METRICS_FILE_CH.collect(),
        RUN )
    out( task.out[0], "upload_stats" )
}
