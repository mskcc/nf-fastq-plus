import csv
import pandas as pd
import numpy as np
import argparse
import os
import glob
from xml.etree import ElementTree
from subprocess import call

# GLOBAL CONSTANTS
BCL2FASTQ_FRONT = ' -n 36 -M 6 /opt/common/CentOS_6/bcl2fastq/bcl2fastq2-v2.20.0.422/bin/bcl2fastq --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0 --ignore-missing-bcl  --runfolder-dir '
BCL2FASTQ_BACK = ' --ignore-missing-filter --ignore-missing-positions --ignore-missing-control --barcode-mismatches 1 --no-lane-splitting  --loading-threads 12 --processing-threads 24 2>&1 >> /home/igo/log/bcl2fastq.log'
BSUB = 'bsub -K -J '


def check_list(sample_sheets):
	print('we are here!!!')
	for x in sample_sheets:
		print(x)
		# check the extensions of the sample sheet
		if '_10X.csv' in x:
			tenx_genomics(x)
		elif '_PAD.csv' in x:
			padding(x)
		elif '_WGS.csv' in x:
			dragen(x)
		else:
			bcl2fastq(x)


def bcl2fastq(sample_sheet):
	print('demux as normal')
	# make the correct directory names
	ss = sample_sheet.split('/')[5]
	print(ss)
	if '_DLP' not in ss:
		run_dir = ss[12:-4]
	else:
		run_dir = ss[12:-8]
	sequencer_and_run =  ss[19:-4]
	sequencer = sequencer_and_run.split('_')[0].lower()
	print('RUN-DIR = ' + run_dir)
	print('SEQUENCER-AND-RUN = ' + sequencer_and_run)
	print('SEQUENCER = ' + sequencer)
	# lets put it together!
	bcl2fastq_command = BSUB + 'BCL2FASTQ__' + sequencer_and_run + ' -o ' + 'BCL2FASTQ__' + sequencer_and_run + '.log' + BCL2FASTQ_FRONT + '/igo/sequencers/' + sequencer + '/' + run_dir + ' --sample-sheet ' + sample_sheet + ' --output-dir /igo/work/FASTQ/' + sequencer_and_run + BCL2FASTQ_BACK
	print(bcl2fastq_command)
	# call(bcl2fastq_command, shell = True)	 
			
				
def tenx_genomics(sample_sheet):
	print('demux with 10X')
	# make the correct directory names
	ss = sample_sheet.split('/')[5]
	run_dir = ss[12:-8]
	sequencer_and_run =  ss[19:-4]
	sequencer = sequencer_and_run.split('_')[0].lower()
	print('RUN-DIR = ' + run_dir)
	print('SEQUENCER-AND-RUN = ' + sequencer_and_run)
	print('SEQUENCER = ' + sequencer)
	# mkfastq constants
	MKFASTQ_FRONT = ' -n 36 -M 6 /igo/work/bin/cellranger-4.0.0/cellranger mkfastq --input-dir '
	MKFASTQ_BACK = ' --nopreflight --jobmode=local --localmem=64 --localcores=36  --barcode-mismatches 1'
	# lets put it together!
	mkfastq_command = BSUB + 'CELLRANGER-MKFASTQ__' + sequencer_and_run + ' -o ' + 'CELLRANGER-MKFASTQ__' + sequencer_and_run + '.log' + MKFASTQ_FRONT + '/igo/sequencers/' + sequencer + '/' + run_dir + ' --sample-sheet ' + sample_sheet + ' --output-dir /igo/work/FASTQ/' + sequencer_and_run + MKFASTQ_BACK
	print(mkfastq_command)
	# call(mkfastq_command, shell = True)
	return
		
	
