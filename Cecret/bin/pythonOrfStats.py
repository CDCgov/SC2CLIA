import os
import argparse
import glob

class Bed_stats:

        def __init__(self,bed1,bed2):

                self.bed1 = str(bed1)
                self.bed2 = str(bed2)

        def bed1Stats(self):
                with open(bed1,'r') as f:
                        bed1Info = f.readlines()
                f.close()

                bed1Stats = []

                for i in bed1Info:
                        orfStat = []

                        i.split('\t')
                        orfStat.append(i[1])
                        orfStat.append(i[2])
                        orfStat.append(i[3])
                        bed1Stats.append(orfStat)

                return(bed1Stats)

        def bed2Stats(self):
                with open(bed2,'r') as f:
                        bed2Info = f.readlines()
                f.close()

                bed2Stats = []

                for i in bed2Info:
                        orfStat = []

                        i.split('\t')
                        orfStat.append(i[1])
                        orfStat.append(i[2])
                        orfStat.append(i[3])
                        bed2Stats.append(orfStat)

                return(bed2Stats)

class Orf_Stats:

        def __init__(self,consensus,bed1Stats,bed2Stats,pacbamInfo):
                self.consensus = consensus
                self.bed1Stats = bed1Stats
                self.bed2Stats = bed2Stats
                self.pacbamInfo = pacbamInfo

        def orfStats(self):

                orfstats = []

                for i in bed1Stats:

                        length = bed1Stats[1] - bed1Stats[0]

                        orfSeq = consensus[bed1Stats[0]:bed2Stats[1]]

                        orfID = bed1Stats[2]

                        numNs = numberNs(orfSeq)

                        percenNs = (numNs/length)*100

                        coverageList = pacbamSlice(pacbamInfo,bed1Stats[0],bed1Stats[1])


def pacbamSlice(pacbam,start,end):

        coverageList = []

        for i in pacbam:

                i = i.split('\t')

                if i[1] >= start and i[1] <= end:

                        coverageList.append(i[8])


        return(coverageList)


def numberNs(orfSeq):

        numNs = 0

        for i in  orfSeq:
                if i == 'N':
                        numNs+=1

        return(numNs)

def consensusReader(consenusFile):

        with open(consenusFile,'r') as f:
                consensus = f.readlines()
        f.close()

        return(consensus)

def pacbamReader(pacbamFile):

        with open(pacbamFile,'r') as f:
                pacbamInfo = f.readlines()
        f.close()

        return(pacbamInfo)


if __name__ == '__main__':

        parser = argparse.ArgumentParser(description='Script to take report ORF stats')

        parser.add_argument('bed_file',type=str,help='Path to the bed file')

        parser.add_argument('pacbam_dir',type=str,help='Path to the directory containing pacbam files')

        parser.add_argument('consensus_dir',type=str,help='Path to the consensus files')

        parser.add_argument('min_cov',nargs='?',type=int,default=30,help='Enter the minimum coverage threshold')

        parser.add_argument('mean_depth',nargs='?',type=int,default=100,help='Enter the mean depth threshold')

        parser.add_argument('per_cov',nargs='?',type=int,default=95,help='Enter the percent coverage threshold to pass basic QC')

        args = parser.parse_args()



