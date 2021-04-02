#!/usr/bin/env python3
import vcf
import glob
import argparse
import re
import os



def find_largest_indel(vcf_dir, result_file):
    """
    This function parse the vcf files in the given folder and find the largest insertion / deletions (in bps)
    for all the samples. And wrie the result into the given result file (i.e. run_results.txt)

    Parameters
    ----------
    vcf_dir: directory for the vcf files
    result_file: the file to attach the result to

    Returns
    -------
    None

    """

    # non-standard situation(large insertion etc.), marked by any non 'ACGT' letter in ALT, calls for an investigation
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

        #convert to str, b/c we're need to use string join function
        result_dict[sample_id] = (str(largest_ins), str(largest_del))

        # delete the temp files here.
        if os.path.isfile(temp_file):
            os.remove(temp_file)

    append_to_file(result_file, result_dict, '\tlen_largest_insertion\tlen_largest_deletion')


def find_reads_match_SC2ref(data_file, result_file):

    result_dict = {}
    with open(data_file, 'r', errors='ignore') as f:
        lines = f.readlines()
        for line in lines:
            record = line.strip().split()
            ID = record[0]
            if len(record) >= 2:
                result_dict[ID] = (str(round(float(record[1])*100,2)),)
            else:
                result_dict[ID] = None

    append_to_file(result_file, result_dict, '\tReads_Matching_SC2_Ref')




# NOTE:
# if the file we're appending to already has 'added_columns'
# we will have trouble. Should put in a check for that.
# BUT because the way the .py script is ran now (in a shell script), we'll be given a brand new file each time.
# So we're fine.
#
# *** The calling function need to make sure the number of columns match the number of elements in the dict's value
def append_to_file(result_file, dict, added_columns):
    with open(result_file, 'r', errors='ignore') as f:
        output = []
        lines = f.readlines()
        output.append(lines[0].strip() + added_columns)

        for line in lines[1:]:
            sample_id = line.split()[0]
            sample = line.split()[1]
            if sample_id in dict:
                #output.append(line.strip() + f'\t{dict[sample_id][0]}\t{dict[sample_id][1]}')
                output.append(line.strip() + '\t' + '\t'.join(dict[sample_id]))
            elif sample in dict:
                #output.append(line.strip() + f'\t{dict[sample][0]}\t{dict[sample][1]}')
                output.append(line.strip() + '\t' + '\t'.join(dict[sample]))
            else:
                output.append(line.strip())

    with open(result_file, 'w') as f:
        f.write('\n'.join(output))

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = 'Parse vcf files for indels.')
    parser.add_argument('-d', '--vcf', metavar = '', required = True, help = 'Specify directory for vcf files')
    parser.add_argument('-s', '--sc2', metavar = '', required = True, help = 'Specify data file for Reads Matching SC2 Ref')
    parser.add_argument('-o', '--result', metavar='', required=True, help='Specify file to attach the result')
    args = parser.parse_args()

    find_largest_indel(args.vcf, args.result)
    find_reads_match_SC2ref(args.sc2,args.result)
    # example usage: python3 vcf_parser.py -d vcf -o vcf/run_results.txt