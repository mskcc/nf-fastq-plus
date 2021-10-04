#!/usr/bin/env python

import sys
import os
import argparse
import random,datetime
import pandas as pd
import xlrd 
import openpyxl
import glob

import logging
logging.basicConfig(level = logging.INFO,
                                         format = '%(levelname)-5s @ %(asctime)s:\n\t %(message)s \n',
                                         datefmt = '%a, %d %b %Y %H:%M:%S',
                                         stream = sys.stderr,
                                         filemode = "w"
                                         )
error   = logging.critical
warn    = logging.warning
debug   = logging.debug
info    = logging.info

__version__ = "0.1.0"

class crispr(object):
    #
    def __init__(self, sampleID, ampliconID, ampliconSeq, codingSeq, guideSeq):
        self.sampleID = sampleID
        self.ampliconID = ampliconID
        self.ampliconSeq = ampliconSeq
        self.codingSeq = codingSeq
        self.guideSeq = guideSeq
        
class fastq(object):
    #
    def __init__(self, r1, r2):
        self.r1 = r1
        self.r2 = r2

class paddedFastq(fastq):
    pass


def padSamples(projectID, projectDir, crisprRecord, fastq):
    #
    paddedFilesDir = '/igo/work/nabors/crispresso/padded_fastq/' + projectID
    paddedFastqFiles = paddedFilesDir + "/" + crisprRecord.sampleID + "*_CP_PAD.fastq.gz"
    
    if not os.path.exists(paddedFilesDir):
        os.mkdir(paddedFilesDir)
        
    workDir = projectDir
    
    os.chdir(paddedFilesDir)
    os.system("/igo/work/nabors/tools/venvpy2/bin/python /igo/work/nabors/tools/crispresso/fixNonOverlappingReads_REMIX.py -r1 " +  fastq.r1  + " -r2 " + fastq.r2 + " -a " + crisprRecord.ampliconSeq)

    paddedFastqRecord = glob.glob(paddedFastqFiles)
    paddedFastqRecord.sort()
    
    paddedFastqRecord = paddedFastq(paddedFastqRecord[0], paddedFastqRecord[1])
    
    
    return paddedFastqRecord



def getCrisprData(filePath, projectID):
    #
    crisprData = list()
    
    for file in os.listdir(filePath):
        if file.endswith('.xlsx' or '.xls'):
            # print("Reading sample data from excel file for Project "+ projectID + "\n\n") 
            excelFile = excel_dir + '/' + projectID + '/' + file
            excelData = pd.read_excel(excelFile, skiprows = [0,1,2])
            excelData = excelData.where(pd.notnull(excelData), None)
            # take care of any blank cells 
            # excelData.fillna('', inplace = True)
            for i in range(0, len(excelData['Sample Name']), 1):
                sampleID = str(excelData['Sample Name'].loc[i])
                ampliconID = str(excelData['Amplicon Name'].loc[i])
                ampliconSeq = str(excelData['Amplicon Sequence'].loc[i])
                codingSeq = excelData['Coding Sequence'].loc[i]
                guideSeq = excelData['Guide Sequence'].loc[i]
                print("Sample = " + sampleID + ", amplicon = " + ampliconID + ", amplicon sequence = " + ampliconSeq)
                print("coding_sequence = " + str(codingSeq) + ", guide_sequence = " + str(guideSeq)) 
                # check to make sure sampleID or ampliconSeq is not empty or NULL
                if (sampleID == None):
                    print('SampleID is NULL. Please check the CRISPR Template file. Ending analysis now.')
                    quit()
                dataRecord = crispr(sampleID, ampliconID, ampliconSeq, codingSeq, guideSeq)
                crisprData.append(dataRecord)
        else:
                print('NO CRISPR Template file present. Ending analysis now.')
                quit()
                
    return crisprData



def crispresso2(fastqs, crisprRecord, projectDir):
    #
    # CRISPResso2 command
    CRISPRESSO2 = '/opt/local/singularity/3.6.2/bin/singularity run --bind /igo:/igo /igo/work/nabors/tools/crispresso/crispresso2-v2.0.30.simg CRISPResso'
    
    codingSeqData = ' --coding_seq ' + str(crisprRecord.codingSeq)
    guideSeqData = ' --guide_seq ' + str(crisprRecord.guideSeq)
    outputDir = ' --output_folder ' + projectDir
    
    crispresso2Run = CRISPRESSO2 + ' --fastq_r1 ' + fastqs.r1 + ' --fastq_r2 ' + fastqs.r2 + ' --amplicon_seq ' + crisprRecord.ampliconSeq + ' --min_paired_end_reads_overlap 10' + outputDir
    
    if (crisprRecord.codingSeq != None):
        crispresso2Run += codingSeqData
        
    if (crisprRecord.guideSeq != None):
        crispresso2Run += guideSeqData
    
    print(crispresso2Run)
    os.system(crispresso2Run)
        
    # if os.path.exists(outputDir):
        # os.system("rm -r " + outputDir + "/")
            
        # os.mkdir(path_sample_report)
        # os.system('mv ' + WORK + projectId + '/' + 'CRISPR*' + sample + "_IGO*" + " " + path_sample_report + "/")
        


