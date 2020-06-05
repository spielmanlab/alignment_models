import os
import sys

"""
###remember sys.argv - can create variables using indexes with sys.argv!      
"""

dir = "perturbed_alignments_Drosophila_AA/EMGT00050000000018.Drosophila.001_AA"
slash = "/"
fas = ".fasta"

infile = open("output_fs.txt", "w+")
infile_name = "output_fs.txt"
outfile = open("parsed_fs_output.csv","w")
header = "reference,estimation,datatype,sp_score,tc"+ "\n"
com = ","
outfile.write(header)
space = " "

aa_ls_dir = os.listdir(dir)
                                
for i in range(50):
    for j in range (i,50):
        if i != j:
        
            file = aa_ls_dir[i]
            file2 = aa_ls_dir[j] 
            
            fasta1 = dir+slash+file
            fasta2 = dir+slash+file2
            #print(fasta1,fasta2)
            
            if file.endswith(fas):
                if file2.endswith(fas):
                    #print(file,file2)
                    print("Running FastSP analysis on " + file + " and " + file2 + "\n")
                    cmd = "java -jar FastSP.jar -r " + fasta1 + " -e " + fasta2
                    #print(cmd)
            
                    fincmd = cmd + " > " + infile_name
                    #print(fincmd)  
                    os.system(fincmd)
                    
                    ########### code below only works if its only one loop 
                    
                    if_lines = infile.readlines()
                    file_split = file.split("_")   
                    print(if_lines)        
                    
                    b_SP = if_lines[0]
                    b_TC = if_lines[5]
                    
                    
                    split_SP = b_SP.rsplit(space)
                    r_SP = split_SP[1]
                    nn_SP = r_SP.rstrip()
                    split_TC = b_TC.rsplit(space)
                    r_TC = split_TC[1]
                    print(r_TC) 
                    nn_TC = r_TC.rstrip()                   
                    
                    write_line = file + com + file2 + com + file_split[1]+ com +  nn_SP + com + nn_TC + "\n"
                    #print(write_line)
                    outfile.write(write_line)
                    
                    assert(1==0)
                
                   
                    
                            
            
            
            
infile.close()
outfile.close()
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            

                    
                    
                    
 