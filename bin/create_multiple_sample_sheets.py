#!/usr/bin/env python

import csv
import pandas as pd
import numpy as np
import argparse
import os

""" Set of barcodes that should be masked to just the first 6 nucleotides
"""
BARCODE_6NT_SET = set()
BARCODE_6NT_SET.update([ '{}'.format(i) for i in range(7001,7097) ])            # 7001-7096
BARCODE_6NT_SET.update([ 'BC{}'.format(i) for i in range(1,9) ])                # BC1-8
BARCODE_6NT_SET.update([ 'BK{}'.format(i) for i in range(25,44) ])              # BK25-43
BARCODE_6NT_SET.update([ 'BK10{}'.format(i) for i in range(1,10) ])             # BK101-109
BARCODE_6NT_SET.update([ 'BK{}'.format(i) for i in range(7098,7101) ])          # BK7098-7100
BARCODE_6NT_SET.update([ 'Vakoc_{}'.format(i/10.0) for i in range(71,109) ])    # Vakoc_7.1-10.8
BARCODE_6NT_SET.update([ 'TS{}'.format(i) for i in range(1,28) ])               # TS1-27
BARCODE_6NT_SET.update([ 'Tsou_{}'.format(i) for i in range(1,13) ])            # Tsou_1-12
BARCODE_6NT_SET.update([ 'RPI{}'.format(i) for i in range(1,49) ])              # RPI1-48
BARCODE_6NT_SET.update([ 'NEBNext{}'.format(i) for i in range(1,28) ])          # NEBNext1-27
BARCODE_6NT_SET.update([ 'NF{}'.format(i) for i in range(1,49) ])               # NF1-48
BARCODE_6NT_SET.update([ 'Overholtzer_{}'.format(i) for i in range(1,5) ])      # Overholtzer_1-4
BARCODE_6NT_SET.update([ 'KAPA_{}'.format(i) for i in range(1,13) ])            # KAPA_1-12
BARCODE_6NT_SET.update([ 'Garippa_{}'.format(i) for i in range(2,46) ])         # Garippa_2-45
BARCODE_6NT_SET.update([ 'IDT-TS{}'.format(i) for i in range(1,49) ])           # IDT-TS1-48
BARCODE_6NT_SET.update([ 'DMP{}'.format(i) for i in range(1,49) ])              # DMP1-48

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
	# create empty data frame
	tenx_genomics_data = pd.DataFrame(columns = header)
	# check for 10X samples in index2 of the sample sheet
	for x in range(0, len(sample_data['index2']), 1):
		if ('SI-' in sample_data['index2'].loc[x]):
			tenx_genomics_data.loc[x] = sample_data.loc[x]  
			sample_data.drop([x], inplace = True, axis = 0)   	
	# drop index2 column for 10X sample data
	tenx_genomics_data.drop(['index2'], inplace = True, axis = 1)   #this works
	# move regular sample sheet to the last element of the list	
	tenx_genomics_data.index = range(len(tenx_genomics_data))
	sample_data.index = range(len(sample_data))
	data_sheets[6] = sample_data
	if not tenx_genomics_data.empty:
		data_sheets[0] = tenx_genomics_data

		
def dlp(sample_data, header):
	# create empty data frame
	dlp_data = pd.DataFrame(columns = header)
	# test for DLP data
	for x in range(0, len(sample_data['Sample_Well']), 1):
		if (sample_data['Sample_Well'].loc[x] == 'DLP'):
			dlp_data.loc[x] = sample_data.loc[x]
			sample_data.drop([x], inplace = True, axis = 0)
	# clean up index and  move regular sample sheet to the last element of the list
	dlp_data.index = range(len(dlp_data))
	sample_data.index = range(len(sample_data))
	data_sheets[6] = sample_data
	if not dlp_data.empty:
		data_sheets[1] = dlp_data
		
		
def wgs(sample_data, header):
	# create empty data frame
	wgs_data = pd.DataFrame(columns = header)
	ped_peg_data = pd.DataFrame(columns = header)
	# test for wgs data
	for x in range(0, len(sample_data['Sample_Well']), 1):
		if (sample_data['Sample_Well'].loc[x] == 'HumanWholeGenome'):
			if ('Project_08822' in sample_data['Sample_Project'].loc[x]):
				ped_peg_data.loc[x] = sample_data.loc[x]
				sample_data.drop([x], inplace = True, axis = 0)
			else:
				wgs_data.loc[x] = sample_data.loc[x]
				sample_data.drop([x], inplace = True, axis = 0)
	# clean up index and move regular sample sheet to the last element of the list
	wgs_data.index = range(len(wgs_data))
	ped_peg_data.index = range(len(ped_peg_data))
	sample_data.index = range(len(sample_data))
	data_sheets[6] = sample_data
	if not wgs_data.empty:
		data_sheets[3] = wgs_data
	if not ped_peg_data.empty:
		data_sheets[4] = ped_peg_data

def is_6nt_index(index_name):
    """ Returns whether the input index_name is an index that should be masked to the first 6 nucleotides
    :param index_name, str: value of index name     e.g. "7001"
    :return: bool                                   e.g. True
    """
    return index_name in BARCODE_6NT_SET

