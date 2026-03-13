nextflow.enable.dsl=2

process FASTQC {
    container 'biocontainers/fastqc@sha256:8ff2a75c6864edec10c92b3a085cc2f3b207107363c83772feab711d13022c3d'

    publishDir "results/fastqc", mode: 'copy'

    input:
        path reads

    output:
        path "*.html"
        path "*.zip"

    script:
    """
    mkdir -p fastqc_out
    fastqc ${reads} --outdir fastqc_out
    mv fastqc_out/*.html .
    mv fastqc_out/*.zip .
    """
}

workflow {
    reads_ch = Channel.fromPath(params.reads)
    FASTQC(reads_ch)
}