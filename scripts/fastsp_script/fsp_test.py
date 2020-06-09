import os
import sys

"""
###remember sys.argv - can create variables using indexes with sys.argv!      
"""

seq_dir = "perturbed_alignments_Drosophila_AA/EMGT00050000000018.Drosophila.001_AA"
slash = "/"
fas = ".fasta"


outfile_name = "parsed_fs_output.csv"
header = "dataset,species,datatype,ref_num,est_num,sp,tc\n"
with open(outfile_name,"w") as outfile:
    outfile.write(header)
    # AUTOMATICALLY CLOSED when out of block. never need .close() with `with`
#outfile = open("parsed_fs_output.csv","w") ## mode "a" = append

infile_name = "output_fs.txt"
com = ","
space = " " 
n_alignments = 50


aa_ls_dir = [x for x in os.listdir(seq_dir) if x.endswith("fasta")]
## Long version of above:
#aa_ls_dir_raw = os.listdir(seq_dir)
#for aafile in aa_ls_dir_raw:
#    if aafile.endswith("fasta"):
#        aa_ls_dir.append(aafile)



for i in range(n_alignments):
    file1  = aa_ls_dir[i]
    fasta1 = seq_dir+slash+file1
    file1_split = file1.split("_")
    file1_dot = file1.split(".")
    dataset = file1_dot[0]
    #print(dataset)
    species = file1_dot[1]
    datatype = file1_split[1]
    dum_ref_num = file1_split[2]
    ref_num = dum_ref_num.split(".")[0]
    #print(ref_num)    
       
    for j in range (i,n_alignments):
        if i != j:
            file2 = aa_ls_dir[j] 
            fasta2 = seq_dir+slash+file2
            file2_split = file2.split("_")
            dum_est_num = file2_split[2]
            est_num = dum_est_num.split(".")[0]
            #print(est_num)

            ## REMINDER: COMMENT OUT PRINT LINE WHEN TOTALLY FINISHED
            #print("Running FastSP analysis on " + file1 + " and " + file2 + "\n")
            cmd = "java -jar FastSP.jar -r " + fasta1 + " -e " + fasta2 + " > " + infile_name
            cmd_exit_code = os.system(cmd)
            assert(cmd_exit_code == 0), "java fastsp failed to run"
          
            
            with open(infile_name, "r") as infile:
                ##HERE COMES THE STUFF
                ## IT'S AUTOCLOSED OUTSIDE THE WITH BLOCK
                if_lines = infile.readlines()
                
                #print(if_lines)        
            
                b_SP = if_lines[0]
                b_TC = if_lines[5]
            
            
                split_SP = b_SP.rsplit(space)
                r_SP = split_SP[1]
                nn_SP = r_SP.rstrip()
                split_TC = b_TC.rsplit(space)
                r_TC = split_TC[1]
                #print(r_TC) 
                nn_TC = r_TC.rstrip()               
            
                #write_line = file1 + com + file2 + com + file1_split[1]+ com +  nn_SP + com + nn_TC + "\n"
                # EMGT00050000000018.Drosophila.001_AA_13.fasta,EMGT00050000000018.Drosophila.001_AA_37.fasta,AA,0.9545768433975294,0.8126888217522659
                write_line = dataset + com + species + com + datatype + com + ref_num + com + est_num + com + nn_SP + com + nn_TC + "\n"
                # SHOULD PRINT THIS:
                ## dataset,species,datatype,ref_num,est_num,sp,tc\n    <- NEW HEADER
                ## EMGT00050000000018,Drosophila,AA,13,37,0.9545768433975294,0.8126888217522659
                #### EMGT00050000000018,Drosophila,AA,13  <- can all be gotten from file 1

            #print(write_line)
            #outfile.write(write_line)
            ## IN ONLY THE NEXT TWO LINES! we open in APPEND mode, write the line, and close the file automatically
            with open(outfile_name, "a") as outfile:
                outfile.write(write_line)
        