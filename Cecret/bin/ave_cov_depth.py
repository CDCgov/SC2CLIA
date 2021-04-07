#!/usr/bin/env python3
import vcf
import glob
import argparse
import re
import os
import vcf_parser_refactor as vpr


def find_ave_cov_depth(data_file, result_file):

    result_dict = {}
    with open(data_file, 'r', errors='ignore') as f:
        lines = f.readlines()
        for line in lines:
            record = line.strip().split()
            ID = record[0]
            if len(record) >= 2:
                result_dict[ID] = (str(record[1]),)
            else:
                result_dict[ID] = None

    vpr.append_to_file(result_file, result_dict, '\tAve_Overall_Cov_Depth')



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = 'find Ave_Overall_Cov_Depth')
    parser.add_argument('-i', '--filein', metavar = '', required = True, help = 'Specify data file for Ave_Overall_Cov_Depth')
    parser.add_argument('-o', '--result', metavar='', required=True, help='Specify file to attach the result')
    args = parser.parse_args()

    find_ave_cov_depth(args.filein, args.result)