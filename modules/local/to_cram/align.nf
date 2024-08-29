
process ALIGN_PE {
    cpus 4
    memory '4 GB'
    time '4 h'
    label 'align'
    tag { "$sm" }
    publishDir "${params.outdir}/cram", mode: 'copy'

    input:
        tuple val(sm), path(f1), path(f2)
        path(ref)
        path(ref_files)

    output:
        tuple val(sm), path(cram), path(crai)

    script:
    cram = sm + '.cram'
    crai = cram + '.crai'
    """
    bwa mem -M -t ${task.cpus} -R '@RG\\tID:${sm}\\tSM:${sm}' $ref $f1 $f2 |
        samtools view -b > unsorted.bam
    samtools sort unsorted.bam -@ ${task.cpus} -n -u |
        samtools fixmate -@ ${task.cpus} -m - fixmate.bam
    samtools sort fixmate.bam -@ ${task.cpus} -u |
        samtools markdup -@ ${task.cpus} -r - markdup.bam
    samtools view -@ $task.cpus markdup.bam \\
        --reference \$(readlink $ref) \\
        -O CRAM,level=8 \\
        --output $cram##idx##$crai \\
        --write-index
    rm unsorted.bam fixmate.bam markdup.bam
    """
}

process ALIGN_SE {
    cpus 4
    memory '4 GB'
    time '4 h'
    label 'align'
    tag { "$sm" }
    publishDir "${params.outdir}/cram", mode: 'copy'

    input:
        tuple val(sm), path(fq)
        path(ref)
        path(ref_files)

    output:
        tuple val(sm), path(cram), path(crai)

    script:
    cram = sm + '.cram'
    crai = cram + '.crai'
    """
    bwa mem -M -t ${task.cpus} -R '@RG\\tID:${sm}\\tSM:${sm}' $ref $fq |
        samtools view -b > unsorted.bam
    samtools sort unsorted.bam -@ ${task.cpus} -u |
        samtools markdup -@ ${task.cpus} -r - markdup.bam
    samtools view -@ $task.cpus markdup.bam \\
        --reference \$(readlink $ref) \\
        -O CRAM,level=8 \\
        --output $cram##idx##$crai \\
        --write-index
    rm unsorted.bam markdup.bam
    """
}