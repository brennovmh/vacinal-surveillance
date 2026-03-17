
nextflow.enable.dsl=2

include { FASTQC_RAW }        from './modules/local/fastqc'
include { FASTP }             from './modules/local/fastp'
include { FASTQC_TRIMMED }    from './modules/local/fastqc'
include { ALIGN }             from './modules/local/align'
include { BAM_QC }            from './modules/local/bam_qc'
include { VARIANT_CALL }      from './modules/local/variant_call'
include { CONSENSUS }         from './modules/local/consensus'
include { CLASSIFY_VACCINE }  from './modules/local/classify_vaccine'
include { MULTIQC }           from './modules/local/multiqc'

params.input         = params.input ?: 'samplesheet.csv'
params.outdir        = params.outdir ?: 'results'
params.reference     = params.reference ?: 'assets/reference.fa'
params.markers       = params.markers ?: 'assets/markers.tsv'
params.min_depth     = params.min_depth ?: 10
params.min_qual      = params.min_qual ?: 20
params.threads       = params.threads ?: 4

Channel
    .fromPath(params.input)
    .splitCsv(header: true)
    .map { row ->
        def sample = row.sample
        def reads  = row.fastq_2 ? [ file(row.fastq_1), file(row.fastq_2) ] : [ file(row.fastq_1) ]
        tuple(sample, reads)
    }
    .set { ch_samples }

workflow {
    FASTQC_RAW(ch_samples)

    FASTP(ch_samples)

    FASTQC_TRIMMED(FASTP.out.cleaned_reads)

    ALIGN(FASTP.out.cleaned_reads)

    BAM_QC(ALIGN.out.bam)

    VARIANT_CALL(ALIGN.out.bam)

    CONSENSUS(VARIANT_CALL.out.vcf, ALIGN.out.bam)

    CLASSIFY_VACCINE(
        CONSENSUS.out.consensus,
        VARIANT_CALL.out.vcf,
        BAM_QC.out.depth
    )

    MULTIQC(
        FASTQC_RAW.out.fastqc_zip.mix(FASTQC_TRIMMED.out.fastqc_zip)
            .mix(FASTP.out.fastp_json)
            .mix(BAM_QC.out.flagstat)
            .mix(CLASSIFY_VACCINE.out.summary)
    )
}
