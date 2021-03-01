#!/usr/bin/env /igo/work/nabors/tools/venvpy2/bin/python

import csv
import pandas as pd
import numpy as np
import argparse
import os

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
	data_sheets[4] = sample_data
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
	data_sheets[4] = sample_data
	if not dlp_data.empty:
		data_sheets[1] = dlp_data
		
		
def wgs(sample_data, header):
	# create empty data frame
	wgs_data = pd.DataFrame(columns = header)
	# test for wgs data
	for x in range(0, len(sample_data['Sample_Well']), 1):
		if (sample_data['Sample_Well'].loc[x] == 'HumanWholeGenome'):
			wgs_data.loc[x] = sample_data.loc[x]
			sample_data.drop([x], inplace = True, axis = 0)
	# clean up index and move regular sample sheet to the last element of the list
	wgs_data.index = range(len(wgs_data))
	sample_data.index = range(len(sample_data))
	data_sheets[4] = sample_data
	if not wgs_data.empty:
		data_sheets[3] = wgs_data
			
		
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
	data_sheets[4] = sample_data

	#  Remove the second index
	i7_data = i7_data.drop(columns=['index2'])

	if not i7_data.empty:
		data_sheets[2] = i7_data


def create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets = None):
	# check to see if sample sheet has been manipulated in any way
	if (data_sheets[0].equals(no_data)) and (data_sheets[1].equals(no_data)) and (data_sheets[2].equals(no_data)) and (data_sheets[3].equals(no_data)):
		print('NO CHANGES MADE TO THE ORIGINAL SAMPLE SHEET')
	else:
		print('WRITING NEW SAMPLE SHEETS: ' + processed_dir)
	# list for sample sheet extensions
	extensions = ['_10X.csv', '_DLP.csv', '_i7.csv', '_WGS.csv', '.csv']
	
	# Write sample sheet to processed location
	os.chdir(processed_dir)
	
	# create a csv sheet for all valid data sheets
	for y in range(0, len(data_sheets), 1):
		# break the loop in there were no changes in regular sample sheet or all of the samples were 10X, DLP or PADDED
		if data_sheets[y].empty:
			continue
		else:
			data_sheets[y].sort_values('Lane')
			# print(data_element['Lane'])
			data_element_list = data_sheets[y].T.reset_index().values.T.tolist()
			# print(data_element_list)
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
			
			# ext = extensions[data_sheets.index(data_element)]
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

def get_sample_sheet_name(sample_sheet):
	sample_sheet_parts = sample_sheet.split("/")
	sample_sheet_file_name = sample_sheet_parts[-1]
	sample_sheet_base = sample_sheet_file_name.split(".")[0]
	return sample_sheet_base

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
	# 0 = 10X, 1 = DLP, 2 = i7 only, 3 = HumanWholeGenome, 4 = rest of sample sheet
	global data_sheets, no_data, dual_index
	dual_index = True  
	# empty data set for comparison
	no_data = pd.DataFrame()
	data_sheets = [no_data, no_data, no_data, no_data, no_data]
		
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
				# got_data is False
				top_of_sheet.append(row)
			elif (row[0] == 'Lane'):
				got_data = True
				header = row
			# elif (got_data is True):
			elif got_data:
				csv_sample_data.append(row)	
	# this is the data part of the sheet
	sample_data = pd.DataFrame(csv_sample_data, columns = header)
	
	# check to see if 'index2'  in header, if not set dual_index = False
	if 'index2' not in header:
		dual_index = False

	sample_sheet_name = get_sample_sheet_name(sample_sheet)

	# testing to see if we have dual barcodes, if not, we just quit.
	# first check for 10X samples
	if dual_index:
		# check for 10X samples
		tenx_genomics(sample_data, header)	   
	
		# call the DLP routine
		dlp(data_sheets[4], header)
		
		# routine for taking out HumanWholeGenome
		wgs(data_sheets[4], header)
		
		# check for padding
		i7_only(data_sheets[4], header)
	
		# did we have to split sample sheets?
		create_csv(top_of_sheet, sample_sheet_name, processed_dir, created_sample_sheets)
	
if __name__ == '__main__':
	main()
