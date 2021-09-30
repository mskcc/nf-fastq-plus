#!/usr/bin/env python2.7

from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from collections import Counter
import gzip
import argparse
import sys
import os
import numpy
import logging, math
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

__version__ = "1.0.1"

"""
Description: To extend the sequencing reads for CRISPResso and other analysis softwares. Sequencing Read1 and Read2
             are extended to provide a maximum overlap between Read1 and Read2 is 10bp. This is important because
             CRISPResso software penalize Reads that overlaps more than certain number of basepairs.
			 The script looks for 10bp Tag sequence at the end of the reads and finds it on the reference sequence.
			 If the tag is not found next 10bp are considered as TAG sequence. If a match is found, the location of
			 the tag sequence on read1 and on reference sequence are then used to extend the sequencing reads with
			 the reference sequence provided for CRISPR projects.
"""

nt_complement = dict({'A':'T', 'C':'G', 'G':'C', 'T':'A', 'N':'N', '_':'_', '-':'-'})


# Reverse compliment the reference sequence
def reverse_complement(seq):
    return "".join([nt_complement[c] for c in seq.upper()[-1::-1]])


# Check if any of the sequences have invalid characters, especially user provided reference sequences.
def find_wrong_nt(sequence):
    return list(set(sequence.upper()).difference(set(['A', 'T', 'C', 'G', 'N'])))


# Check for fastq files
def check_file(filename):
    try:
        with open(filename): pass
    except IOError:
        raise Exception('I cannot open the file: ' + filename)


# Read Sequencing fastq files
def readFASTQ(fastq_filename):
    #
    if fastq_filename.endswith('.gz'):
        fastq_handle = gzip.open(fastq_filename)
    else:
        fastq_handle = open(fastq_filename)
        
    for record in SeqIO.parse(fastq_handle, "fastq"):
        yield record
        
        # print(record)
        
        # for title, seq, qual in FastqGeneralIterator(fastq_handle):
        # yield seq


""" Sequencing reads for Read1 and Read2 are mix of forward and reverse seqences.
    This method is to find read1 tag_sequence on forward read and read2 tag sequence
    on reverse compliment of reference sequence."""
        
def find_tag_on_reference(tag_len, read1, read2, ref_sequence, reverse_complement):
    foundR1tag = False
    foundR2tag = False

    results = []

    end_R1tag = tag_len
    end_R2tag = tag_len

    start_R1tag = 0
    start_R2tag = 0

    tagR1_sequence = read1[-end_R1tag:]  # tag sequence on read1
    tagR2_sequence = read2[-end_R2tag:]  # tag sequence on read2


    pos = ref_sequence.find(str(tagR1_sequence.seq))  # find tagR1_sequence on forward strand of reference sequence
    pos2 = reverse_complement.find(str(tagR2_sequence.seq)) # find tagR2_sequence on reverse compliment of reference sequence

    # if position of tagR1 is found add it to results along with its sequence and distance form the end of the read.
    if pos > -1:
        foundR1tag = True
        results.append(pos)
        results.append(tagR1_sequence)
        results.append(end_R1tag)

 	# if position of tagR2 is found add it to results along with its sequence and distance form the end of the read.
    if pos2 > -1:
        foundR2tag = True
        results.append(pos2)
        results.append(tagR2_sequence)
        results.append(end_R2tag)

    # if position of tagR1 is not found take next 10bp as tag and search again until found or end of read1 sequence is reached.
    if not foundR1tag and not pos > -1:
        i = 1
        max_iterations = len(read1) % tag_len

        while i <= max_iterations and not foundR1tag:
            i += 1
            end_R1tag += tag_len
            start_R1tag += tag_len
            tagR1_sequence = read1[-end_R1tag:-start_R1tag]
            pos = ref_sequence.find(str(tagR1_sequence.seq))

            if pos > -1:
                foundR1tag = True
                results.append(pos)
                results.append(tagR1_sequence)
                results.append(end_R1tag)

    # if position of tagR2 is not found take next 10bp as tag and search again until found or end of read2 sequence is reached.
    if not foundR2tag and not (pos2 > -1):
        j = 1
        max_iterations = len(read2) % tag_len

        while j <= max_iterations and not foundR2tag:
            j +=1
            end_R2tag += tag_len
            start_R2tag += tag_len
            tagR2_sequence = read2[-end_R2tag:-start_R2tag]
            pos2 = reverse_complement.find(str(tagR2_sequence.seq))

            if pos2 > -1:
                foundR2tag = True

                results.append(pos2)
                results.append(tagR2_sequence)
                results.append(end_R2tag)


    if not (pos > -1) or not (pos2 > -1):
        results.append(pos)
        results.append(tagR1_sequence)
        results.append(end_R1tag)
        results.append(pos2)
        results.append(tagR2_sequence)
        results.append(end_R2tag)

    return results # an array with all the needed values is returned.



