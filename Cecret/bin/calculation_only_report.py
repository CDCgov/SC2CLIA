import pandas as pd
import argparse
import sys
from datetime import datetime

__author__ = 'Rong Jin'
__version__ = '1.0'
__maintainer__ = 'Rong Jin'
__email__ = '***REMOVED***'


column_index = 'sample'
# summary/report: pangolin_lineage/lineage
# summary/report: S_aa_INDELs/Spike Protein Substitutions
summary_columns = ['pangolin_lineage','S_aa_INDELs']


# helper method 
# take a file_name, read it and return the dateframe
def setUp(summary_file):

    try:
        df = pd.read_csv(summary_file, sep='\t')
        df.set_index(column_index, inplace=True)
        df = df.where(df.notnull(), None)  # set NaN cell to None for easy processing
    except Exception as e:
        print(f"Could not import {summary_file} using Pandas: {e}")
        sys.exit(1)

    return df


def compare_summary(original,test):
    """
    Takes 2 summary txt files and compare contents for the columns: {summary_columns}
    and return the result in a list

    Parameters
    ----------
    original: string
    file path to original summary.txt

    test: string
    file path to test summary.txt


    Returns
    -------
    output: list
    a list of the content of the report
    """

    summary_original_df = setUp(original)
    summary_test_df = setUp(test)
    output = [] # to hold our comparison result
    output.append('\n\n' + datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    output.append(f"original summary file is: {original}")
    output.append(f"test summary file is: {test}")

    # check if the 'original' and 'test' summary.txt files are based on the same data set
    # by checking if they have the exact same samples in the summary.txt file
    orignal_index_list = list(summary_original_df.index)
    test_index_list = list(summary_test_df.index)
    orignal_index_list.sort()
    test_index_list.sort()

    if orignal_index_list != test_index_list:
        print ("WARNING: original summary samples DOES NOT match test summary samples")
        output.append("WARNING: original summary samples DOES NOT match test summary samples")
        output.append(f"original summary samples are: {orignal_index_list}")
        output.append(f"test summary samples are: {test_index_list}")
    else:
        for ind in summary_original_df.index:
            row = f"{ind}" # 1st column in the report
            test_list = [] # hold YES/NO for the comparison result

            for col in summary_columns:
                original_value = summary_original_df[col][ind]
                test_value = summary_test_df[col][ind]
                row += f"\t{original_value}" # add 2nd and 3rd columns in the report

                if original_value == test_value:
                    test_list.append("Yes")
                else:
                    test_list.append("No")

            row += '\t' + '\t'.join(test_list) # add 4th and 5th columns in the report
            if any(x == 'No' for x in test_list): # for the 6th column in the report
                row += "\tFail"
            else:
                row += "\tPass"

            output.append(row)

    return output



if __name__ == '__main__':
    # USAGE: python3 calculation_only_report.py -o original_summary.txt -t test_summary.txt
    # optional argument -f , default to calculation_only_report.txt in PWD
    parser = argparse.ArgumentParser(description = 'generate the contents for calculation_only_report.')
    parser.add_argument('-o', '--summary_original', metavar = '', required = True, help = 'Specify original summary.txt')
    parser.add_argument('-t', '--summary_test', metavar = '', required = True, help = 'Specify the test summary.txt')
    parser.add_argument('-f', '--calculation_only_report', metavar='', default='calculation_only_report.txt', \
                       help='path to the report txt file, default to calculation_only_report.txt in PWD')
    args = parser.parse_args()
    summary_original = args.summary_original
    summary_test = args.summary_test
    calculation_only_report = args.calculation_only_report

    with open(calculation_only_report, 'a') as f:
        f.write('\n'.join(compare_summary(summary_original,summary_test)) + '\n')

