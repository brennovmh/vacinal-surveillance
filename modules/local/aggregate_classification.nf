process AGGREGATE_CLASSIFICATION {
    tag "aggregate_classification"

    input:
    path(summary_files)
    path(detail_files)

    output:
    path("classification_summary.tsv"), emit: summary_tsv
    path("classification_details.tsv"), emit: details_tsv

    script:
    """
    python ${projectDir}/bin/aggregate_classification.py \
      --summaries ${summary_files.join(' ')} \
      --details ${detail_files.join(' ')} \
      --out-summary classification_summary.tsv \
      --out-details classification_details.tsv
    """
}
