import argparse
import glob
import statistics
import csv

class Bed_stats:

        """Bed file information parsed

        Attributes:
                bed1: String representing the file path to the first bed file
                bed2: String representing the file path to the second bed file
        """

        def __init__(self,bed1,bed2):

                """Creates a new Bed_stats object"""

                self.bed1 = str(bed1)
                self.bed2 = str(bed2)

        def bed1Stats(self):

                """Function returning list of lists the contain the orf stats
                   Parses the bed file and indexes out the information
                """

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

                """Function returning list of lists the contain the orf stats
                   Parses the bed file and indexes out the information
                """

                with open(self.bed2,'r') as f:
                        bed2Info = f.readlines()
                f.close()

                bed2Stats = []

                for i in bed2Info:
                        orfStat = []

                        i = i.split('\t')
                        orfStat.append(int(i[1]))
                        orfStat.append(int(i[2]))
                        orfStat.append(i[3])
                        bed2Stats.append(orfStat)

                return(bed2Stats)

class Orf_Stats:

        """Parsed consensus and pacbam files to generate relavent orf stats

        Attributes:
                consensus: String of nucleotide sequence for an input genome
                bedStats: Class of Bed_stats
                pacbamInfo: List of parsed pcabam file information
                min_cov: Int of the minimum required coverage
                meanDepth: Int of the minimum required mean depth
                per_cov: Int of the minimum required percent coverage
                basename: String of the basename of the file
        """

        def __init__(self, consensus, bedStats, pacbamInfo,min_cov,meanDepth,per_cov,basename):

                """Creates a new Orf_Stats class object"""

                self.consensus = consensus
                self.bedStats = bedStats
                self.pacbamInfo = pacbamInfo
                self.min_cov = min_cov
                self.meanDepth = meanDepth
                self.per_cov = per_cov
                self.basename = basename

        def orfStats(self):

                """Function that performs several operations
                        First retrieves the length of orf from bedStats
                        Second slices the orf from the consensus sequence using bedStats start and stop info
                        Third retrieves the orf ID from bedStats
                        Fourth Counts number of N's in the orfSeq
                                Sends orf sequence to numberN's function
                        Fifth calculates the percentage of N's in orfSeq
                        Sixth slices out relavent pacbam stats from pacbamInfo
                        Seventh sends coverageList to CoverageCalc function
                        Eighth calculates the percentage of bases with minimum coverage
                        Ninth calculates the percent total coverage

                        Returns above calculations
                """

                orfstats = []

                for i in self.bedStats:

                        try:
                                length = int(i[1]) - int(i[0])
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

                                if numNs == 0:
                                        numNs = 'NA'
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
                                coverCalcs = (coverageCalc(coverageList,self.min_cov))
                        except:
                                coverCalcs = ['NA','NA','NA']

                        try:
                                minCovPercen = coverCalcs[1]/length*100
                        except:
                                minCovPercen = 'NA'

                        try:
                                covPercen = coverCalcs[0]/length*100
                        except:
                                covPercen = 'NA'

                        try:
                                if int(coverCalcs[2]) >= int(self.meanDepth) or int(minCovPercen) >= int(self.per_cov):
                                        QC = 'Pass'
                                else:
                                        QC = 'Fail'
                        except:
                                QC = 'Fail'

                        orfStat=[self.basename,orfID,length,covPercen,coverCalcs[2],coverCalcs[1],minCovPercen,numNs,percenNs,QC]

                        orfstats.append(orfStat)


                return(orfstats)

def coverageCalc(coverageList,minCov):

        """Function parsing coverageList for


        :param coverageList: List of pacbam coverage information
        :param minCov: Int of minimum passing coverage
        :return:
                covCount: Int of bases with coverage
                minCovCount: Int of bases with minimum coverage
                meanDepth: Int mean coverage stat
        """

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

        """Function to slice out relevant pacbam information

        :param pacbam: List pacbam covereage
        :param start: Int start position slice
        :param end: Int end position for slice
        :return:
                coverageList: List sliced from pacbam
        """

        coverageList = []

        for i in pacbam:

                i = i.split('\t')

                if int(i[1]) >= start and int(i[1]) <= end:

                        cov = int(i[8].strip('\n'))

                        coverageList.append(cov)


        return(coverageList)


def numberNs(orfSeq):

        """Function to count number of N's in a sequence

        :param orfSeq: Str of orf sequence
        :return:
                numNs: Int number of N's
        """

        numNs = 0

        for i in  orfSeq:
                if i == 'N':
                        numNs+=1

        return(numNs)

