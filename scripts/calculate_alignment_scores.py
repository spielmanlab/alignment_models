import os
import sys
import tempfile

COM   = "," # uppercase is a visual indicator these are global constants
SPACE = " " 
SLASH = "/"
FAS   = ".fasta"
BAR   = "_"


def parse_fastsp(if_lines, dataset, species, datatype, ref_num, est_num):
    b_SP = if_lines[0]
    b_TC = if_lines[5]
    
    split_SP = b_SP.rsplit(SPACE)
    r_SP = split_SP[1]
    nn_SP = r_SP.rstrip()
    split_TC = b_TC.rsplit(SPACE)
    r_TC = split_TC[1]
    #print(r_TC) 
    nn_TC = r_TC.rstrip()               
    
    #write_line = file1 + COM + file2 + COM + file1_split[1]+ COM +  nn_SP + COM + nn_TC + "\n"
    # EMGT00050000000018.Drosophila.001_AA_13.fasta,EMGT00050000000018.Drosophila.001_AA_37.fasta,AA,0.9545768433975294,0.8126888217522659
    write_line = dataset + COM + species + COM + datatype + COM + ref_num + COM + est_num + COM + nn_SP + COM + nn_TC + "\n"

    return write_line
    
    
def main():

    overall_path = sys.argv[1] # eg, perturbed_alignments_Drosophila_AA
    split_path = overall_path.split(BAR)
    species = split_path[2]
    datatype = split_path[3]
    
    outfile_name = species + BAR + datatype + BAR + "alignment_scores.csv"
    # should produce output CSV named like: <species>_<datatype>_alignment_scores.csv, e.g. Drosophila_AA_alignment_scores.csv
    
    header = "dataset,species,datatype,ref_num,est_num,sp,tc\n"
    with open(outfile_name,"w") as outfile:
        outfile.write(header)
        # AUTOMATICALLY CLOSED when out of block. never need .close() with `with`
    #outfile = open("parsed_fs_output.csv","w") ## mode "a" = append

    n_alignments = 50

    aln_dir = [x for x in os.listdir(overall_path) if os.path.isdir(os.path.join(overall_path,x))]
    
    counter = 0
    for dir in aln_dir:
        file_path = os.path.join(overall_path,aln_dir[counter])
        counter +=1
        fas_files = [x for x in os.listdir(file_path) if x.endswith(FAS)]  
           
        for i in range(n_alignments):
            file1  = fas_files[i]
            fasta1 = file_path+SLASH+file1
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
                    file2 = fas_files[j] 
                    fasta2 = file_path+SLASH+file2
                    file2_split = file2.split("_")
                    dum_est_num = file2_split[2]
                    est_num = dum_est_num.split(".")[0]
                    #print(est_num)
                    
                    version_infile = tempfile.NamedTemporaryFile()
                    
    
                    ## REMINDER: COMMENT OUT PRINT LINE WHEN TOTALLY FINISHED
                    #print("Running FastSP analysis on " + file1 + " and " + file2 + "\n")
                    cmd = "java -jar FastSP.jar -r " + fasta1 + " -e " + fasta2 + " > " + version_infile.name
                    cmd_exit_code = os.system(cmd)
                    assert(cmd_exit_code == 0), "java fastsp failed to run"
              
                
                    with open(version_infile.name, "r") as infile:
                        ##HERE COMES THE STUFF
                        ## IT'S AUTOCLOSED OUTSIDE THE WITH BLOCK
                        if_lines = infile.readlines()
                    ## call a function here after file is closed
                    write_line = parse_fastsp(if_lines, dataset, species, datatype, ref_num, est_num)
                    
                    #print(write_line)
    
                    ## IN ONLY THE NEXT TWO LINES! we open in APPEND mode, write the line, and close the file automatically
                    with open(outfile_name, "a") as outfile:
                        outfile.write(write_line)
                        
    os.system("mv " + outfile_name + " ../results")  
  
                      
main()
        