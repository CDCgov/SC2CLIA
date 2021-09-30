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

                        i = i.split('\t')
                        orfStat.append(int(i[1]))
                        orfStat.append(int(i[2]))
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

                        i = i.split('\t')
                        orfStat.append(i[1])
                        orfStat.append(i[2])
                        orfStat.append(i[3])
                        bed2Stats.append(orfStat)

                return(bed2Stats)

class Orf_Stats:

        def __init__(self, consensus, bedStats, pacbamInfo,min_cov):
                self.consensus = consensus
                self.bedStats = bedStats
                self.pacbamInfo = pacbamInfo
                self.min_cov = min_cov

        def orfStats(self):

                orfstats = []

                for i in self.bedStats:

                        print(i)

                        try:
                                length = int(i[1]) - int(i[0])
                                print(length)
                        except:
                                length = 'NA'

                        try:
                                orfSeq = self.consensus[i[0]:i[1]]
                        except:
                                orfSeq = 'NA'

                        try:
                                orfID = i[2]
                                print(orfID)
                        except:
                                orfID = 'NA'

                        try:
                                numNs = numberNs(orfSeq)
                                print(numNs)
                        except:
                                numNs = 'NA'

                        try:
                                percenNs = (numNs/length)*100
                                print(percenNs)
                        except:
                                percenNs = 'NA'

                        try:
                                coverageList = pacbamSlice(self.pacbamInfo, i[0], i[1])
                        except:
                                coverageList = 'NA'

                        try:
                                coverCalcs = (coverageCalc(coverageList,self.min_cov))
                                print(coverCalcs[2],coverCalcs[1])
                        except:
                                coverCalcs = 'NA'

                        try:
                                minCovPercen = coverCalcs[1]/length*100
                                print(minCovPercen)
                        except:
                                minCovPercen = 'NA'

                        try:
                                covPercen = coverCalcs[0]/length*100
                                print(covPercen)
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
                if i != 0:
                        covCount +=1
                if i >= minCov:
                        minCovCount +=1


        return(covCount,minCovCount,meanDepth)


def pacbamSlice(pacbam,start,end):

        coverageList = []

        for i in pacbam:

                i = i.split('\t')

                if int(i[1]) >= start and int(i[1]) <= end:

                        cov = int(i[8].strip('\n'))

                        coverageList.append(cov)


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

        del pacbamInfo[0]

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

        consensusFiles = sorted(glob.glob(args.consensus_dir+'*.fa'))

        orfInfo = []

        for consensus in consensusFiles:

                basename = consensus.split('/')[-1]

                basename = basename.split('.')[0]

                pacbams = sorted(glob.glob(args.pacbam_dir+basename+'/*/*.sorted.pileup'))

                consensusSeq = consensusReader(consensus)

                consensusSeq = consensusSeq[1]

                pacbamOrfs = pacbamReader(pacbams[1])

                pacbamOrf7b = pacbamReader(pacbams[0])

                orfClass = Orf_Stats(consensusSeq,bed1Stats,pacbamOrfs,args.min_cov)

                orf = orfClass.orfStats()

                orf7bClass = Orf_Stats(consensusSeq,bed2Stats,pacbamOrf7b,args.min_cov)

                orf7b = orf7bClass.orfStats()

                orf.append(orf7b)

                orfInfo.append(orf)

        for i in orfInfo:

                with open('orf_stats','w',newline='') as f:
                        orfOut = csv.writer(f,delimiter='\t')
                        orfOut.writerow(i)