def consensusReader(consenusFile):

        """Function to read in consensus file

        :param consenusFile: Str path to consensus file
        :return:
                consensus: List of read in consensus file info
        """

        with open(consenusFile,'r') as f:
                consensus = f.readlines()
        f.close()

        return(consensus)

def pacbamReader(pacbamFile):

        """Function to read in pacbam files
                deletes of header before return

        :param pacbamFile: Str file path to pacbam file
        :return:
                pacbamInfo: List of read in pabam file info
        """

        with open(pacbamFile,'r') as f:
                pacbamInfo = f.readlines()
        f.close()

        del pacbamInfo[0]

        return(pacbamInfo)


if __name__ == '__main__':

        parser = argparse.ArgumentParser(description='Script to take report ORF stats')

        parser.add_argument('bed_file1',type=str,help='Path to the bed file. Default Cecret/configs/MN908947.3-ORFs')

        parser.add_argument('bed_file2',type=str,help='Path to second bed file. Default Cecret/configs/MN908947.3-ORF7b')

        parser.add_argument('pacbam_dir',type=str,help='Path to the directory containing pacbam files. Default is pacbam_orf')

        parser.add_argument('consensus_dir',type=str,help='Path to the consensus files. Default is consensus')

        parser.add_argument('min_cov',nargs='?',type=int,default=30,help='Enter the minimum coverage threshold')

        parser.add_argument('mean_depth',nargs='?',type=int,default=100,help='Enter the mean depth threshold')

        parser.add_argument('per_cov',nargs='?',type=int,default=95,help='Enter the percent coverage threshold to pass basic QC')

        args = parser.parse_args()

        bedFileClass = Bed_stats(args.bed_file1,args.bed_file2)

        bed1Stats = bedFileClass.bed1Stats()
        bed2Stats = bedFileClass.bed2Stats()

        with open(f'{args.pacbam_dir}/orf_stats.tsv', 'a', newline='') as f:
                f.write(f"Sample.ID\tORF.ID\tLength\tCoverage.ORF\tMean.Depth\tNum.Pos.Min.Cov\tPercent.Pos.Min.Cov\tNum.Ns\tPercent.Ns\tQC\n")


        with open(f'{args.pacbam_dir}/orf_stats_summary.tsv', 'a', newline='') as f:
                f.write(f"Sample.ID\tORFs.Passing.QC\tCoverage.S\tMean.Depth.S\tPercent.Pos.Min.Cov.S\tPercent.Ns.S\n")

        consensusFiles = sorted(glob.glob(args.consensus_dir+'*.fa'))

        for consensus in consensusFiles:

                basename = consensus.split('/')[-1]

                basename = basename.split('.')[0]

                pacbams = sorted(glob.glob(args.pacbam_dir+basename+'/*/*.sorted.pileup'))

                consensusSeq = consensusReader(consensus)

                consensusSeq = consensusSeq[1]

                try:
                        pacbamOrfs = pacbamReader(pacbams[1])
                except:
                        pacbamOrfs = 'NA'

                try:
                        pacbamOrf7b = pacbamReader(pacbams[0])
                except:
                        pacbamOrf7b = 'NA'

                orfClass = Orf_Stats(consensusSeq,bed1Stats,pacbamOrfs,args.min_cov,args.mean_depth,args.per_cov,basename)

                orf = orfClass.orfStats()

                for i in orf:
                        with open(f'{args.pacbam_dir}/orf_stats.tsv', 'a', newline='') as f:
                                orfOut = csv.writer(f, delimiter='\t')
                                orfOut.writerow(i)

                ocPass = 0
                for i in orf:
                        if i[9] == 'Pass':
                                ocPass += 1

                for i in orf:
                        if i[1] == 'S':
                                oSstat = open(f'{args.pacbam_dir}/orf_stats_summary.tsv','a',newline='')
                                print(i[0]+'\t'+str(ocPass)+'\t'+str(i[3])+'\t'+str(i[4])+'\t'+str(i[6])+'\t'+str(i[8]),file=oSstat)


                orf7bClass = Orf_Stats(consensusSeq,bed2Stats,pacbamOrf7b,args.min_cov,args.mean_depth,args.per_cov,basename)

                orf7b = orf7bClass.orfStats()

                for i in orf7b:
                        with open(f'{args.pacbam_dir}/orf_stats.tsv', 'a', newline='') as f:
                                orfOut = csv.writer(f, delimiter='\t')
                                orfOut.writerow(i)


