
import groovy.json.JsonSlurper

nextflow.enable.dsl=2

// params.options = 'config.json'

def jsonSlurper = new JsonSlurper()
def baseDir = baseDir

def configFile = new File("${baseDir}/data/input/${params.data}/config.json")

String configJSON = configFile.text

def myConfig = jsonSlurper.parseText(configJSON)

timestamp = workflow.start

process nanoplotDocker {
    input:
        myConfig
    output:
        stdout
    script:
    """
    nanoplot_wrapper.py -p ${baseDir}/data/input/${params.data} -o ${baseDir}/data/output/${params.data}_${timestamp.format("dd-MM-yyyy_HH_mm_ss")} -s ${baseDir}/data/input/${params.data}/${myConfig.sample}
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
    echo \$myArray
    outputDir=${baseDir}/data/output/${params.data}_${timestamp.format("dd-MM-yyyy_HH_mm_ss")}/cats
    cd \$outputDir
    cp ${baseDir}/data/input/${params.data}/${myConfig.reference} \$outputDir
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

workflow {

    nanoplotDocker | getConsensus | view
}
