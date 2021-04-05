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
    env IGO_EMAIL

  output:
    stdout()
    path "UPLOAD_DONE.txt", emit: UPLOAD_DONE

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
    env IGO_EMAIL

  shell:
  '''
    echo "Emailing Stats Complete: ${RUN}"
    echo ${RUN} | mail -s " Stats calculated for Run ${RUN} " ${IGO_EMAIL}
    touch ${RUN}_DONE.txt
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
    IGO_EMAIL

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
        RUN,
        IGO_EMAIL )
    out( task.out[0], "upload_stats" )

  emit:
    UPLOAD_DONE = task.out.UPLOAD_DONE
}
