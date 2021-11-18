#!/usr/bin/env python

import csv
import pandas as pd
import numpy as np
import argparse
import os
from functools import reduce

###################################
######   SAMPLESHEET SETUP   ######
###################################
# STEP 1 - ADD NEW EXTENSION, EXT_*
EXT_10X = '_10X.csv'
EXT_MLT = '_10X_Multiome.csv'
EXT_DLP = '_DLP.csv'
EXT_WGS = '_WGS.csv'
EXT_PPG = '_PPG.csv'
EXT_REG = '.csv'
# STEP 2 - ADD EXT_* VARIABLE HERE
EXTENSIONS = [EXT_10X, EXT_MLT, EXT_DLP, EXT_WGS, EXT_PPG, EXT_REG]
# STEP 3 - ADD IDX_* HERE
DF_IDX_10X = EXTENSIONS.index(EXT_10X)
DF_IDX_MLT = EXTENSIONS.index(EXT_MLT)
DF_IDX_DLP = EXTENSIONS.index(EXT_DLP)
DF_IDX_WGS = EXTENSIONS.index(EXT_WGS)
DF_IDX_PPG = EXTENSIONS.index(EXT_PPG)
DF_IDX_REG = EXTENSIONS.index(EXT_REG)
# CREATES GLOBAL DF - Stores SampleSheet info for each EXT_*
NO_DATA = pd.DataFrame()    # empty data set for comparison
DATA_SHEETS = [ NO_DATA for ext in EXTENSIONS ]

def get_sample_sheet_name(sample_sheet):
	""" Retrieves the samplesheet filename from the absolute path to the samplesheet
	:param sample_sheet_file, str: absolute path to sample sheet
	:return: string
	"""
	sample_sheet_parts = sample_sheet.split("/")
	sample_sheet_file_name = sample_sheet_parts[-1]
	sample_sheet_base = sample_sheet_file_name.split(".")[0]
	return sample_sheet_base

def tenx_genomics(sample_data, header):
	tenx_data = sample_data[ sample_data["index2"].str.match('^SI-.*') == True ].copy()
	sample_data = sample_data[ sample_data["index2"].str.match('^SI-.*') == False ].copy()
	DATA_SHEETS[DF_IDX_REG] = sample_data

	# Remove dual-index b/c older versions of cellranger would fail if 'index2' was included in the samplesheet
	tenx_data.drop(['index2'], inplace = True, axis = 1)

    # Multiome requests need to be written to their own samplesheet and demultiplexed w/ cellranger-arc
	tenx_genomics_regular_data = tenx_data[ tenx_data["Sample_Well"].str.contains("Multiome") == False ].copy()
	tenx_genomics_multiome_data = tenx_data[ tenx_data["Sample_Well"].str.contains("Multiome") == True ].copy()

	if not tenx_genomics_regular_data.empty:
		DATA_SHEETS[DF_IDX_10X] = tenx_genomics_regular_data
	if not tenx_genomics_multiome_data.empty:
		DATA_SHEETS[DF_IDX_MLT] = tenx_genomics_multiome_data

def dlp(sample_data, header):
	dlp_data = sample_data[ sample_data["Sample_Well"].str.match("DLP") == True ].copy()
	sample_data = sample_data[ sample_data["Sample_Well"].str.match("DLP") == False ].copy()
	DATA_SHEETS[DF_IDX_REG] = sample_data
	if not dlp_data.empty:
		DATA_SHEETS[DF_IDX_DLP] = dlp_data

def wgs(sample_data, header):
	all_hwg_data = sample_data[ sample_data["Sample_Well"].str.match("HumanWholeGenome") == True ].copy()
	sample_data = sample_data[ sample_data["Sample_Well"].str.match("HumanWholeGenome") == False ].copy()

	wgs_data = all_hwg_data[ all_hwg_data['Sample_Project'].str.contains("Project_08822") == False ].copy()
	ped_peg_data = all_hwg_data[ all_hwg_data['Sample_Project'].str.contains("Project_08822") == True ].copy()

	DATA_SHEETS[DF_IDX_REG] = sample_data
	if not wgs_data.empty:
		DATA_SHEETS[DF_IDX_WGS] = wgs_data.copy()
	if not ped_peg_data.empty:
		DATA_SHEETS[DF_IDX_PPG] = ped_peg_data

