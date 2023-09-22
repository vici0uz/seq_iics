#!/home/user/miniconda3/bin/python
import os
import subprocess
import argparse
import csv

def mysplit(s):
    head = s.rstrip('0123456789')
    tail = s[len(head):]
    return head, tail

def getVal(num, tab):
    for index, row in enumerate(tab):
        if index >0:		
            if int(row['barcode']) == num:
                return row['sample'].split('/')[0]


def main_fn(barcode_path, samples):
    contenido  = os.listdir(barcode_path)
    listado_directorios = []
    filas = []
    code_names = []
    path_samples = os.path.join(barcode_path, samples)
    with open(path_samples, 'r') as samples_file:
        samples_reader =  csv.DictReader(samples_file,['sample', 'barcode'], delimiter="\t")
        for row in samples_reader:
            filas.append(row)
    for item in contenido:
        if os.path.isdir(os.path.join(barcode_path, item)):
            if((item.startswith('barcode')) and not(item.endswith('a'))):
                listado_directorios.append(item)
    
    for index, item in enumerate(listado_directorios):
        if index >1:
            # break
            pass
        item_data = mysplit(item)
        dir_number = int(item_data[1])
        new_file_name = getVal(dir_number, filas)
        code_names.append(new_file_name)
        cwd = os.path.join(barcode_path, item)
        parent_out_dir = os.path.join(barcode_path, 'output3')
        parent_cat_dir = os.path.join(barcode_path,'cat2')
        if not os.path.exists(parent_cat_dir):
            os.mkdir(parent_cat_dir)
        if not os.path.exists(parent_out_dir):
            os.mkdir(parent_out_dir)
        out_dir = os.path.join(parent_out_dir, item)
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        files_in_directory = subprocess.run(["ls"], capture_output=True, text=True, shell=True, cwd=cwd)
        file_list = files_in_directory.stdout.split()
       
        output_file = os.path.join(parent_cat_dir, f'{new_file_name}.gz')
        
        with open(output_file, 'w') as file:
            cat_process = subprocess.run(["cat"] +file_list, cwd=cwd, stdout=file)
        p = subprocess.Popen(['NanoPlot', '-t','20', '--tsv_stats', '--drop_outliers', '--fastq', f'{output_file}', '--plots', 'dot', 'kde', '-o', f'{out_dir}',  '--info_in_report', '--verbose'], cwd=cwd)
        p.wait()
    print(code_names)


parser = argparse.ArgumentParser(description='Nanoplot Wrapper')

parser.add_argument('-p','--path', help='Path to barcode dirs')
parser.add_argument('-s', '--samples', help='Samples')

args = parser.parse_args()

if args.path and args.samples:
    main_fn(args.path, args.samples)
else:
    raise ValueError('Path required')