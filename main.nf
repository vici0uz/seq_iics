
import groovy.json.JsonSlurper

nextflow.enable.dsl=2

params.options = 'config.json'

def jsonSlurper = new JsonSlurper()

def configFile = new File(params.options)

String configJSON = configFile.text


def myConfig = jsonSlurper.parseText(configJSON)

process nanoplot {
    input:
        myConfig
    output:
        stdout
    script:
    """
    nanoplot_wrapper.py -p ${myConfig.path} -s ${myConfig.sample}
    """
}

process getConsensus {
    input:
        tuple val(x)
    output:
        stdout
    script:
    """
    myStringArray=("${x}")
    myArray=\$(echo \$myStringArray | tr -d "[],''" )
    cd ${myConfig.path}cat2
    for i in \${myArray[@]}; do
        echo "Processing \$i"
        minimap2 -a ${myConfig.reference} \${i}.gz > \${i}.sam
        samtools view \${i}.sam > \${i}.bam
        samtools sort \${i}.sam > \${i}_sorted.bam
        samtools index \${i}_sorted.bam
        samtools mpileup -d 600000 -A -Q 0 \${i}_sorted.bam | ivar consensus -p \${i}_cns.fasta -q 20  -t 0.5 -n N
    done
    """

}

workflow {
    nanoplot | getConsensus | view
   
}
