process ALIGN {
    tag "$sample"

    input:
    tuple val(sample), path(r1), path(r2)

    output:
    tuple val(sample), path("${sample}.sorted.bam"), emit: bam
    path("${sample}.sorted.bam.bai"), emit: bai

    script:
    """
    bwa mem -t ${params.threads} ${params.reference} ${r1} ${r2} | \
      samtools sort -@ ${params.threads} -o ${sample}.sorted.bam

    samtools index ${sample}.sorted.bam
    """
}
