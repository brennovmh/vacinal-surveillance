process FASTQC_RAW {
    tag "$sample"

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    path("*_fastqc.zip"), emit: fastqc_zip
    path("*_fastqc.html"), emit: fastqc_html

    script:
    """
    fastqc -t ${params.threads} ${r1} ${r2}
    """
}

process FASTQC_TRIMMED {
    tag "$sample"

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    path("*_fastqc.zip"), emit: fastqc_zip
    path("*_fastqc.html"), emit: fastqc_html

    script:
    """
    fastqc -t ${params.threads} ${r1} ${r2}
    """
}
