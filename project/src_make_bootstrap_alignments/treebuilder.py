import subprocess
import shutil
import os
from dendropy import *
from dendropy.calculate import treecompare
from Bio import AlignIO
#from dendropy import TaxonSet, Tree, TreeList
from random import randint


class TreeBuilder:
    def __init__(self):
        '''initialization function'''
        return


class builderFastTree(TreeBuilder):
    def __init__(self, executable, options):
        '''"executable" is the path to the FastTree executable, and "options" are options to be handed to executable'''
        self.executable = executable
        self.options = options
    
    def makeBootAlignment(self, refaln_seq, numseq, alnlen, outfile):
        '''into a SINGLE FILE: makes n bootstrap alignment replicates from a given reference alignment sequence (refaln_seq). Doesn't involve alignment software at all.'''
        outhandle=open(outfile + "_raw", 'w')
        outhandle.write(' '+str(numseq)+' '+str(alnlen)+'\n')
        indices = []
        for a in range(alnlen):
            indices.append(randint(0,alnlen-1))    
        for s in range(numseq):
            newseq=''
            id=s+1
            for a in indices:
                newseq=newseq+refaln_seq[s][a]
            outhandle.write(str(id)+'        '+newseq+'\n')
        outhandle.close()
        AlignIO.convert(outfile + "_raw", "phylip-relaxed", outfile, "fasta")
        os.remove(outfile + "_raw")

    def buildBootTree( self, refaln_seq, numseq, alnlen, outfile):
        bootseq = 'refaln.BS'
        self.makeBootAlignment(refaln_seq, numseq, alnlen, bootseq)
        BuildTree=self.executable+' '+self.options+' -nosupport '+bootseq+' > '+outfile
        print(BuildTree)
        os.system(BuildTree)
        # Double-check that FastTree worked. (It has been throwing some floating point exceptions.) If not, make a new bootstrap alignment and try again.
        #numReps = 0
        #while os.path.getsize(outfile) <= 0:
        #    self.makeBootAlignment(refaln_seq, numseq, alnlen, bootseq)
        #    runtree=subprocess.call(str(BuildTree), shell='True')    
        #    assert(numReps<10), "Serious FastTree problem."
        #    numReps+=1


    def buildBootTreesNoReps(self, num, refaln_seq, numseq, alnlen, outfile):
        ''' Construct bootstrap trees, but if found a repeat just remember which ones are repeats and save that many alns from it later '''
        
        
        tnamespace = TaxonNamespace()
        saveTrees = []
        numSaveTrees = []
        
        ## Final file
        finalTrees = open(outfile, 'w')
    
        self.buildBootTree(refaln_seq, numseq, alnlen, 'temp.tre')
        
        # Save tree
        tree = Tree.get(path='temp.tre', schema = 'newick', taxon_namespace = tnamespace)
        finalTrees.write(str(tree)+';\n')
        saveTrees.append(tree)
        numSaveTrees.append(1)
        
        for i in range(1,num):
            self.buildBootTree(refaln_seq, numseq, alnlen, 'temp.tre')
            
            # Compare it to all current trees to see if we already have it
            testTree = Tree.get(path='temp.tre', schema = 'newick', taxon_namespace = tnamespace)
            newTree = True
            for x in range(len(saveTrees)):
                dist = treecompare.symmetric_difference(saveTrees[x], testTree)
            
                # Have the tree already. Increment 1 to that tree's index
                if ( abs(dist - 1.) < 1e-10 ):
                    numSaveTrees[x]+=1
                    newTree = False
                    break
            
            # Need to save the tree
            if newTree:
                numSaveTrees.append(1)
                saveTrees.append(testTree)
                finalTrees.write(str(testTree)+';\n')
        
        finalTrees.close()
        
        # Double check that the correct number of trees (num bootstraps requested) have been accounted for
        sum = 0
        for i in numSaveTrees:
            sum += i
        assert (sum == num), "The correct number of trees have not been built. This is a problem. Email stephanie.spielman@gmail.com "
        
        return numSaveTrees
        
        