def padding(sample_sheet):
	print('demux with PAD - mask out')
	ss = sample_sheet.split('/')[5]
	run_dir = ss[12:-8]
	sequencer_and_run =  ss[19:-4]
	sequencer = sequencer_and_run.split('_')[0].lower()
	print('RUN-DIR = ' + run_dir)
	print('SEQUENCER-AND-RUN = ' + sequencer_and_run)
	print('SEQUENCER = ' + sequencer)
	# get run data from RunInfo.xml
	run_info_location = '/igo/sequencers/' + sequencer + '/' + run_dir
	use_bases_mask = get_run_data(run_info_location)
	# print(use_bases_mask)
	# lets put it together!
	bcl2fastq_command = BSUB + 'BCL2FASTQ__' + sequencer_and_run + ' -o ' + 'BCL2FASTQ__' + sequencer_and_run + '.log' + BCL2FASTQ_FRONT + '/igo/sequencers/' + sequencer + '/' + run_dir + ' --sample-sheet ' + sample_sheet + ' --output-dir /igo/work/FASTQ/' + sequencer_and_run + use_bases_mask + BCL2FASTQ_BACK
	print(bcl2fastq_command)
	# call(bcl2fastq_command, shell = True)
	return	
	
	
def get_run_data(run_info_location):
	# add RunInfo.xml constant
	run_info_file = run_info_location + '/RunInfo.xml'
	tree = ElementTree.parse(run_info_file)
	root = tree.getroot()
	reads_tag = list()
	# get the run data!
	for child in root.iter('Read'):
		read_data = list()
		read_data.append(child.attrib.get('Number', None))
		read_data.append(int(child.attrib.get('NumCycles', None)))
		read_data.append(child.attrib.get('IsIndexedRead', None))
		reads_tag.append(read_data)
	use_bases_mask = ' --use-bases-mask y' + str(reads_tag[0][1] - 1) + 'n,i' + str(reads_tag[1][1]) + ',n' + str(reads_tag[2][1]) + ',y' + str(reads_tag[3][1] - 1) + 'n '
	return use_bases_mask
		
	
def dragen(sample_sheet):
	print('demux on DRAGEN server')
	# make the correct directory names
	ss = sample_sheet.split('/')[5]
	run_dir = ss[12:-8]
	sequencer_and_run =  ss[19:-4]
	sequencer = sequencer_and_run.split('_')[0].lower()
	print('RUN-DIR = ' + run_dir)
	print('SEQUENCER-AND-RUN = ' + sequencer_and_run)
	print('SEQUENCER = ' + sequencer)
	DRAGEN_FRONT = ' -q dragen -n 48 -M 4 /opt/edico/bin/dragen --bcl-conversion-only true --bcl-input-directory '
	# lets put it together!
	dragen_bcl_conversion_command = BSUB + 'DRAGEN-BCL-CONVERSION__' + sequencer_and_run + ' -o ' + 'DRAGEN-BCL-CONVERSION__' + sequencer_and_run + '.log' + DRAGEN_FRONT + '/igo/sequencers/' + sequencer + '/' + run_dir + ' --sample-sheet ' + sample_sheet + ' --output-directory /igo/work/FASTQ/' + sequencer_and_run + ' --bcl-sampleproject-subdirectories true'
	print(dragen_bcl_conversion_command)
	# call(dragen_bcl_conversion_command, shell = True)
	return	
		

def main():
		
	parser = argparse.ArgumentParser(description = 'This script takes a dual indexed sample sheet and splits it if there are DLP, PADDED or 10X indices')
	parser.add_argument('--sample-sheet', type = str, required = True, help = 'The name and path of the sample sheet to be split')
	args = parser.parse_args()
		
	# grab sample sheet and create the seach criteria
	sample_sheet_search = '/igo/home/igo/DividedSampleSheets/' + args.sample_sheet[:-4] + '*.csv'
	# whenever we need the original sample sheet 
	sample_sheet = '/igo/home/igo/SampleSheetCopies/' + args.sample_sheet
	
	print(sample_sheet_search)
	
	# if there are multiple sample sheets of the same run, grab them for demuxing
	sample_sheets = list(glob.iglob(sample_sheet_search))

	print(sample_sheets)
	
	if len(sample_sheets) > 1:
		# start process of demuxing
		print('need to start process')
		check_list(sample_sheets)
	else:
		# we can just demux original run
		print('just demux original')
		bcl2fastq(sample_sheet)
	
if __name__ == '__main__':
	main()
