process FASTQC_RAW {
    tag "$sample"

    input:
    tuple val(sample), path(reads)

    output:
    path("*_fastqc.zip"), emit: fastqc_zip
    path("*_fastqc.html"), emit: fastqc_html

    script:
    def input_reads = reads.join(' ')
    """
    fastqc -t ${params.threads} ${input_reads}
    """
}

process FASTQC_TRIMMED {
    tag "$sample"

    input:
    tuple val(sample), path(reads)

    output:
    path("*_fastqc.zip"), emit: fastqc_zip
    path("*_fastqc.html"), emit: fastqc_html

    script:
    def input_reads = reads.join(' ')
    """
    fastqc -t ${params.threads} ${input_reads}
    """
}
