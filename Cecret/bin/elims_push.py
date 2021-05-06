#!/usr/bin/env python3

'''Gathers data pertaining to a run and outputs the data in format for upload to ELIMS'''

import os, sys, re, argparse
import pandas as pd
from functools import partial, reduce
import numpy as np
np.warnings.filterwarnings('ignore', category=np.VisibleDeprecationWarning)

__author__ = 'Jessica Rowell'
__version__ = '1.2'
__maintainer__ = 'Jessica Rowell'
__email__ = '***REMOVED***'
__status__ = 'Development'


# Make the dictionary mapping the summary.txt variable to its expanded name
out_formats = {
    "sample_id":"CSID",
    "sample":"CSID_CUID",
    "min_cov_threshold":"Minimum Coverage Threshold",
    "depth_after_trimming":"Average Depth",
    "coverage_after_trimming":"Percent Genome Coverage",
    "fastqc_raw_reads_1":"Total Reads",
    "Total_Reads_Analyzed":"Mapped Reads",
    "percent_mapped":"Percent Mapped Reads",
    "ORFs.Passing.QC":"Open Reading Frames",
    "Coverage.S":"S-gene Coverage",
    "S_aa_INDELs":"Spike Protein Substitutions",
    "pangolin_lineage":"Lineage",
    "num_pangolin_subs":"Number of Lineage-Defined Substitutions",
    "pangoLEARN_version":"pangoLEARN Version",
    "genbank":"GenBank Accession #"
}

# Make the second row (required for the ELIMS database)
db_row = ["SAMPLECONTAINERS.SAMPLECONTAINERS.EXTERNAL_ID.", \
          "SAMPLECONTAINERS.SAMPLECONTAINERS.CONTAINERID.", \
          "SAMPLECONTAINERS_DEPTID.SAMPLECONTAINERS_DEPTID.CONTAINER_DEPTID.", \
          "ORDTASK.ORDTASK.QCTYPE.", \
          "RESULTS.RESULTS.TESTNO.", \
          "RESULTS.RESULTS.SINONYM.", \
          "RESULTS.RESULTS.REP.", \
          "RESULTS.RESULTS.NUMRES.", \
          "RESULTS.RESULTS.RN1.", \
          "RESULTS.RESULTS.RN2."
]


# Get sample names to traverse through folders for pangolin info
def get_samples(filename):
    """Gets a list of the samples

    Params
    ------
    filename: String
        The summary.txt file

    Returns
    ------
    Pandas Series object that is a filtered list of sample IDs

    """
    try:
        summary_table = pd.read_csv(filename, sep='\t')
    except Exception:
        print(f"Could not import {filename} using Pandas")
        sys.exit(1)
    # Get only the real samples (exclude controls) - right now excluding if it contains PC, NC, WA, or CA
    non_sample_pattern = "^PC-|-PC-|^NC-|-NC-|^CA|^WA|^Undetermined"
    filter = summary_table['sample'].str.contains(non_sample_pattern)
    summary_table = summary_table[~filter]
    return(summary_table['sample']) 

# Get the info available in summary.txt and output as a df
def get_summary_data(filename, samples):
    try:
        summary_table = pd.read_csv(filename, sep='\t')
    except Exception:
        print(f"Could not import {filename} using Pandas")
        sys.exit(1)
    # Modify to take in samples and only keeps where rows that are real samples
    summary_table = summary_table[summary_table["sample"].isin(samples)]
    summary_subset = summary_table.loc[:,('sample','depth_after_trimming','coverage_after_trimming','fastqc_raw_reads_1', \
                                          'Total_Reads_Analyzed','pangolin_lineage', 'ORFs.Passing.QC', 'Coverage.S', 'S_aa_INDELs')]
    summary_subset['percent_mapped'] = (summary_subset['Total_Reads_Analyzed'] / summary_subset['fastqc_raw_reads_1'])*100
    summary_subset['min_cov_threshold'] = 30
    summary_subset['CSID'] = summary_table['sample'].str.split('-').str[0]
    summary_subset['CUID'] = summary_table['sample'].str.split('-').str[1]
    summary_subset['genbank'] = ''    
    # add orfs, s-cov
    return(summary_subset)


