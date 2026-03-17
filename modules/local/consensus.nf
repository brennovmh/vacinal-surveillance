process CONSENSUS {
    tag "$sample"

    input:
    tuple val(sample), path(vcf), path(bam)

    output:
    tuple val(sample), path("${sample}.consensus.fa"), emit: consensus

    script:
    """
    cat ${params.reference} | bcftools consensus ${vcf} > ${sample}.consensus.fa
    """
}
