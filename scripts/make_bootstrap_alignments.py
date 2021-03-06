#!/usr/bin/python3

from numpy import *
from dendropy import *

import os
import re
import subprocess
import sys
import shutil
import filecmp

source = "src_make_bootstrap_alignments/"
sys.path.append(source)
sys.path.append("scripts/" + source) # depends on path where called from

from aligner import *
from treebuilder import *
from bootstrapper import *

###################### User input (or derived from user input) ###########################
assert(len(sys.argv) == 8), "\n USAGE: python3 make_bootstrap_alignments.py <fastafile> <outname> <output directory> <AA/NT> <num bootstraps> <threads> <badfile...>"


unaligned   = sys.argv[1]        # infile
outname     = sys.argv[2]        # alignment output name 
outpath     = sys.argv[3]        # outpath
alphabet    = sys.argv[4].upper()  # This should be either "AA" or "NT"
n           =  int(sys.argv[5])  # bootstraps
numproc     =  int(sys.argv[6])  # threads
badfile     = sys.argv[7]        # indicator file if duplicate alignments are created
os.environ["OMP_NUM_THREADS"] = str(numproc)

prealn_file = 'prealn.fasta' # Will contain the raw (unaligned) sequences in fasta format
refaln_file = 'refaln.fasta' # Will contain the reference (unmasked!) alignment
prefix      = unaligned.split(".fasta")[0]

#BootDir     =  prefix + "_alnversions/"
if (os.path.exists(outpath)):
	for file in os.listdir(outpath):
		os.remove(outpath+file)	
else:
	os.mkdir(outpath)
	assert(os.path.exists(outpath))
os.chdir(outpath)	
os.system("cp ../" + unaligned + " " + prealn_file)

############################### Internal variables #######################################

# Aligner
amod = MafftAligner("mafft", " --auto --quiet --preservecase ")
if alphabet == "NT":
    addarg = " -nt "
else:
    addarg = " "
tmod = builderFastTree("FastTreeMP", addarg + "-fastest -nosupport -quiet -nopr") # -nosupport **MUST** be there
bmod = BootstrapperLight(bootstraps = n, prealn_file = prealn_file, refaln_file = refaln_file, BootDir = outpath, 
                           threads = numproc, aligner=amod, tree_builder = tmod, srcdir = source)
                           
#print("making base alignment")
amod.makeAlignment(prealn_file, refaln_file)

#print("bp trees, aln")
bmod.bootstrap()	

######### Rename alignments  ########
for i in range(1, n+1):
    os.system("mv alnversion" + str(i) + ".fasta " + outname + "_" + str(i) + ".fasta")
os.system("mv refaln.fasta " + outname + "_" + str(n+1) + ".fasta")

############# Check whether alignments are all unique ##############
duplicate_alignments = False
for i in range(1, n+1):
    filei = outname + "_" + str(i) + ".fasta"
    for j in range(1, n+1):
        filej = outname + "_" + str(j) + ".fasta"
        
        #print(filei, filej)
        # don't compare the same file
        if filei == filej:
            continue
            
        files_are_equal = filecmp.cmp(filei, filej)  ## True if equal, False if unequal. We want these to be UNEQUAL.
        if files_are_equal:
            outstring = "EQUAL ALIGNMENT FILES: " + str(i) + " " + str(j)
            os.system("echo " + outstring + " > " + badfile)
            duplicate_alignments = True
            break
    if duplicate_alignments:
        break
        
os.system("rm *txt *tre prealn.fasta refaln.BS")
