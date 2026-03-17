process VARIANT_CALL {
    tag "$sample"

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}.vcf.gz"), emit: vcf
    tuple val(sample), path("${sample}.vcf.gz.csi"), emit: index

    script:
    """
    bcftools mpileup -Ou -f ${params.reference} ${bam} | \
      bcftools call -mv -Oz -o ${sample}.vcf.gz

    bcftools index ${sample}.vcf.gz
    """
}
