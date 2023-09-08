#!/bin/bash




while getopts ":p:i:f:h" opt; do
  case $opt in
    p)
      arg_path="$OPTARG"
      echo "Option -p with argument: $arg_path"
      ;;
    i)
      arg_interval="$OPTARG"
      echo "Option -i with argument: $arg_interval"
      ;;
    f)
      arg_ref="$OPTARG"
      echo "Option -f with argument: $arg_ref"
      ;;
    \?|h)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

cd $arg_path
num=$((arg_interval))
echo "Exec..."
# num = $((arg_code))
# for i in $(seq 01 $num); do 
# for i in ${01..$num}; do
#     echo "$i";
# done
for i in $(seq -w 1 "$num"); do
    echo "Procesing $i"
    # minimap2 -a MK073885_ref.fasta barcode${i}.gz > barcode${i}.sam
    minimap2 -a $arg_ref barcode${i}.gz > barcode${i}.sam
    samtools view barcode${i}.sam > barcode${i}.bam
    samtools sort barcode${i}.sam > barcode${i}_sorted.bam
    samtools index barcode${i}_sorted.bam
    samtools mpileup -d 600000 -A -Q 0 barcode${i}_sorted.bam | ivar consensus -p barcode${i}_cns.fasta -q 20  -t 0.5 -n N
done



# for i in {01..01}; do
#     bcftools mpileup -Ou -f  MK073885_ref.fasta barcode${i}_sorted.bam | bcftools call -c | vcfutils.pl vcf2fq > barcode${i}_cns.fastq;
# done

# while IFS= read -r number; do
#     echo "Processing number: $number"
# done < <(seq "$start" "$final")

# for i in {01..11}; do seqtk seq -aQ64 -q20 -n N barcode${i}_cns.fastq > barcode${i}_cns.fasta; done



# for i in {1..11}; do minimap2 -a ref_norogii.fasta sample${i}.fastq > sample${i}.sam; done
# DIR="/home/user/Documents/Maga/analisis_nov/nov_sup_barcoded/cat"
# cd $DIR;
# echo $DIR
# bcftools call -mv -Ob -o calls.bcf
# bcftools call -c 