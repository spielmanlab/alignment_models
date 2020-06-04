import os
import sys

"""
###remember sys.argv - can create variables using indexes with sys.argv!  
    
"""

dir = "perturbed_alignments_Drosophila_AA/EMGT00050000000018.Drosophila.001_AA"
slash = "/"

#print(sys.argv)

aa_ls_dir = os.listdir(dir)

for file in aa_ls_dir:
    if file.endswith(".fasta"):
        #print (file)
        for file2 in aa_ls_dir:
            if file2.endswith(".fasta"):
                if file != file2:
                    print(file,file2)
                    #print(dir+slash+file + dir+slash+file2)
                    
                    fasta1 = dir+slash+file
                    fasta2 = dir+slash+file2
                    
                    print("Running FastSP analysis on " + file + " and " + file2 + "\n")
                    cmd = "java -jar FastSP.jar -r " + fasta1 + " -e " + fasta2
                    print(cmd)
                    
                    #os.system(cmd)
                    
                    
                    
                    
                    
 