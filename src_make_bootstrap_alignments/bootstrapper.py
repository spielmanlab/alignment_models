import shutil
import os
from Bio import AlignIO
from numpy import *

class BootstrapperLight(object): 
    def __init__(self, **kwargs):
        self.aligner      = kwargs.get("aligner")
        self.tree_builder = kwargs.get("tree_builder")
        
        self.n            = kwargs.get("bootstraps")
        self.prealn_file  = kwargs.get("prealn_file")
        self.refaln_file  = kwargs.get("refaln_file")
        self.final_treefile = "BStrees.tre"
        self.BootDir      = kwargs.get("BootDir", "BootDir/")
        
        self.numprocesses = kwargs.get("threads", 1)
        self.srcdir       = kwargs.get("srcdir", "src/")
        
        ############# input assertions ##########
        assert(self.aligner is not None), "No aligner was passed to Bootstrapper."
        assert(self.tree_builder is not None), "No tree builder was passed to Bootstrapper."
        assert(self.n is not None), "Number of bootstraps was not specified."
        assert(self.prealn_file is not None), "Raw sequence file was not specified."
        assert(self.refaln_file is not None), "Reference alignment file was not specified."
        #########################################

        # These will be defined in the fxn parseRefAln
        self.refaln_seq = []
        self.alnlen = None
        self.numseq = None


    def parseRefAln(self):
        # Parse reference alignment for internal use
        infile=open(self.refaln_file, 'r')
        parsed = AlignIO.read(infile, 'fasta')
        infile.close()
        for record in parsed:
            self.refaln_seq.append(str(record.seq))
        self.numseq = len(self.refaln_seq)
        self.alnlen = len(self.refaln_seq[0])    
        
        
    def bootstrap(self):
        ''' Create bootstrapped trees and then from those create perturbed alignments.'''
        
        self.parseRefAln()
        
        # Create the bootstrapped trees
        print ("Constructing bootstrap trees")
        #self.tree_builder.buildBootTrees(self.n, self.refaln_seq, self.numseq, self.alnlen, self.final_treefile)
        numSaveTrees = self.tree_builder.buildBootTreesNoReps(self.n, self.refaln_seq, self.numseq, self.alnlen, self.final_treefile)
        
        # We only need to process unique guide trees. This will be a massive time-saver when conducting alignments. 
        # The missing (n - new_n) will be accounted for in scorer.py . 
        new_n = len(numSaveTrees)
    
        # Separate into PROCESSED trees for given alignment software
        print ("Formatting trees")
        self.aligner.processTrees(new_n, self.final_treefile)     
        
        print ("Building bootstrap alignments")
        self.aligner.multiMakeAlignmentsGTOP(self.prealn_file, new_n, self.numprocesses)
        
        return numSaveTrees
            
        
        
    
