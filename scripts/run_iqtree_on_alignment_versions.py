import os
import sys


name        = sys.argv[1]         # name
fasta_dir   = sys.argv[2]         # directory with all fasta files
start_fasta = int(sys.argv[3])    # first index
stop_fasta  = int(sys.argv[4])    # second index
datatype    = sys.argv[5].upper() # AA or NT
threads     = sys.argv[6]         # threadzzz

name_datatype = name + "_" + datatype + "_"

if datatype == "NT":
    iqdatatype = "DNA"
else:
    iqdatatype = datatype

csvfile   = fasta_dir + name_datatype + "bestmodels.csv"
outstring = "name,datatype,AIC,AICc,BIC\n"


for i in range(start_fasta, stop_fasta + 1):
    
    fastafile = fasta_dir + name_datatype + str(i) + ".fasta"
    logfile   = fasta_dir + name_datatype + str(i) + ".fasta.log"

    print("Running model selection on", fastafile) 
   
    ### Run through iqtree
    cmd = "iqtree -s " + fastafile + " -m TESTONLY -st " + iqdatatype + " -redo -quiet -nt " + str(threads)
    iqtree_success = os.system(cmd)
    assert iqtree_success == 0, "\nERROR: iqtree did not run properly"

    AIC = None
    AICc = None
    BIC = None
    with open(logfile, "r") as f:
        for line in f:
            if line.startswith("Akaike Information Criterion:"):
                AIC = line.strip().split(":")[1].strip()
            if line.startswith("Corrected Akaike Information Criterion:"):
                AICc = line.strip().split(":")[1].strip()
            if line.startswith("Bayesian Information Criterion:"):
                BIC = line.strip().split(":")[1].strip()

    assert(AIC is not None), "failed to retrieve AIC"
    assert(AICc is not None), "failed to retrieve AICc"
    assert(BIC is not None), "failed to retrieve BIC"
    
    outstring += ",".join([name,datatype,AIC,AICc,BIC]) + "\n"
    
    os.system("rm " + fastafile + ".*") 

with open(csvfile, "w") as f:   
    f.write(outstring.strip())