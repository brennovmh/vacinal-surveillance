process BAM_QC {
    tag "$sample"

    input:
    tuple val(sample), path(bam)

    output:
    path("${sample}.flagstat.txt"), emit: flagstat
    path("${sample}.depth.tsv"), emit: depth

    script:
    """
    samtools flagstat ${bam} > ${sample}.flagstat.txt
    samtools depth -a ${bam} > ${sample}.depth.tsv
    """
}
