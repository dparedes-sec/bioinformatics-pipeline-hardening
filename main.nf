nextflow.enable.dsl=2

process FASTQC {
    container 'biocontainers/fastqc:v0.11.9_cv7'

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