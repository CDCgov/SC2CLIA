#!/usr/bin/env python3
import argparse
import re
import os



def find_largest_indel(vcf_file):
    """
    This function parse the vcf files passed in and find the largest insertion / deletions (in bps)
    for all the samples.

    This function is to be used when the python script is used internally within the nextflow

    Parameters
    ----------
    vcf_file: name of the vcf file

    Returns
    -------
    a string of largest indel (can be string of 'can not import vcf module' if can't import vcf)
    insertion and deletion joined by '_'

    """

    # non-standard situation(large insertion etc.), marked by any non 'ACGT' letter in ALT, calls for an investigation
    sample_id = os.path.basename(vcf_file[:-4]) # don't need this actually (since we don't need the sample_id here)

    with open(vcf_file, 'r', errors='ignore') as f:
        file = f.read()
    file = re.sub(r'\[|]', '_', file)  # [] causes trouble with vcf.Reader

    temp_file = vcf_file+'.temp'
    with open(temp_file, 'w') as f:
        f.write(file)

    try:
        import vcf
    except ImportError as ie:
        return (f"can not import python vcf module_can not import python vcf module")

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

    # delete the temp files here.
    if os.path.isfile(temp_file):
        os.remove(temp_file)

    return (f"{largest_ins}_{largest_del}")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = 'Parse vcf files for indels.')
    parser.add_argument('-f', '--vcf', metavar = '', required = True, help = 'Specify vcf files')
    args = parser.parse_args()

    print(find_largest_indel(args.vcf))
    # example usage: python3 vcf_parser.py -f vcf 