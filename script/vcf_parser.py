#!/usr/bin/env python3
import vcf
import glob
import argparse
import re
import os



def find_largest_indel():
    """
    This function parse the vcf files in the given folder and find the largest insertion / deletions (in bps)
    for all the samples. And wrie the result into the given result file (i.e. run_results.txt)

    Parameters
    ----------

    Returns
    -------
    None

    """

    parser = argparse.ArgumentParser(description = 'Parse vcf files for indels.')
    parser.add_argument('-d', '--vcf', metavar = '', required = True, help = 'Specify directory for vcf files')
    parser.add_argument('-o', '--result', metavar='', required=True, help='Specify file to attach the result')
    args = parser.parse_args()

    # non-standard situation(large insertion etc.), marked by any non 'ACGT' letter in ALT, calls for an investigation
    vcf_dir = args.vcf
    result_dict = {}
    for vcf_file in glob.glob(rf"{vcf_dir}/*.vcf"):
        sample_id = vcf_file[len(vcf_dir)+1:-4]

        with open(vcf_file, 'r', errors='ignore') as f:
            file = f.read()
        file = re.sub(r'\[|]', '_', file)  # [] causes trouble with vcf.Reader

        temp_file = vcf_file+'.temp'
        with open(temp_file, 'w') as f:
            f.write(file)

        vcf_reader = vcf.Reader(open(temp_file, 'r'))
        largest_del = 0
        largest_ins = 0
        #print (f"*********** {sample_id}")
        for record in vcf_reader:
            #print (f'REF: {record.REF}, ALT: {record.ALT}')
            ref_len = len(record.REF)
            for base in record.ALT:
                # check if there is any 'unusal case'
                #print (f"base is: {base}")
                if re.search(r'[^ACGT]', str(base)):
                    largest_ins = base # we simply assign that weird thing to largest_ins
                    break

                base_len = len(base)
                diff = base_len - ref_len
                if diff >= 0:
                    if diff > largest_ins:
                        largest_ins = diff
                else:
                    if abs(diff) > largest_del:
                        largest_del = abs(diff)

            if not isinstance(largest_ins, int):
                break  # we already found one abnormality, jump out

        #print (f"largest_del: {largest_del},  largest_ins: {largest_ins}")
        result_dict[sample_id] = (largest_ins, largest_del)

        # delete the temp files here.
        if os.path.isfile(temp_file):
            os.remove(temp_file)

    append_to_file(args.result, result_dict)


# NOTE:
# if the file we're appending to already has 'largest_insertion, largest_deletion' columns
# we will have trouble. Should put in a check for that.
# BUT because the way the .py script is ran now (in a shell script), we're fine
def append_to_file(result_file, dict):
    with open(result_file, 'r', errors='ignore') as f:
        output = []
        lines = f.readlines()
        output.append(lines[0].strip() + '\tlen_largest_insertion\tlen_largest_deletion')

        for line in lines[1:]:
            sample_id = line.split()[0]
            sample = line.split()[1]
            if sample_id in dict:
                output.append(line.strip() + f'\t{dict[sample_id][0]}\t{dict[sample_id][1]}')
            elif sample in dict:
                output.append(line.strip() + f'\t{dict[sample][0]}\t{dict[sample][1]}')
            else:
                output.append(line.strip())

    with open(result_file, 'w') as f:
        f.write('\n'.join(output))

if __name__ == "__main__":
    find_largest_indel()
    # example usage: python3 vcf_parser.py -d vcf -o vcf/run_results.txt