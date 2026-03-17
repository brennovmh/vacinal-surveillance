process CONSENSUS {
    tag "$sample"

    input:
    tuple val(sample), path(vcf)
    tuple val(sample2), path(bam)

    output:
    path("${sample}.consensus.fa"), emit: consensus

    when:
    sample == sample2

    script:
    """
    cat ${params.reference} | bcftools consensus ${vcf} > ${sample}.consensus.fa
    """
}
