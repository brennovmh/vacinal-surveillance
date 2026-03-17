process CLASSIFY_VACCINE {
    tag "$consensus.baseName"

    input:
    path(consensus)
    tuple val(sample), path(vcf)
    path(depth)

    output:
    path("${sample}.classification.tsv"), emit: per_sample
    path("classification_summary.tsv"), emit: summary

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
