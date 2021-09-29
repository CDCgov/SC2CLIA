import argparse
import glob
import statistics
import csv

class Bed_stats:

        def __init__(self,bed1,bed2):

                self.bed1 = str(bed1)
                self.bed2 = str(bed2)

        def bed1Stats(self):
                with open(self.bed1,'r') as f:
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
                with open(self.bed2,'r') as f:
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

        def __init__(self, consensus, bedStats, pacbamInfo):
                self.consensus = consensus
                self.bedStats = bedStats
                self.pacbamInfo = pacbamInfo

        def orfStats(self):

                orfstats = []

                for i in self.bedStats:

                        try:
                                length = i[1] - i[0]
                        except:
                                length = 'NA'

                        try:
                                orfSeq = self.consensus[i[0]:i[1]]
                        except:
                                orfSeq = 'NA'

                        try:
                                orfID = i[2]
                        except:
                                orfID = 'NA'

                        try:
                                numNs = numberNs(orfSeq)
                        except:
                                numNs = 'NA'

                        try:
                                percenNs = (numNs/length)*100
                        except:
                                percenNs = 'NA'

                        try:
                                coverageList = pacbamSlice(self.pacbamInfo, i[0], i[1])
                        except:
                                coverageList = 'NA'

                        try:
                                coverCalcs = (coverageCalc(coverageList,args.min_cov))
                        except:
                                coverCalcs = 'NA'

                        try:
                                minCovPercen = coverCalcs[1]/length*100
                        except:
                                minCovPercen = 'NA'

                        try:
                                covPercen = coverCalcs[0]/length*100
                        except:
                                covPercen = 'NA'

                        orfStat=[orfID,length,covPercen,coverCalcs[2],coverCalcs[1],minCovPercen,numNs,percenNs]

                        orfstats.append(orfStat)

                return(orfstats)

def coverageCalc(coverageList,minCov):

        covCount = 0
        minCovCount = 0
        meanDepth = statistics.mean(coverageList)

        for i in coverageList:
                if i == 0:
                        covCount +=1
                elif i >= minCov:
                        minCovCount +=1


        return(covCount,minCovCount,meanDepth)


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

        parser.add_argument('bed_file1',type=str,help='Path to the bed file')

        parser.add_argument('bed_file2',type=str,help='Path to second bed file')

        parser.add_argument('pacbam_dir',type=str,help='Path to the directory containing pacbam files')

        parser.add_argument('consensus_dir',type=str,help='Path to the consensus files')

        parser.add_argument('min_cov',nargs='?',type=int,default=30,help='Enter the minimum coverage threshold')

        parser.add_argument('mean_depth',nargs='?',type=int,default=100,help='Enter the mean depth threshold')

        parser.add_argument('per_cov',nargs='?',type=int,default=95,help='Enter the percent coverage threshold to pass basic QC')

        args = parser.parse_args()

        bedFileClass = Bed_stats(args.bed_file1,args.bed_file2)

        bed1Stats = bedFileClass.bed1Stats()
        bed2Stats = bedFileClass.bed2Stats()

        consensusFiles = sorted(glob.glob(args.consensus_dir+'.fa'))

        orfInfo = []

        for consensus in consensusFiles:

                basename = consensus.split('/')[-1]

                pacbams = sorted(glob.glob(args.pacbam_dir+basename+'*/*/*'))

                consensusSeq = consensusReader(consensus)

                consensusSeq = consensusSeq[1]

                pacbamOrfs = pacbamReader(pacbams[1])

                pacbamOrf7b = pacbamReader(pacbams[0])

                orfClass = Orf_Stats(consensusSeq,bed1Stats,pacbamOrfs)

                orf = orfClass.orfStats()

                orf7bClass = Orf_Stats(consensusSeq,bed2Stats,pacbamOrf7b)

                orf7b = orf7bClass.orfStats()

                orf.append(orf7b)

                orfInfo.append(orf)

        for i in orfInfo:

                with open('orf_stats','w',newline='') as f:
                        orfOut = csv.writer(f,delimiter='\t')
                        orfOut.writerow(i)
