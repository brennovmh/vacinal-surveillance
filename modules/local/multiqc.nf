process MULTIQC {
    tag "multiqc"

    input:
    path(files)

    output:
    path("multiqc_report.html")
    path("multiqc_data")

    script:
    """
    mkdir -p collected
    for f in ${files.join(' ')}; do
      cp -r \$f collected/ 2>/dev/null || true
    done

    multiqc collected \
      --config ${params.multiqc_config} \
      --outdir .
    """
}
