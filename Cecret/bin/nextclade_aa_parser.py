import argparse
import re

class Nextclade_AA_Info:

    """Parsed amino acid substitutions and deletions determined by Nextclade

    Attributes:
        seq_name: String representing the sequence ID
        seq_subs: String consisting of the amino acid substitutions
        seq_sub_number: String value of how many substitutions there are
        seq_dels: String consisting of amino acid deletions
        seq_del_number: String value of how many deletions there are

    """
    def __init__(self,seq_name,seq_subs,seq_sub_number,seq_dels,seq_del_number):

        """Returns a new Nextclade_AA_Info object"""

        self.seq_name = seq_name
        self.seq_subs = seq_subs
        self.seq_sub_number = seq_sub_number
        self.seq_dels = seq_dels
        self.seq_del_number = seq_del_number

    def spikeProteinInfo(self):

        """Function returning just S protein substitutions and deletions
           Parses the strings seq_subs and seq_dels for 'S' labeled subs or dels
           Returns S_prot_submuts, a list of those subs and dels
        """


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

    """Takes a nextclade output csv file and parses using nextclade column headers to
       find and return a Nextclade_AA_Info object

       Parameters
       ----------
       nextclade_csv: String
            File path to nextclade csv file

       Returns
       -------
       nextclade_obj: Object
            Nextclade_AA_Info object
    """
    with open(nextclade_csv,'r') as fh:
        nextclade_info = fh.readlines()

    nextclade_headers = nextclade_info[0]
    nextclade_headers = re.split(''';(?=(?:[^'"]|'[^']*'|"[^"]*")*$)''',nextclade_headers)
    nextclade_values = nextclade_info[1]
    nextclade_values = re.split(''';(?=(?:[^'"]|'[^']*'|"[^"]*")*$)''',nextclade_values)

    seq_name = nextclade_values[nextclade_headers.index('seqName')].split('.')[0]

    seq_name = seq_name.split('_')[1]

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

#Runs the Nextclade_AA_Info class function spikeProtienInfo() to return
#the spike protein subs and dels

    spikeProteinInfo = nextclade_obj.spikeProteinInfo()

#Opens an appendable file to print the spikeProteinInfo list to
    nextcladeOutFileHandle = open(args.nextclade_aa_file,'w')

#Joins the list into csv format and prints to file

    print(','.join(spikeProteinInfo),file=nextcladeOutFileHandle)
