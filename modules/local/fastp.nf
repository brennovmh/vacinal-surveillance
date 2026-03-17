process FASTP {
    tag "$sample"

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    tuple val(sample), path("${sample}_R1.clean.fastq.gz"), path("${sample}_R2.clean.fastq.gz"), emit: cleaned_reads
    path("${sample}.fastp.json"), emit: fastp_json
    path("${sample}.fastp.html"), emit: fastp_html

    script:
    """
    fastp \
      -i ${r1} \
      -I ${r2} \
      -o ${sample}_R1.clean.fastq.gz \
      -O ${sample}_R2.clean.fastq.gz \
      -j ${sample}.fastp.json \
      -h ${sample}.fastp.html \
      -w ${params.threads}
    """
}
