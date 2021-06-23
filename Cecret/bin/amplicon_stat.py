#!/usr/bin/env python3
import glob
import argparse
import re
import os



def find_amplicon_dropout():
    """
    This function parse the ampliconstats.txt files in the given folder and extract FDEPTH, and FPCOV
    for all the samples. And wrie the result into the given folder (one file per sample)

    usage: python3 amplicon_stat.py -d $OUTDIR/samtools_ampliconstats -o $OUTDIR/amplicon_dropout_summary

    Parameters
    ----------

    Returns
    -------
    None

    """

    parser = argparse.ArgumentParser(description = 'Parse amplicon_stats file for FDEPTH and FPCOV.')
    parser.add_argument('-d', '--dir', metavar = '', required = True, help = 'Specify directory for amplicon_stats files')
    parser.add_argument('-o', '--result', metavar='', required=False, help='Specify name of the folder to place the result')
    args = parser.parse_args()

    ampl_dir = args.dir
    result_dir = args.result
    if not result_dir:
        result_dir = 'amplicon_stats_summary'
    if not os.path.exists(result_dir):
        os.makedirs(result_dir)

    for ampl_file in glob.glob(rf"{ampl_dir}/*ampliconstats.txt"):
        sample_id = ampl_file[len(ampl_dir):-18]
        with open(ampl_file, 'r', errors='ignore') as f:
            file = f.read()
            pattern_FDEPTH = r'FDEPTH.*?Percentage coverage per amplicon'
            lines = re.search(pattern_FDEPTH, file, flags=re.DOTALL|re.I).group(0)
            # the info we need is on the 2nd line and from the 2nd element onwards
            FDEPTH_list = lines.split('\n')[1].split()[2:]

            pattern_FPCOV = r'FPCOV.*?Depth per reference base'
            lines = re.search(pattern_FPCOV, file, flags=re.DOTALL | re.I).group(0)
            # the info we need is on the 2nd line and from the 2nd element onwards
            FPCOV_list = lines.split('\n')[1].split()[2:]

        result_list = []
        result_list.append('Amplicon_Num\tVoC_feature\tFDEPTH\tFPCOV')
        for index,result in enumerate(zip(FDEPTH_list,FPCOV_list)):
            result_list.append(f'{index+1}\t\t{result[0]}\t{result[1]}')

        with open(result_dir+f'/{sample_id}.txt', 'w') as f:
            f.write('\n'.join(result_list))

 

def find_amplicon_dropout_nf():
    """
    This is the updated version of 'find_amplicon_dropout'. It will now take only one parameter: amplicon_stats file
    and print out the extracted dropout information

    This function is to be used when the python script is used internally within the nextflow

    Parameters
    ----------

    Returns
    -------
    None

    """

    parser = argparse.ArgumentParser(description = 'Parse amplicon_stats file for FDEPTH and FPCOV.')
    parser.add_argument('-f', '--file', metavar = '', required = True, help = 'Specify amplicon_stats files')
    args = parser.parse_args()

    with open(args.file, 'r', errors='ignore') as f:
        file = f.read()
        pattern_FDEPTH = r'FDEPTH.*?Percentage coverage per amplicon'
        lines = re.search(pattern_FDEPTH, file, flags=re.DOTALL|re.I).group(0)
        # the info we need is on the 2nd line and from the 2nd element onwards
        FDEPTH_list = lines.split('\n')[1].split()[2:]

        pattern_FPCOV = r'FPCOV.*?Depth per reference base'
        lines = re.search(pattern_FPCOV, file, flags=re.DOTALL | re.I).group(0)
        # the info we need is on the 2nd line and from the 2nd element onwards
        FPCOV_list = lines.split('\n')[1].split()[2:]

    result_list = []
    result_list.append('Amplicon_Num\tVoC_feature\tFDEPTH\tFPCOV')
    for index,result in enumerate(zip(FDEPTH_list,FPCOV_list)):
        result_list.append(f'{index+1}\t\t{result[0]}\t{result[1]}')

    print ('\n'.join(result_list))


if __name__ == "__main__":
    # find_amplicon_dropout()
    find_amplicon_dropout_nf()
    