""" Sequencing reads for Read1 and Read2 are mix of forward and reverse seqences.
    This method is to find read1 tag_sequence on reverse compliment of reference sequence
    and read2 tag on forward strand of reference sequence."""
    
def find_tag_on_revCompliment(tag_len, read1, read2, ref_sequence, reverse_complement):
    # print("Processing reverse reads")
    foundR1tag = False
    foundR2tag = False

    results = []

    end_R1tag = tag_len
    end_R2tag = tag_len

    start_R1tag = 0
    start_R2tag = 0

    tagR1_sequence = read1[-end_R1tag:] # tag sequence on read1
    tagR2_sequence = read2[-end_R2tag:] # tag sequence on read2


    posReverseComp = reverse_complement.find(str(tagR1_sequence.seq)) # find tagR1_sequence on reverse compliment of reference sequence
    pos2ReverseComp = ref_sequence.find(str(tagR2_sequence.seq))      # find tagR2_sequence on forward strand of reference sequence

    # if position of tagR1 is found add it to results along with its sequence and distance form the end of the read.
    if posReverseComp > -1:

        foundR1tag = True
        results.append(posReverseComp)
        results.append(tagR1_sequence)
        results.append(end_R1tag)

    # if position of tagR2 is found add it to results along with its sequence and distance form the end of the read.
    if pos2ReverseComp > -1:
        foundR2tag = True
        # print("found rev R2tag")
        results.append(pos2ReverseComp)
        results.append(tagR2_sequence)
        results.append(end_R2tag)

    # if position of tagR1 is not found take next 10bp as tag and search again until found or end of read1 sequence is reached.
    if not foundR1tag and not posReverseComp>-1:
        i = 1
        max_iterations = len(read1) % tag_len

        while i <= max_iterations and not foundR1tag:
            # print("finding rev  R1tag")
            i += 1
            end_R1tag += tag_len
            start_R1tag += tag_len
            tagR1_sequence = read1[-end_R1tag:-start_R1tag]
            posReverseComp = reverse_complement.find(str(tagR1_sequence.seq))

            if posReverseComp > -1:
                foundR1tag = True
                results.append(posReverseComp)
                results.append(tagR1_sequence)
                results.append(end_R1tag)

    # if position of tagR2 is not found take next 10bp as tag and search again until found or end of read1 sequence is reached.
    if not foundR2tag and not pos2ReverseComp > -1:
        j = 1
        max_iterations = len(read2) % tag_len
        while j <= max_iterations and not foundR2tag:
            # print("finding rev  R2tag")
            j += 1
            end_R2tag += tag_len
            start_R2tag += tag_len
            tagR2_sequence = read2[-end_R2tag:-start_R2tag]
            pos2ReverseComp = ref_sequence.find(str(tagR2_sequence.seq))

            if pos2ReverseComp > -1:
                foundR2tag = True
                results.append(pos2ReverseComp)
                results.append(tagR2_sequence)
                results.append(end_R2tag)

    if not posReverseComp > -1 or not pos2ReverseComp > -1:

        results.append(posReverseComp)
        results.append(tagR1_sequence)
        results.append(end_R1tag)
        results.append(pos2ReverseComp)
        results.append(tagR2_sequence)
        results.append(end_R2tag)


    return results # an array with all the needed values is returned.



