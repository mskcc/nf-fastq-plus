include { create_sample_bams_wkflw }    from './create_sample_bams';
include { create_run_bams_wkflw }       from './create_run_bams';
include { alignment_summary_wkflw }     from './tasks/collect_alignment_summary_metrics';
include { collect_hs_metrics_wkflw }    from './tasks/collect_hs_metrics';
include { collect_oxoG_metrics_wkflw }  from './tasks/collect_oxoG_metrics';
include { collect_wgs_metrics_wkflw }   from './tasks/collect_wgs_metrics';
include { collect_rna_metrics_wkflw }   from './tasks/collect_rna_metrics';
include { collect_gc_bias_wkflw }       from './tasks/collect_gc_bias_metrics';
include { upload_stats_wkflw }          from './tasks/upload_stats';
include { fingerprint_wkflw }           from './tasks/fingerprint';
include { cellranger_wkflw }            from './tasks/cellranger';
include { upload_cellranger_wkflw }     from './tasks/upload_cellranger';


workflow samplesheet_stats_wkflw {
  take:
    DEMUXED_DIR
    SAMPLESHEET
    STATS_DIR
    STATSDONEDIR
    FILTER

  main:
    create_run_bams_wkflw( DEMUXED_DIR, SAMPLESHEET, STATS_DIR, STATSDONEDIR, FILTER )
    alignment_summary_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    collect_hs_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    collect_oxoG_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    collect_wgs_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    collect_rna_metrics_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    collect_gc_bias_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    cellranger_wkflw( create_run_bams_wkflw.out.PARAMS, create_run_bams_wkflw.out.BAM_CH,
        create_run_bams_wkflw.out.OUTPUT_ID, STATSDONEDIR )
    upload_cellranger_wkflw( cellranger_wkflw.out.LAUNCHED_CELLRANGER )
    upload_stats_wkflw( create_run_bams_wkflw.out.METRICS_FILE.collect(), alignment_summary_wkflw.out.METRICS_FILE.collect(),
        collect_hs_metrics_wkflw.out.METRICS_FILE.collect(), collect_oxoG_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_wgs_metrics_wkflw.out.METRICS_FILE.collect(), collect_rna_metrics_wkflw.out.METRICS_FILE.collect(),
        collect_gc_bias_wkflw.out.METRICS_FILE.collect(), create_run_bams_wkflw.out.RUNNAME, STATSDONEDIR, IGO_EMAIL
    )
    create_sample_bams_wkflw( create_run_bams_wkflw.out.RUN_BAMS_CH, create_run_bams_wkflw.out.RUNNAME, DEMUXED_DIR,
        ARCHIVED_DIR, STATS_DIR, STATSDONEDIR, CMD_FILE, SAMPLE_BAM_DIR, FILTER,
        upload_stats_wkflw.out.UPLOAD_DONE.collect() )
    fingerprint_wkflw( SAMPLESHEET, upload_stats_wkflw.out.UPLOAD_DONE )
}
