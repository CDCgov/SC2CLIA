#!/usr/bin/env python3
import glob
import argparse
import os
import ivar_variants_to_vcf as ivtv



def convert_tsv_to_vcf():
    """
    This function fetches all the tsv files in the given folder and calls on ivar_variants_to_vcf 
    to convert all tsv files into vcf files in the given folder

    Parameters
    ----------

    Returns
    -------
    None

    """

    parser = argparse.ArgumentParser(description = 'Parse vcf files for indels.')
    parser.add_argument('-o', '--vcf', metavar = '', required = True, help = 'Specify directory for converted vcf files')
    parser.add_argument('-i', '--tsv', metavar='', required=True, help='Specify directory for ivar tsv files')
    args = parser.parse_args()

    vcf_dir = args.vcf
    tsv_dir = args.tsv
    ivtv.make_dir(vcf_dir)

    for tsv_file in glob.glob(rf"{tsv_dir}/*.tsv"):
        sample = os.path.basename(tsv_file)[:-13]
        ivtv.ivar_variants_to_vcf(tsv_file, rf'{vcf_dir}/{sample}.vcf')
        


if __name__ == "__main__":
    convert_tsv_to_vcf()
    # example usage: python3 ivar_variants.py -i ivar_variants -o ivar_vcf