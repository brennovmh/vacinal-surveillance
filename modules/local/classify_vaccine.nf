process CLASSIFY_VACCINE {
    tag "$sample"

    input:
    tuple val(sample), path(consensus), path(vcf), path(depth)

    output:
    path("${sample}.classification.details.tsv"), emit: details
    path("${sample}.classification.summary.tsv"), emit: summary

    script:
    """
    python ${projectDir}/bin/classify_vaccine.py \
      --sample ${sample} \
      --consensus ${consensus} \
      --vcf ${vcf} \
      --depth ${depth} \
      --markers ${params.markers} \
      --min-depth ${params.min_depth}
    """
}
