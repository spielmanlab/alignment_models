#!/usr/bin/python3

from numpy import *
from dendropy import *

import os
import re
import subprocess
import sys
import shutil

source = "src_make_bootstrap_alignments/"
sys.path.append(source)

from aligner import *
from treebuilder import *
from bootstrapper import *

###################### User input (or derived from user input) ###########################
assert(len(sys.argv) == 5), "\n USAGE: python3 make_bootstrap_alignments.py <fastafile> <protein/dna> <num bootstraps> <threads>"


unaligned   = sys.argv[1]        # infile
alphabet    = sys.argv[2]        # This should be either "protein" or "dna"
n           =  int(sys.argv[3])  # bootstraps
numproc     =  int(sys.argv[4])  # threads
os.environ["OMP_NUM_THREADS"] = str(numproc)

prealn_file = 'prealn.fasta' # Will contain the raw (unaligned) sequences in fasta format
refaln_file = 'refaln.fasta' # Will contain the reference (unmasked!) alignment
prefix      = unaligned.split(".fasta")[0]
BootDir     =  prefix + "_bootaln/"
if (os.path.exists(BootDir)):
	bootfiles=os.listdir(BootDir)
	for file in bootfiles:
		os.remove(BootDir+file)	
else:
	os.mkdir(BootDir)
	assert(os.path.exists(BootDir))
os.chdir(BootDir)	
os.system("cp ../" + unaligned + " " + prealn_file)

############################### Internal variables #######################################

# Aligner
amod = MafftAligner("mafft", " --auto --quiet ")
tmod = builderFastTree("FastTreeMP", " -fastest -nosupport -quiet ") # -nosupport **MUST** be there
bmod = BootstrapperLight(bootstraps = n, prealn_file = prealn_file, refaln_file = refaln_file, BootDir = BootDir, 
                           threads = numproc, aligner=amod, tree_builder = tmod, srcdir = source)
                           
print("making base alignment")
amod.makeAlignment(prealn_file, refaln_file)

print("bp trees, aln")
bmod.bootstrap()	
	
for i in range(1, n+1):
    os.system("mv bootaln" + str(i) + ".fasta " + prefix + "_" + str(i) + ".fasta")
os.system("rm *txt *tre prealn.fasta refaln.BS")
os.system("mv refaln.fasta " + prefix + "_0.fasta")
os.chdir('../')  