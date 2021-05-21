import unittest
import pandas as pd
import argparse
import sys

__author__ = 'Rong Jin'
__version__ = '1.0'
__maintainer__ = 'Rong Jin'
__email__ = '***REMOVED***'

# creat 2 global variables to hold the names of 2 summary.txt files
summary_standard = ''
summary_test = ''
error_margin = 5 # default to +/-5%

column_index = 'sample'
numeric_columns = ['fastqc_raw_reads_1','depth_after_trimming','coverage_after_trimming',
                   '%_Reads_Matching_SC2_Ref','ORFs.Passing.QC','Coverage.S']
# 'pangolin_subs' is not currently in summary.txt

non_numeric_columns = ['pangolin_lineage','S_aa_INDELs','vdr_sgene_orftshift']
# 'pangoLEARN_version','GenBank#' are not currently in summary.txt

class MyTestCase(unittest.TestCase):

    def setUp(self):

        self.error_margin = error_margin

        try:
            self.summary_standard_df = pd.read_csv(summary_standard, sep='\t')
            self.summary_standard_df.set_index(column_index, inplace=True)
            self.summary_standard_df.fillna(-100,inplace=True) # set NaN cell to -100 for easy processing
        except Exception:
            print(f"Could not import {summary_standard} using Pandas")
            sys.exit(1)
        try:
            self.summary_test_df = pd.read_csv(summary_test, sep='\t')
            self.summary_test_df.set_index(column_index, inplace=True)
            self.summary_test_df.fillna(-100,inplace=True)
        except Exception:
            print(f"Could not import {summary_test} using Pandas")
            sys.exit(1)

    def test_numeric_columns(self):
        """ testing columns with numeric values. we compare the absolute value within user-configurable {error_margin},
            default is 10% """
        for col in numeric_columns:
            for ind in self.summary_standard_df.index:
                test_value = self.summary_test_df[col][ind]
                standard_value = self.summary_standard_df[col][ind]
                with self.subTest(ind=ind):
                    expr = abs(test_value) >= abs(standard_value) * (1-error_margin/100) \
                        and abs(test_value) <= abs(standard_value) * (1+error_margin/100)
                    self.assertTrue(expr, f"test_value: {test_value} ; standard_value: {standard_value}")

    def test_non_numeric_columns(self):
        """ testing columns with non-numeric values. we compare the literal value for each cell
            """
        for col in non_numeric_columns:
            for ind in self.summary_standard_df.index:
                test_value = self.summary_test_df[col][ind]
                standard_value = self.summary_standard_df[col][ind]
                with self.subTest(ind=ind):
                    self.assertEqual(test_value, standard_value)




if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = 'use validation data for unit test.')
    parser.add_argument('-s', '--summary_standard', metavar = '', required = True, help = 'Specify gold-standard summary.txt')
    parser.add_argument('-t', '--summary_test', metavar = '', required = True, help = 'Specify the test summary.txt')
    parser.add_argument('-e', '--error_margin', metavar='', default=5, help='Specify margin for error, default to 5 (5%)')
    args = parser.parse_args()
    summary_standard = args.summary_standard
    summary_test = args.summary_test
    error_margin = args.error_margin

    # these are for passing arguments under unittest setting
    ns, args = parser.parse_known_args(namespace=unittest)
    remaining_args = sys.argv[:1] + args

    # USAGE: python -m test_validation_data -s -t
    unittest.main(argv=remaining_args)
