#!/bin/bash


# for i in {1..11}; do minimap2 -a ref_norogii.fasta sample${i}.fastq > sample${i}.sam; done
DIR="/home/user/Documents/Maga/analisis_nov/nov_sup_barcoded/cat"
cd $DIR;
echo $DIR
# bcftools call -mv -Ob -o calls.bcf
# bcftools call -c 

# while getopts ":path:keyword:" opt; do
#   case $opt in
#     a)
#       arg_path="$OPTARG"
#       echo "Option -a with argument: $arg_path"
#       ;;
#     b)
#       echo "Option -b"
#       ;;
#     \?)
#       echo "Invalid option: -$OPTARG"
#       ;;
#   esac
# done

# for i in {01..01}; do
#     bcftools mpileup -Ou -f  MK073885_ref.fasta barcode${i}_sorted.bam | bcftools call -c | vcfutils.pl vcf2fq > barcode${i}_cns.fastq;
# done

# while IFS= read -r number; do
#     echo "Processing number: $number"
# done < <(seq "$start" "$final")

for i in {01..11}; do seqtk seq -aQ64 -q20 -n N barcode${i}_cns.fastq > barcode${i}_cns.fasta; done