def main():
    print('Version %s\n' % __version__)

    PYTHON3 = '/igo/work/nabors/tools/venvpy3/bin/python'
    PYTHON2 = '/igo/work/nabors/tools/venvpy2/bin/python'

    ACCESS = 0o775
    
    
    parser = argparse.ArgumentParser(prog = 'CRISPResso', usage = 'Run the pipeline for CRISPResso Analysis')
    parser.add_argument('-run', help = 'Provide the HiSeq Run name that contain the Project FASTQ files. Example - PITT_0142_BHLCT5BBXX', required = True)
    parser.add_argument('-proj', help = 'Project Number for analysis. Enter project number starting with 0. Example - 07900', required = True)
    parser.add_argument('-lane', help ='Optional - If Project run on multiple lanes, select one lane to run analysis on. Add the lane number you want to run analysis for. Example - L005', default = "")
    parser.add_argument('-subsample', help = 'Enter Y/N. Subsample 100,000 reads from original FASTQ file for analysis.Y/N', default = "N")
    parser.add_argument('-edir', help = 'Optional - Directory containing project subdirectories w/ excel inputs', default = "/pskis34/LIMS/LIMS_CRISPRSeq")
    parser.add_argument('-fdir', help = 'Directory to write CRISPRESSO output to', default = "/igo/staging/FASTQ/")
    parser.add_argument('-outdir', help = 'Directory to write CRISPRESSO output to', default = ".")

    args = parser.parse_args()
    runID = str(args.run).strip()
    projectID = str(args.proj).strip()
    lane = str(args.lane).strip()
    subsample = str(args.subsample).strip()
    excel_dir = str(args.edir).strip()
    fastq_root = str(args.fdir).strip()
    WORK =  str(args.outdir).strip()

    fastqDir = WORK + "/" + runID + "/Project_" + projectID + '/'

    print("****************************************** Starting CRISPRESSO for Project_" + projectID + " ******************************************")
    print("RUN ID = {}".format(runID))
    print("Project = {}".format(projectID))
    print("Lane = {}".format(lane))
    print("subsample = {}".format(subsample))
    print("Input Excel Directory = {}".format(excel_dir))
    print("Output Work Directory = {}".format(WORK))
    print("FASTQ Directory = {}".format(fastqDir))
    print("\n\n\n")

    if (lane == None):
        lane = ""

    # check to see if valid projectID
    if (runID == None) or (projectID == None):
        os.system('echo Please provide Run ID and Project in the arguments. For help type "python RunCrisprAnalysis.py --help"')
        quit()
        


    ################### Start Parsing Excel File with sample and amplicon data ################
    filePath = excel_dir + '/' + projectID + '/'
    
    # set WORKING DIRECTORY FOR PROJECTS
    projectDir = WORK + projectID + '/'
    os.chdir(WORK)
    # create folder
    folders = next(os.walk('.'))[1]
    if projectID not in folders:
        os.mkdir(projectID, ACCESS)
    
    
    # grab the excel data 
    crisprData = getCrisprData(filePath, projectID)
    
    # get samples
    sampleDirs = os.listdir(fastqDir)
    # print(sampleDirs)
    
    fastqData = dict()
    
    for sample in sampleDirs:
        sampleFastqDir = fastqDir + sample + '/'
        fastqFiles = os.listdir(sampleFastqDir)
        fastqFiles.sort()
        r1 = sampleFastqDir + fastqFiles[0]
        r2 = sampleFastqDir + fastqFiles[1]
        i = sample.find('_IGO')
        sampleID = sample[7:i]
        # sampleID = sample[7:]
        print("SampleID >>> " + sampleID)
        fastqRec = fastq(r1, r2)
        fastqData[sampleID] = fastqRec
        
        
    # Run fastqs thru CRISPResso2  if needed, pad fastqs
    for crisprRecord in crisprData:
        #
        # print('AMPLiCON SIZE = ', (len(crisprRecord.ampliconSeq)))
        # check length of reference sequences.  if Greater than 196, we will need to pad the fastqs
        if (len(crisprRecord.ampliconSeq) >= 196):
            fastqRecord = padSamples(projectID, projectDir, crisprRecord, fastqData[crisprRecord.sampleID])
            crispresso2(fastqRecord, crisprRecord, projectDir)
        else:
            crispresso2(fastqData[crisprRecord.sampleID], crisprRecord, projectDir)
    


if __name__ == "__main__":
        main()




