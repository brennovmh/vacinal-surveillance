process BUILD_REPORT_ASSETS {
    tag "build_report_assets"

    input:
    path(summary_tsv)
    path(details_tsv)

    output:
    path("multiqc_data"), emit: multiqc_files

    script:
    """
    mkdir -p multiqc_data

    python ${projectDir}/bin/build_multiqc_assets.py \
      --summary ${summary_tsv} \
      --details ${details_tsv} \
      --outdir multiqc_data
    """
}