def has_6nt(sample_data, header):
	""" Creates a 6_nt dataframe if 6nt indices are present
			Side Effects:
				- Modifies @sample_data in-place (Removes and re-orders indices)
				- Creates a 6_nt dataframe and adds it to global @data_sheets

	:param sample_data, df: original sample sheet
	:param sample_data, header: original sample sheet headers

	:return: bool, was a 6_nt dataframe created
	"""
	# create empty data frame for padded requests
	has_6nt_data = pd.DataFrame(columns = header)
	for x in range(0, len(sample_data), 1):
		i7_index = sample_data['index'].loc[x]
		i7_index_name = sample_data['I7_Index_ID'].loc[x]
		if (is_6nt_index(i7_index_name) and len(i7_index) > 6):
			# Mark & modify samplesheet if the i7_index is recognized as a 6nt and the i7 index isn't already length 6
			has_6nt_data.loc[x] = sample_data.loc[x]
			has_6nt_data['index'].loc[x] = i7_index[:6]      # We only need the first 6 nucleotides
			sample_data.drop([x], inplace = True, axis = 0)

	if not has_6nt_data.empty:
		data_sheets[5] = has_6nt_data
		# Reset the index to 0 (if this isn't done, the indices of sample_data will have missing positions that will cause errors)
		sample_data.index = range(len(sample_data))
		data_sheets[6] = sample_data
		return True

	return False

def i7_only(sample_data, header):
	# create empty data frame for padded requests
	i7_data = pd.DataFrame(columns = header)
	# get a list of individual requests
	requests = set(sample_data['Sample_Project'])
	# use for testing thew length of 'index2'
	len_req_samples = 0
	len_index2 = 0
	for req in requests:
		# check index2 to see if the same index, this would indicate padding
		#  put the groupby step here to avoid random errors from an earlier experience
		requests_group = sample_data.groupby(['Sample_Project'], as_index = False)
		req_group = requests_group['Sample_Name'].get_group(req)
		req_samples = set(req_group)
		len_req_samples = len(req_samples)
		len_index2 = len(set(requests_group['index2'].get_group(req)))
		if (len_req_samples > 1) and (len_index2 == 1):
			# move the padded project to another data frame
			i7_data = i7_data.append(requests_group.get_group(req))
			sample_data.drop(sample_data[sample_data['Sample_Project'] == req].index, inplace = True)
	# move regular sample sheet to the last element of the list	
	i7_data.index = range(len(i7_data))
	sample_data.index = range(len(sample_data))
	data_sheets[6] = sample_data
	if not i7_data.empty:
		data_sheets[2] = i7_data

def create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets = None):
	# check to see if sample sheet has been manipulated in any way
	if (data_sheets[0].equals(no_data)) and (data_sheets[1].equals(no_data)) and (data_sheets[2].equals(no_data)) and (data_sheets[3].equals(no_data)) and (data_sheets[4].equals(no_data)) and (data_sheets[5].equals(no_data)):
		print('NO CHANGES MADE TO THE ORIGINAL SAMPLE SHEET')
	else:
		print('WRITING NEW SAMPLE SHEETS: ' + processed_dir)
	# list for sample sheet extensions
	extensions = ['_10X.csv', '_DLP.csv', '_i7.csv', '_WGS.csv', '_PPG.csv', '_6nt.csv', '.csv']
	
	# go to new DividedSampleSheets directory
	os.chdir(processed_dir)

	# create a csv sheet for all valid data sheets
	for y in range(0, len(data_sheets), 1):
		# break the loop in there were no changes in regular sample sheet or all of the samples were 10X, DLP or PADDED
		if data_sheets[y].empty:
			continue
		else:
			data_sheets[y].sort_values('Lane')
			data_element_list = data_sheets[y].T.reset_index().values.T.tolist()

			# for BCL CONVERSION on DRAGEN, we must delete the "Adapter" tag in the SETTINGS section ( delete row 14 )
			if y == 3:
				# swap headings for SAMPLE_ID and SAMPLE_NAME ROWS
				data_element_list[0][1] = 'Sample_Name'
				data_element_list[0][2] = 'Sample_ID'
				# wgs_top_of_sheet = top_of_sheet.copy()   # for python 3.3 and later
				wgs_top_of_sheet = top_of_sheet[:]
				del wgs_top_of_sheet[14]
				data_element_sample_sheet = wgs_top_of_sheet + data_element_list
			else:
				data_element_sample_sheet = top_of_sheet + data_element_list

			data_element_sample_sheet_name = sample_sheet_name + extensions[y]
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
	
	# hold area for the sample sheet created
	# index listing
	# 0 = 10X, 1 = DLP, 2 = padded, 3 = HumanWholeGenome, 4 = PED-PEG, 5 = 6nt, 6 = rest of sample sheet
	global data_sheets, no_data, dual_index
	dual_index = True  
	# empty data set for comparison
	no_data = pd.DataFrame()
	data_sheets = [no_data, no_data, no_data, no_data, no_data, no_data, no_data]
		
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
	if 'index2' not in header:
		dual_index = False

	sample_sheet_name = get_sample_sheet_name(sample_sheet)

	# 6nt barcodes
	made_6nt_sample_sheet = has_6nt(sample_data, header)
	if made_6nt_sample_sheet:
	    # RE-ASSIGN 6nt Samples - an input sample_data w/ 6nt samples will have its 6nt samples removed. The remaining
	    # samples are placed in data_sheets[6]
	    sample_data = data_sheets[6]

	# testing to see if we have dual barcodes, if not, we just quit.
	# first check for 10X samples
	if dual_index:
		# check for 10X samples
		tenx_genomics(sample_data, header)

		# call the DLP routine
		dlp(data_sheets[6], header)

		# routine for taking out HumanWholeGenome
		wgs(data_sheets[6], header)

		# check for padding
		i7_only(data_sheets[6], header)

	if dual_index or made_6nt_sample_sheet:
		# did we have to split sample sheets?
		create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets)
	
if __name__ == '__main__':
	main()