def create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets = None):
	# Check to see if any samplesheet other than the last one has been populated
	no_changes = reduce(lambda all_dfs_empty, df : all_dfs_empty and df.equals(NO_DATA), DATA_SHEETS[:-1], True)
	if no_changes:
		print('NO CHANGES MADE TO THE ORIGINAL SAMPLE SHEET')
	else:
		print('WRITING NEW SAMPLE SHEETS: ' + processed_dir)

	# go to new DividedSampleSheets directory
	os.chdir(processed_dir)

	# create a csv sheet for all valid data sheets
	for y in range(0, len(DATA_SHEETS), 1):
		# break the loop in there were no changes in regular sample sheet or all of the samples were 10X, DLP or PADDED
		if DATA_SHEETS[y].empty:
			continue
		else:
			DATA_SHEETS[y].sort_values('Lane')
			data_element_list = DATA_SHEETS[y].T.reset_index().values.T.tolist()
			data_element_sample_sheet = top_of_sheet + data_element_list

			data_element_sample_sheet_name = sample_sheet_name + EXTENSIONS[y]
			print("Writing " + data_element_sample_sheet_name)
			data_element_csv_file = open(data_element_sample_sheet_name, 'w')
			with data_element_csv_file:
				writer = csv.writer(data_element_csv_file)
				writer.writerows(data_element_sample_sheet)
			data_element_csv_file.close()
			if created_sample_sheets:
				f = open(created_sample_sheets, "a")
				f.write("{}/{}\n".format(processed_dir, data_element_sample_sheet_name))
				f.close()

def main():
	parser = argparse.ArgumentParser(description = 'This script takes a dual indexed sample sheet and splits it if there are DLP, PADDED or 10X indices')
	parser.add_argument('--sample-sheet', type = str, required = True, help = 'The name and path of the sample sheet to be split')
	parser.add_argument('--processed-dir', type = str, required = True, help = 'Directory to write processed sample sheets to')
	parser.add_argument('--output-file', type = str, required = False, help = '(Optional) File to write names of created sample-sheets')
	args = parser.parse_args()

	# grab sample sheet
	sample_sheet = args.sample_sheet
	processed_dir = args.processed_dir
	created_sample_sheets = args.output_file

	output="SAMPLE SHEET={}, PROCESSED DIR={}".format(sample_sheet, processed_dir)
	if created_sample_sheets:
		working_dir = os.getcwd()
		created_sample_sheets = "{}/{}".format(working_dir, created_sample_sheets)
		output += ", OUTPUT FILE={}".format(created_sample_sheets)
	print(output)

	# this will hold the top of the sample sheet
	top_of_sheet = list()

	# this will hold the sample data portion of the sheet
	csv_sample_data = list()
	barcode_types = list()

	with open(sample_sheet) as csv_file:
		csv_reader = csv.reader(csv_file, delimiter = ',')
		got_data = False
		for row in csv_reader:
			if (row[0] != 'Lane') and (got_data is False):
				top_of_sheet.append(row)
			elif (row[0] == 'Lane'):
				got_data = True
				header = row
			elif got_data:
				csv_sample_data.append(row)

	# this is the data part of the sheet
	sample_data = pd.DataFrame(csv_sample_data, columns = header)
	# check to see if 'index2'  in header, if not set dual_index = False
	dual_index = False if 'index2' not in header else True

	sample_sheet_name = get_sample_sheet_name(sample_sheet)

	# testing to see if we have dual barcodes, if not, we just quit.
	# first check for 10X samples
	if dual_index:
		# check for 10X samples
		tenx_genomics(sample_data, header)

		# call the DLP routine
		dlp(DATA_SHEETS[DF_IDX_REG], header)

		# routine for taking out HumanWholeGenome
		wgs(DATA_SHEETS[DF_IDX_REG], header)

		create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets)
	
if __name__ == '__main__':
	main()
