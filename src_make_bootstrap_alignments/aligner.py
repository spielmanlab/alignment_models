import subprocess, os, multiprocessing
from dendropy import *
import re
from Bio import AlignIO
    
class Aligner:
    def __init__(self):
        return

    def makeAlignment( self, prealn_file, alnfile ):
        '''Makes an alignment, nothing fancy.'''

    def makeAlignmentGT( self, treefile, prealn_file, alnfile):
        '''Makes an alignment using a provided guide tree.'''

    def multiMakeAlignmentsGT(self, prealn_file, n, numprocesses):
        '''Makes n bootstrap alignments. Note that this function is rather clunky because multiprocessing.pool() does not work when inside a class in python. The code here is a decent workaround of this unfortunate issue.'''

        pool=multiprocessing.Pool(numprocesses)
        jobs=[]

        if numprocesses>=n:
            for i in range(n):
                treefile='tree'+str(i+1)+'.txt'
                alnfile='bootaln'+str(i+1)+'.fasta'
                p=multiprocessing.Process(target=self.makeAlignmentGT, args=( treefile, prealn_file, alnfile ))
                jobs.append(p)
                p.start()
            for p in jobs:
                p.join()

        elif numprocesses<n:
            nruns=0
            while (nruns < n):
                if (n-nruns)>=numprocesses:
                    jobs=[]
                    for i in range(nruns, nruns+numprocesses):
                        treefile='tree'+str(i+1)+'.txt'
                        alnfile='bootaln'+str(i+1)+'.fasta'
                        p=multiprocessing.Process(target=self.makeAlignmentGT, args=( treefile, prealn_file, alnfile ))
                        jobs.append(p)
                        p.start()
                    for p in jobs:
                        p.join()
                    nruns+=numprocesses ## now increment
                elif (n-nruns)<numprocesses:
                    jobs=[]
                    for i in range(n-nruns, n):
                        treefile='tree'+str(i+1)+'.txt'
                        alnfile='bootaln'+str(i+1)+'.fasta'
                        p=multiprocessing.Process(target=self.makeAlignmentGT, args=( treefile, prealn_file, alnfile ))
                        jobs.append(p)
                        p.start()
                    for p in jobs:
                        p.join()
                    break
        pool.terminate()

        return 0


class MafftAligner(Aligner):
    def __init__(self, executable, options):
        ''' "executable" is the path to the MAFFT and its options are given by "options" '''
        self.executable = executable
        self.options = options

    def makeAlignment( self, prealn_file, alnfile):
        align=self.executable+' '+self.options+' '+prealn_file+' > '+alnfile
        runalign=subprocess.call(str(align),shell=True)

        return 0

    def makeAlignmentGT( self, treefile, prealn_file, alnfile):
        align=self.executable+' '+self.options+' --treein '+treefile+' '+prealn_file+' > '+alnfile ## Note that we do not use "--retree 1." Providing an input tree will still capture alignment stochasticity without forcing a poorer alignment, as retree 1 has the potential to do.
        print(align)
        runalign=subprocess.call(str(align), shell=True)
        return 0

    def processTrees(self, n, infile):
        ''' Takes the bootstrapped trees out from a single file and process each into MAFFT format.'''
        #trees=TreeList()
        #trees.read(infile, 'newick', as_rooted=True)
        trees = TreeList.get(
            path=infile,
            schema="newick",
            rooting='force-rooted'
        )
#        trees = dendropy.TreeList()
#trees.read(path="sometrees.nex", schema="nexus", tree_offset=10)
        for i in range(n):
            rawtree = trees[i]
            # Remove any polytomies and update splits since it was forced in as rooted 3 lines above
            rawtree.resolve_polytomies()
            rawtree.update_bipartitions()
            rawtree2=str(rawtree).replace('[&R] ','')
            outtree = "tree"+str(i+1)+".txt"
            self.Tree2Mafft(rawtree2, outtree)            
        return 0


    #################################################################################
    ### The following two functions are simply the newick2mafft.rb script re-written in python. Note that the MAFFT authors have been notified of this modified code and intend to distribute it.

    def killMegatomy(self, tree):
        ''' First part of the newick2mafft.rb script.'''
        findMegatomy = re.search(",(\d+):(\d+\.\d*),(\d+):(\d+\.\d*)", tree)
        while findMegatomy:
            hit1 = findMegatomy.group(1)
            hit2 = findMegatomy.group(2)
            hit3 = findMegatomy.group(3)
            hit4 = findMegatomy.group(4)
            wholeMega = ","+hit1+":"+hit2+","+hit3+":"+hit4
            tree = tree.replace(wholeMega, ",XXX")
            poshit = tree.index("XXX")
            i=poshit
            height=0
            while i >= 0:
                if height == 0 and tree[i]=='(':
                    break
                if tree[i]==')':
                    height+=1
                elif tree[i] == '(':
                    height-=1
                i-=1
            poskakko=i
            zenhan=tree[0:poskakko+1]
            treelen = len(tree)
            tree = zenhan + "(" + tree[(poskakko+1):treelen]
            tree=tree.replace('XXX', hit1+":"+hit2+"):0,"+hit3+":"+hit4)
            findMegatomy = re.search(",(\d+):(\d+\.\d*),(\d+):(\d+\.\d*)", tree)    
        return tree


    def Tree2Mafft(self, tree, outfile):    
        ''' Second part of the newick2mafft.rb script. Converts a newick tree into MAFFT's native format.'''
        outhandle=open(outfile, 'w')

        # Replace forbidden characters. 
        tree = re.sub(" ", "", tree)
        tree = re.sub("\d\.*\d*e-\d+", "0", tree)
        tree = re.sub("\[.*?\]", "", tree)
        tree = re.sub("[_*?:]", ":", tree)

        memi=[-1,-1]
        leni=[-1,-1]
        findparen = re.search('\(', tree)
        while findparen:
            tree=self.killMegatomy(tree)
            find = re.search("\((\d+):(\d+\.*\d*),(\d+):(\d+\.*\d*)\)", tree)
            if find:
                memi[0] = find.group(1)
                leni[0] = find.group(2)
                memi[1] = find.group(3)
                leni[1] = find.group(4)
                wholeclade = "("+memi[0]+":"+leni[0]+","+memi[1]+":"+leni[1]+")"
                tree = tree.replace(wholeclade, "XXX")
                if int(memi[1]) < int(memi[0]):
                    memi.reverse()
                    leni.reverse()
                tree=tree.replace("XXX", memi[0])    
                outhandle.write(memi[0]+' '+memi[1]+' '+leni[0]+' '+leni[1]+'\n')
            findparen = re.search('\(', tree)
        outhandle.close()
        return 0
    ##############################################################################################

