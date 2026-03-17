process BAM_QC {
    tag "$sample"

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}.flagstat.txt"), emit: flagstat
    tuple val(sample), path("${sample}.depth.tsv"), emit: depth

    script:
    """
    samtools flagstat ${bam} > ${sample}.flagstat.txt
    samtools depth -a ${bam} > ${sample}.depth.tsv
    """
}