def main():

        print('Version %s\n' % (__version__))

        parser = argparse.ArgumentParser(description = 'fixNonOverlappingReads Parameters', formatter_class = argparse.ArgumentDefaultsHelpFormatter)
        parser.add_argument('-r1', '--fastq_r1', type = str, help = 'First fastq file', required = True, default = 'Fastq filename')
        parser.add_argument('-r2', '--fastq_r2', type = str, help = 'Second fastq file for paired end reads', required = True, default = '')
        parser.add_argument('-a', '--amplicon_seq', type = str, help = 'Amplicon Sequence', required = True)
        parser.add_argument('-t', '--tag_len', type = int, help = 'Tag (anchor) length', default = 10)
        args = parser.parse_args()

        #check files
        check_file(args.fastq_r1)
        if args.fastq_r2:
             check_file(args.fastq_r2)

        #amplicon sequence check
        #make evetything uppercase!
        args.amplicon_seq = args.amplicon_seq.strip().upper()
        revComp_amplicon = reverse_complement(args.amplicon_seq)
        wrong_nt = find_wrong_nt(args.amplicon_seq)
        if wrong_nt:
            raise NTException('The amplicon sequence contains wrong characters: %s' % ' '.join(wrong_nt))

        len_amplicon = len(args.amplicon_seq)

        print('AMPLICON LENGTH = ' + str(len_amplicon))

        #NUM_SEQS_TO_SCAN=10000 # used only for testing

        newR1File = os.path.basename(args.fastq_r1).replace(".fastq.gz", "__CP_PAD.fastq.gz")
        fpR1 = gzip.open(newR1File, "w")
        newR2File = os.path.basename(args.fastq_r2).replace(".fastq.gz", "__CP_PAD.fastq.gz")
        fpR2 = gzip.open(newR2File, "w")
        readsNotPaddedR1 = os.path.basename(args.fastq_r1).replace(".fastq.gz", "__CP_NotPadded.fastq.gz")
        notpaddedR1 = gzip.open(readsNotPaddedR1, "w")
        readsNotPaddedR2 = os.path.basename(args.fastq_r2).replace(".fastq.gz", "__CP_NotPadded.fastq.gz")
        notpaddedR2 = gzip.open(readsNotPaddedR2, "w")

        total_reads_processed = 0
        total_reads_padded = 0
        notFoundCount = 0
        pos = -1
        pos2 = -1
        posReverseStrand = -1
        pos2ReverseStrand = 1

        for i, rr in enumerate(zip(readFASTQ(args.fastq_r1), readFASTQ(args.fastq_r2))):
            r1,r2 = rr

            total_reads_processed += 2 #Count number of  all the reads that were processed

            tag_forward_reads = find_tag_on_reference(args.tag_len, r1, r2, args.amplicon_seq, revComp_amplicon)

            tagR1_forward = tag_forward_reads[1]
            tagR2_forward = tag_forward_reads[4]
            tagR1_forward_distance = tag_forward_reads[2]
            tagR2_forward_distance = tag_forward_reads[5]
            pos = tag_forward_reads[0]
            pos2 = tag_forward_reads[3]

            # search for read1 tag on reverse compliment only if the position on forward strand is not foune.
            # It is possible that the read1 is on reverse compliment of reference sequence.
            if not (pos >- 1) and not (pos2 > -1):

                tag_reverse_reads = find_tag_on_revCompliment(args.tag_len, r1, r2, args.amplicon_seq, revComp_amplicon)

                tagR1_rev = tag_reverse_reads[1]
                tagR2_rev = tag_reverse_reads[4]
                tagR1_rev_distance = tag_reverse_reads[2]
                tagR2_rev_distance = tag_reverse_reads[5]
                posReverseStrand = tag_reverse_reads[0]
                pos2ReverseStrand = tag_reverse_reads[3]

            #calculate the desired length of reads. CRISPResso software penalizes reads if the overlap is longer than certain basepairs.
            desired_read_length = int(math.floor(len(args.amplicon_seq)/2)) + 10
            padLen = desired_read_length - len(r1) #declare the padding length

            # if both tags are found then add then extend the reads and add extended reads to new fastq file.
            if (pos > -1) and (pos2 > -1):

                qVals = [x for x in tagR1_forward.letter_annotations["phred_quality"]]
                meanQ = int(numpy.mean(qVals))
                extendQ = chr(meanQ+33) * padLen
                origQ = "".join([chr(x + 33) for x in r1.letter_annotations["phred_quality"]])
                extendedRead1 = str(r1.seq) + args.amplicon_seq[(pos + tagR1_forward_distance):(pos + padLen + tagR1_forward_distance)]

                print >> fpR1, r1.description
                print >> fpR1, extendedRead1
                print >> fpR1, "+" 
                print >> fpR1, (origQ+extendQ)[:len(extendedRead1)] 

                qVals = [x for x in tagR2_forward.letter_annotations["phred_quality"]]
                meanQ = int(numpy.mean(qVals))
                extendQ = chr(meanQ+33) * padLen
                origQ = "".join([chr(x + 33) for x in r2.letter_annotations["phred_quality"]])
                extendedRead2 = str(r2.seq) + revComp_amplicon[(pos2 + tagR2_forward_distance):(pos2 + padLen + tagR2_forward_distance)]

                print >> fpR2, r2.description
                print >> fpR2, extendedRead2
                print >> fpR2, "+"
                print >> fpR2, (origQ+extendQ)[:len(extendedRead2)]

                total_reads_padded += 2  # count number of padded reads

            # if both tags are found then add then extend the reads and add extended reads to new fastq file.
            elif (posReverseStrand > -1) and (pos2ReverseStrand > -1):

                qVals = [x for x in tagR1_rev.letter_annotations["phred_quality"]]
                meanQ = int(numpy.mean(qVals))
                extendQ = chr(meanQ + 33) * padLen
                origQ = "".join([chr(x + 33) for x in r1.letter_annotations["phred_quality"]])
                extendedRead1 = str(r1.seq) + revComp_amplicon[(posReverseStrand + tagR1_rev_distance):(posReverseStrand + padLen + tagR1_rev_distance)]

                print >> fpR1, r1.description 
                print >> fpR1, extendedRead1 
                print >> fpR1, "+"
                print >> fpR1, (origQ+extendQ)[:len(extendedRead1)] 

                qVals = [x for x in tagR2_rev.letter_annotations["phred_quality"]]
                meanQ = int(numpy.mean(qVals))
                extendQ = chr(meanQ + 33) * padLen
                origQ = "".join([chr(x + 33) for x in r2.letter_annotations["phred_quality"]])
                extendedRead2 = str(r2.seq) + args.amplicon_seq[(pos2ReverseStrand + tagR2_rev_distance):(pos2ReverseStrand + padLen + tagR2_rev_distance)]

                print >> fpR2, r2.description
                print >> fpR2, extendedRead2
                print >> fpR2, "+"
                print >> fpR2, (origQ + extendQ)[:len(extendedRead2)] 
                total_reads_padded += 2 # count number of padded reads

            # if either of the tags are not found then add the reads to new fastq file that collects unpadded reads.
            else:
                print >> notpaddedR1, r1.description
                print >> notpaddedR1, r1.seq
                print >> notpaddedR1, "+"
                print >> notpaddedR1, "".join([chr(x+33) for x in r1.letter_annotations["phred_quality"]])

                print >> notpaddedR2, r2.description
                print >> notpaddedR2, r2.seq
                print >> notpaddedR2, "+" 
                print >> notpaddedR2, "".join([chr(x+33) for x in r2.letter_annotations["phred_quality"]]) 

                notFoundCount += 2 # count number of unpadded reads

        # print counts to the screen for testing purposes. But this statistics should be captured for testing purposes.
        print("Total reads processed, " + str(total_reads_processed))
        print("Total reads padded, " + str(total_reads_padded)) 
        print("Total reads eliminated in this process, " + str(notFoundCount))

        fpR1.close()
        fpR2.close()

if __name__=="__main__":
    main()

