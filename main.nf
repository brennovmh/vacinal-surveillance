nextflow.enable.dsl = 2

include { FASTQC_RAW }              from './modules/local/fastqc'
include { FASTP }                   from './modules/local/fastp'
include { FASTQC_TRIMMED }          from './modules/local/fastqc'
include { ALIGN }                   from './modules/local/align'
include { BAM_QC }                  from './modules/local/bam_qc'
include { VARIANT_CALL }            from './modules/local/variant_call'
include { CONSENSUS }               from './modules/local/consensus'
include { CLASSIFY_VACCINE }        from './modules/local/classify_vaccine'
include { AGGREGATE_CLASSIFICATION } from './modules/local/aggregate_classification'
include { BUILD_REPORT_ASSETS }     from './modules/local/build_report_assets'
include { MULTIQC }                 from './modules/local/multiqc'

params.input        = params.input ?: 'samplesheet.csv'
params.outdir       = params.outdir ?: 'results'
params.reference    = params.reference ?: 'assets/reference.fa'
params.markers      = params.markers ?: 'assets/markers.tsv'
params.min_depth    = params.min_depth ?: 10
params.min_qual     = params.min_qual ?: 20
params.threads      = params.threads ?: 4
params.multiqc_config = params.multiqc_config ?: 'assets/multiqc_config.yaml'

Channel
    .fromPath(params.input, checkIfExists: true)
    .splitCsv(header: true)
    .map { row ->
        tuple(
            row.sample as String,
            file(row.fastq_1, checkIfExists: true),
            file(row.fastq_2, checkIfExists: true)
        )
    }
    .set { ch_samples }

workflow {

    FASTQC_RAW(ch_samples)

    FASTP(ch_samples)

    FASTQC_TRIMMED(FASTP.out.cleaned_reads)

    ALIGN(FASTP.out.cleaned_reads)

    BAM_QC(ALIGN.out.bam)

    VARIANT_CALL(ALIGN.out.bam)

    ch_vcf_bam = VARIANT_CALL.out.vcf.join(ALIGN.out.bam, by: 0)
    CONSENSUS(ch_vcf_bam)

    ch_classify_input = CONSENSUS.out.consensus
        .join(VARIANT_CALL.out.vcf, by: 0)
        .join(BAM_QC.out.depth, by: 0)
        .map { sample, consensus, vcf, depth ->
            tuple(sample, consensus, vcf, depth)
        }

    CLASSIFY_VACCINE(ch_classify_input)

    AGGREGATE_CLASSIFICATION(CLASSIFY_VACCINE.out.summary.collect(),
                             CLASSIFY_VACCINE.out.details.collect())

    BUILD_REPORT_ASSETS(AGGREGATE_CLASSIFICATION.out.summary_tsv,
                        AGGREGATE_CLASSIFICATION.out.details_tsv)

    ch_multiqc_inputs = FASTQC_RAW.out.fastqc_zip
        .mix(FASTQC_TRIMMED.out.fastqc_zip)
        .mix(FASTP.out.fastp_json)
        .mix(FASTP.out.fastp_html)
        .mix(BAM_QC.out.flagstat)
        .mix(BAM_QC.out.depth)
        .mix(AGGREGATE_CLASSIFICATION.out.summary_tsv)
        .mix(AGGREGATE_CLASSIFICATION.out.details_tsv)
        .mix(BUILD_REPORT_ASSETS.out.multiqc_files)

    MULTIQC(ch_multiqc_inputs.collect())
}
