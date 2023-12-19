
@Grab(group='commons-io', module='commons-io', version='2.11.0')
import groovy.json.JsonSlurper
import org.apache.commons.io.FileUtils
nextflow.enable.dsl=2

// params.options = 'config.json'
params.q = false

def jsonSlurper = new JsonSlurper()
def baseDir = baseDir
systemSeparator = System.getProperty("file.separator")

def configFile = new File("${params.path}/config.json")

String[] pathList = "${params.path}".split("${systemSeparator}")
lastDir = pathList[pathList.size() - 1]
def outputDir = new File("${params.output}")
def tmpOutputDir = new File("${baseDir}/output")
String configJSON = configFile.text

def myConfig = jsonSlurper.parseText(configJSON)

timestamp = workflow.start
treshold = 0.5
depth = 600000
min_map_q = 20


if (myConfig.treshold){
    treshold = myConfig.treshold
}
if (myConfig.min_map_q) {
    min_map_q = myConfig.min_map_q
}
if (myConfig.depth) {
    depth = myConfig.depth
}

def inputPath = new File(params.path)
def inputDir = new File("${baseDir}/input")
def copyOutputFiles(){
    try{
        tmpOutputPathStr = "${baseDir}/output/${lastDir}_${timestamp.format("dd-MM-yyyy_HH_mm_ss")}"
        tmpOutputPath = new File(tmpOutputPathStr);
        
        FileUtils.copyDirectoryToDirectory(tmpOutputPath, outputDir)
    }catch(e) {
        e.printStackTrace();
    }
}

try {
        
        FileUtils.copyDirectoryToDirectory(inputPath, inputDir);
    } catch (e) {
        e.printStackTrace();
    }

process nanoplotWrapper {
    input:
        myConfig
    output:
        stdout
    script:
    """
    nanoplot_wrapper.py -p ${baseDir}/input/${lastDir} -o ${tmpOutputDir} -s ${baseDir}/input/${lastDir}/${myConfig.sample} -t ${timestamp.format("dd-MM-yyyy_HH_mm_ss")}
    """
}

process getConsensusLong {
    input:
        tuple val(x)
    output:
        stdout
    script:
    """
    myStringArray=("${x}")
    myArray=\$(echo \$myStringArray | tr -d "[],''" )
    echo \$myArray
    outputDir=${tmpOutputDir}/${lastDir}_${timestamp.format("dd-MM-yyyy_HH_mm_ss")}/cats
    cd \$outputDir
    cp ${baseDir}/input/${lastDir}/${myConfig.reference} \$outputDir

    for i in \${myArray[@]}; do
        echo "Processing \$i"
        minimap2 -a ${myConfig.reference} \${i}.gz > \${i}.sam
        samtools view \${i}.sam > \${i}.bam
        samtools sort \${i}.sam > \${i}_sorted.bam
        samtools index \${i}_sorted.bam
        #samtools mpileup -uf ${myConfig.reference} \${i}_sorted.bam | bcftools call -c | vcfutils.pl vcf2fq > \${i}_cns.fastq
        bcftools mpileup -f ${myConfig.reference} \${i}_sorted.bam | bcftools call -c | vcfutils.pl vcf2fq > \${i}_cns.fastq
        seqtk seq -aQ64 -q 20 -n N \${i}_cns.fastq > \${i}_dirty.fasta
        #bcftools mpileup -f ${myConfig.reference} \${i}_sorted.bam | bcftools call -c 

        #samtools mpileup -d ${depth} -A -Q 0 \${i}_sorted.bam | ivar consensus -p \${i}_cns.fasta -q ${min_map_q}  -t ${treshold} -n N
        # NUEVO
        #samtools fasta \${i}_sorted.bam > \${i}_converted.fasta
        #/usr/local/bin/quast.py -r ${myConfig.reference} -g ${myConfig.genes} \${i}_converted.fasta
        ## ELIMINA LA PRIMERA LINEA Y LE AGREGA LA CORRECTA
        tail -n +2 "\${i}_dirty.fasta" > \${i}_cns.fasta
        sed -i "1i >\${i}" \${i}_cns.fasta
    done
    """
}
// quast
process assemblyQualityControl {
    script:
    """
    echo 
    """
}

process nanoplot {
    input:
        myConfig
    output:
        stdout
    script:
    """
    nanoplot_wrapper.py -p ${myConfig.path} -s ${myConfig.sample} -o ${params.output}
    """
}

workflow {
    
    nanoplotWrapper | getConsensusLong | copyOutputFiles() | view
}
