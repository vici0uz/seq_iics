import os
import subprocess
import argparse


def main_fn(barcode_path, code=None):

    contenido  = os.listdir(barcode_path)

    listado_directorios = []

    for item in contenido:
        if os.path.isdir(os.path.join(barcode_path, item)):
            if((item.startswith('barcode')) and not(item.endswith('a'))):
                listado_directorios.append(item)
    
    for index, item in enumerate(listado_directorios):
        # if index >0:
        #     break

        cwd = os.path.join(barcode_path, item)
        
        parent_our_dir = os.path.join(barcode_path, 'output2')
        if not os.path.exists(parent_our_dir):
            os.mkdir(parent_our_dir)
        out_dir = os.path.join(parent_our_dir, item)
        
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        files_in_directory = subprocess.run(["ls"], capture_output=True, text=True, shell=True, cwd=cwd)
        file_list = files_in_directory.stdout.split()

        
        # print(file_list)
        output_file = os.path.join(out_dir, f'{item}.gz')
        
        with open(output_file, 'w') as file:
            cat_process = subprocess.run(["cat"] +file_list, cwd=cwd, stdout=file)
        
        p = subprocess.Popen(['NanoPlot', '-t','20', '--tsv_stats', '--drop_outliers', '--fastq', f'{output_file}', '--plots', 'dot', 'kde', '-o', f'{out_dir}',  '--info_in_report', '--verbose'], cwd=cwd)
        p.wait()


parser = argparse.ArgumentParser(description='Nanoplot Wrapper')

parser.add_argument('-p','--path', help='Path to barcode dirs')
parser.add_argument('-c', '--code', help='Code')

args = parser.parse_args()

if args.path:
    main_fn(args.path)
else:
    raise ValueError('Path required')