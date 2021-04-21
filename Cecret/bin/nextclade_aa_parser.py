import argparse
import re

class Nextclade_AA_Info:

    def __init__(self,seq_name,seq_subs,seq_sub_number,seq_dels,seq_del_number):

        self.seq_name = seq_name
        self.seq_subs = seq_subs
        self.seq_sub_number = seq_sub_number
        self.seq_dels = seq_dels
        self.seq_del_number = seq_del_number

    def spikeProteinInfo(self):
        s_prot_submuts = [self.seq_name,'S']
        seq_subs = self.seq_subs.split(',')
        for s in seq_subs:
            if s.startswith('S'):
                s = s.split(':')[1]
                s_prot_submuts.append(s)

        seq_dels = self.seq_dels.split(',')
        for s in seq_dels:
            if s.startswith('S'):
                s = s.split(':')[1]
                s = s.replace('-','del')
                s_prot_submuts.append(s)

        return s_prot_submuts



def nextcladeParser(nextclade_csv):

    with open(nextclade_csv,'r') as fh:
        nextclade_info = fh.readlines()

    nextclade_headers = nextclade_info[0]
    nextclade_headers = re.split(''';(?=(?:[^'"]|'[^']*'|"[^"]*")*$)''',nextclade_headers)
    nextclade_values = nextclade_info[1]
    nextclade_values = re.split(''';(?=(?:[^'"]|'[^']*'|"[^"]*")*$)''',nextclade_values)

    seq_name = nextclade_values[nextclade_headers.index('seqName')].split('.')[0]

    seq_subs = nextclade_values[nextclade_headers.index('aaSubstitutions')]

    seq_sub_number = nextclade_values[nextclade_headers.index('totalAminoacidSubstitutions')]

    seq_dels = nextclade_values[nextclade_headers.index('aaDeletions')]

    seq_del_number = nextclade_values[nextclade_headers.index('totalAminoacidDeletions')]

    nextclade_obj = Nextclade_AA_Info(seq_name,seq_subs,seq_sub_number,seq_dels,seq_del_number)

    return nextclade_obj


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Script is designed to take in a nextclade output csv file and parse it for substitutions/mutations present')

    parser.add_argument('nextclade_csv',type=str,help='File path to a nextclade csv file')

    parser.add_argument('nextclade_aa_file',type=str,help='File path to a mutable output file')

    args = parser.parse_args()

    nextclade_obj = nextcladeParser(args.nextclade_csv)

    spikeProtienInfo = nextclade_obj.spikeProteinInfo()

    nextcladeOutFileHandle = open(args.nextclade_aa_file,'a')

    print(','.join(spikeProtienInfo),file=nextcladeOutFileHandle)