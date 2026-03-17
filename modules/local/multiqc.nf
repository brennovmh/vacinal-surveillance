process MULTIQC {
    publishDir "${params.outdir}/report", mode: 'copy'

    input:
    path(files)

    output:
    path("multiqc_report.html")

    script:
    """
    multiqc . -o .
    """
}