#Change from wide to long format, add in the extra columns, rearrange, format the Analyte columns
def out_elims_data(summary_df):
    long_data = pd.melt(summary_df, id_vars=['CSID','CUID', 'sample'], var_name='Analyte (required)', value_name='Raw Result (required)')
    long_data = long_data.rename(columns = {'sample':'CDC Local Aliquot ID'}) # We need a place to store full sample, so Jo can use it for report
    #long_data['CDC Local Aliquot ID'] = '' # Old version left this as a blank field, which is out eLIMS wants it
    long_data['QC Type'] = 'N/A'
    long_data['Test Name'] = 'SARS-CoV-2 Genetic Analysis'
    long_data['Replicate'] = ''
    long_data['Interpretation'] = ''
    long_data['QA Analysis'] = ''
    cols = ['CSID','CUID','CDC Local Aliquot ID','QC Type','Test Name','Analyte (required)', \
            'Replicate','Raw Result (required)','Interpretation','QA Analysis']
    long_data = long_data[cols]
    long_data.sort_values(by=['CSID','CUID'], inplace=True) # ignore_index=True is only available after Pandas 1.0.0, M3 is still on 0.25.0
    long_data.reset_index(drop=True, inplace=True)
    long_data.loc[-1] = db_row
    long_data.index = long_data.index + 1
    long_data = long_data.sort_index() # I've done it this way because I'm inserting a list, not a dict/Series with colnames
    long_data = long_data.replace({"Analyte (required)": out_formats})
    return(long_data)

def main():
    #import pdb; pdb.set_trace()
    parser = argparse.ArgumentParser(description = 'Generate data for uploading to ELIMS.')
    parser.add_argument('-d', '--directory', metavar = '', required = True, help = 'Specify run directory to pull data from')
    parser.add_argument('-s', '--summary_file', metavar = '', required = True, help = 'Specify summary.txt file to pull data from')
    args = parser.parse_args()

    summary_file = args.summary_file

    if os.path.exists(args.directory) == False:
        print(f"Directory does not exist: {args.directory}")
        sys.exit(1)
    elif os.path.isfile(summary_file) == False:
        raise FileNotFoundError
        print(f"File not found: {summary_file}")
        sys.exit(1)
    
    samples = get_samples(summary_file)

    # Still working out a way to exit gracefully if duplicates exist
    #possible_CSIDs = set(samples.str.findall('\d{10}')) # Find all strings of 10 digits
    #possible_CUIDs = samples.str.findall('(?![A-Za-z]{8}|[0-9]{8})[0-9A-Za-z]{8}') # Find all alphanumeric, 8-char strings
    # Note: this is really a hack. It won't accommodate multiple CSID-like/CUID-like strings that will be identified above
    #elims_identifier = possible_CSIDs.astype('str').str.cat(possible_CUIDs.astype('str'), sep = '-', join='left') 
    #if not elims_identifier.is_unique:
    #    print("There are duplicate CSID-CUIDs in your sample sheet.")
    #    print("Duplicate samples cannot be uploaded to ELIMS.")
    #    sys.exit()

    summary_output = get_summary_data(summary_file, samples)  

    # Use samples to traverse args.directory and get info about lineage substitutions and pangoLEARN vs
    pangolin_list = []
    for sample in samples:
        pangolin_file = args.directory + '/pangolin/' + sample + '/lineage_report.csv'
        if os.path.isfile(pangolin_file) == True:
            try:
                pangolin_data = pd.read_csv(pangolin_file)
                pangolin_data.fillna('',inplace=True)
            except Exception:
                print(f"Could not import {pangolin_file} using Pandas")
                pass
            lineage_subs = pangolin_data.iloc[0]['note'].split(' ')[0]
            pangoLEARN_version = pangolin_data.iloc[0]['pangoLEARN_version']
            if lineage_subs == '':
                data_trio = (sample, "No data", pangoLEARN_version)
            elif re.search('\d+\/\d+', lineage_subs):
                data_trio = (sample, lineage_subs, pangoLEARN_version)
            else:
                data_trio = (sample, "No data", pangoLEARN_version)
            pangolin_list.append(data_trio)
    pangolin_substitutions = pd.DataFrame(pangolin_list, columns = ['sample', 'num_pangolin_subs', 'pangoLEARN_version'])

    # Merge all the info
    # Note: can be done with just one merge  because there are only two dfs, but I've left it in case we add more
    dfs = [summary_output, pangolin_substitutions] # add additional dfs as needed
    merge = partial(pd.merge, on='sample', how='left') # merge object, partial function
    full_data = reduce(merge, dfs) # apply the merge object to all the dfs


    # Rearrange columns 
    cols = ['CSID','CUID','min_cov_threshold','depth_after_trimming','coverage_after_trimming', \
            'fastqc_raw_reads_1','Total_Reads_Analyzed','percent_mapped', 'S_aa_INDELs', 'genbank', \
            'ORFs.Passing.QC', 'Coverage.S', 'pangolin_lineage', 'num_pangolin_subs','pangoLEARN_version', 'sample'] # add orfs, s-cov, genbank

    full_data = full_data[cols]

    final_data = out_elims_data(full_data)

    if os.path.exists(args.directory + '/report'):
        outfile = args.directory + "/report/push_to_elims.txt"
    else:
        outfile = args.directory + "/push_to_elims.txt"

    final_data.to_csv(outfile, sep='\t', index=False)
    print(f'Generated {outfile}.')

if __name__ == '__main__':
    main()
