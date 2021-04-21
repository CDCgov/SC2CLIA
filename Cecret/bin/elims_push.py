#!/usr/bin/env python3

'''Gathers data pertaining to a run and outputs the data in format for upload to ELIMS'''

import os, sys, re, argparse
import pandas as pd

__author__ = 'Jessica Rowell'
__version__ = '1.0'
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
    "placeholder2":"Open Reading Frames",
    "placeholder3":"S-gene Coverage",
    "placeholder4":"Spike Protein Substitutions",
    "pangolin_lineage":"Lineage",
    "num_pangolin_subs":"Number of Lineage-Defined Substitutions",
    "pangoLEARN_version":"pangoLEARN Version",
    "genbank":"GenBank Accession #"
}


# Get sample names to traverse through folders for pangolin info
def get_samples(filename):
    """Gets a list of the samples

    Params
    ------
    filename: String
        Name of the summary.txtfile

    Returns
    ------
    Path to file

    """

    try:
        summary_table = pd.read_csv(filename, sep='\t')
    except Exception:
        print(f"Could not import {filename} using Pandas")
        sys.exit(1)
    # Get only the real samples (exclude controls) - right now excluding if they start with non-decimal digit
    non_sample_pattern = "^\D+"
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
    summary_subset = summary_table.loc[:,('sample','depth_after_trimming','coverage_after_trimming','fastqc_raw_reads_1','Total_Reads_Analyzed','pangolin_lineage')]
    summary_subset['percent_mapped'] = (summary_subset['Total_Reads_Analyzed'] / summary_subset['fastqc_raw_reads_1'])*100
    summary_subset['min_cov_threshold'] = 30
    summary_subset['CSID'] = summary_table['sample'].str.split('-').str[0]
    summary_subset['CUID'] = summary_table['sample'].str.split('-').str[1]
    summary_subset['genbank'] = ''    
    # add orfs, s-cov, spike_subs
    return(summary_subset)


#Change from wide to long format, add in the extra columns, rearrange, format the Analyte columns?
def out_elims_data(summary_df):
    long_data = pd.melt(summary_df, id_vars=['CSID','CUID'], var_name='Analyte (required)', value_name='Raw Result (required)')
    long_data['CDC Local Aliquot ID'] = ''
    long_data['QC Type'] = 'N/A'
    long_data['Test Name'] = 'SARS-CoV-2 Genetic Analysis'
    long_data['Replicate'] = ''
    long_data['Interpretation'] = ''
    long_data['QA Analysis'] = ''
    cols = ['CSID','CUID','CDC Local Aliquot ID','QC Type','Test Name','Analyte (required)', \
            'Replicate','Raw Result (required)','Interpretation','QA Analysis']
    long_data = long_data[cols]
    long_data = long_data.replace({"Analyte (required)": out_formats})
    long_data.sort_values(by=['CSID','CUID'], inplace=True)
    return(long_data)

def main():
    #import pdb; pdb.set_trace()
    parser = argparse.ArgumentParser(description = 'Generate data for uploading to ELIMS.')
    parser.add_argument('-d', '--directory', metavar = '', required = True, help = 'Specify run directory to pull data from')
    parser.add_argument('-s', '--summary_file', metavar = '', required = True, help = 'Specify summary.txt file to pull data from')
    args = parser.parse_args()

    summary_file = args.summary_file

    outfile = args.directory + "/push_to_elims.txt"
    with open(outfile, 'w') as o:
        o.write(f"Created {outfile}")
        o.write(f"Directory: {args.directory}")
        o.write(f"Summary file: {summary_file}")

    if os.path.exists(args.directory) == False:
        print(f"Directory does not exist: {args.directory}")
        sys.exit(1)
    elif os.path.isfile(summary_file) == False:
        raise FileNotFoundError
        print(f"File not found: {summary_file}")
        sys.exit(1)
    
    samples = get_samples(summary_file)
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

    # Merge in pangolin substition info
    full_data = pd.merge(summary_output, pangolin_substitutions, on = 'sample', how = 'left')

    # Rearrange columns 
    cols = ['CSID','CUID','min_cov_threshold','depth_after_trimming','coverage_after_trimming', \
            'fastqc_raw_reads_1','Total_Reads_Analyzed','percent_mapped', \
            'pangolin_lineage', 'num_pangolin_subs','pangoLEARN_version'] # add orfs, s-cov, spike_subs, genbank
    full_data = full_data[cols]

    final_data = out_elims_data(full_data)
    
    if os.path.exists(args.directory + '/report'):
        outfile = args.directory + "/report/push_to_elims.txt"
        print(f"Generated {outfile}")
    else:
        outfile = args.directory + "/push_to_elims.txt"
        print(f"Generated {outfile}")

    final_data.to_csv(outfile, sep='\t', index=False)

if __name__ == '__main__':
    main()
