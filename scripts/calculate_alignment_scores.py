"""
Written by MM (with gugene_idance and mentorship from SJS) to calculate and parse TC and SP scores.
Originally written by MM to do *all* alignments at once. 
Modified by SJS (preserving MM code*****) to have one CSV per gene_id which can subsequently be merged.
"""

import os
import sys
import tempfile

COM   = "," # uppercase is a visual indicator these are global constants
SPACE = " " 
SLASH = "/"
FAS   = ".fasta"
BAR   = "_"


def parse_fastsp(if_lines, gene_id, dataset, datatype, ref_num, est_num):
    """ written by MM """
    

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
    write_line = gene_id + COM + dataset + COM + datatype + COM + ref_num + COM + est_num + COM + nn_SP + COM + nn_TC

    return write_line
    
    
def main():


    path_to_alignments = sys.argv[1] 
    dataset            = sys.argv[2]
    datatype           = sys.argv[3]
    
    n_alignments = 50
    reference_number = 50
    ref_num = str(reference_number)
    
    output_path = "../results/alignment_scores/"
    all_aln_dir = [x for x in os.listdir(path_to_alignments) if os.path.isdir(os.path.join(path_to_alignments,x))]
    
    for aln_dir in all_aln_dir:
        aln_file_path = os.path.join(path_to_alignments,aln_dir) + "/"
        outfile_name =  aln_dir.replace("." + dataset + ".001","") + "_alignment_scores.csv"
        gene_id = aln_dir.replace("." + dataset + ".001","").replace("_"+datatype, "")
        
        if os.path.exists(output_path + outfile_name) and os.path.getsize(output_path + outfile_name) > 0:
            continue 
        #print(aln_dir)
        #print(outfile_name)
        #print(aln_file_path)

        # DO NOT WRITE THE HEADER SINCE WE ARE GOING TO CAT THE FILES TOGETGER!!!!
        #header = "gene_id,dataset,datatype,ref_num,est_num,sp,tc\n"
        #with open(outfile_name,"w") as outfile:
        #    outfile.write(header)
            # AUTOMATICALLY CLOSED when out of block. never need .close() with `with`
            #outfile = open("parsed_fs_output.csv","w") ## mode "a" = append
  
        output_lines = ""
        # EMGT00050000002067_AA_alignment_scores.csv
        # PF02900_AA_alignment_scores.csv
        
        
        # EMGT00050000002067.Drosophila.001_AA_9.fasta
        # PF02900_AA_18.fasta 
        if dataset != "PANDIT":
            ref_fasta = aln_file_path + gene_id + "." + dataset + ".001_" + datatype + "_" + ref_num + ".fasta"
        else:
            ref_fasta = aln_file_path + gene_id + "_" + datatype + "_" + ref_num + ".fasta"
          
        for i in range(1, n_alignments):
            if i == reference_number:
                continue
                
            est_num = str(i)
            if dataset != "PANDIT":
                est_fasta = aln_file_path + gene_id + "." + dataset + ".001_" + datatype + "_" + est_num + ".fasta"
            else:
                est_fasta = aln_file_path + gene_id + "_" + datatype + "_" + est_num + ".fasta"
            
            version_infile = tempfile.NamedTemporaryFile()
            cmd = "java -jar FastSP.jar -r " + ref_fasta + " -e " + est_fasta + " > " + version_infile.name
            cmd_exit_code = os.system(cmd)
            assert(cmd_exit_code == 0), "java fastsp failed to run"
            
            
            with open(version_infile.name, "r") as infile:
                ##HERE COMES THE STUFF
                ## IT'S AUTOCLOSED OUTSIDE THE WITH BLOCK
                if_lines = infile.readlines()
            ## call a function here after file is closed
            output_lines += parse_fastsp(if_lines, gene_id, dataset, datatype, ref_num, est_num) + "\n"
        
        assert(output_lines.count("\n") == n_alignments -1), "NOT ENOUGH SCORES!" 
        with open(outfile_name, "w") as outfile:
            outfile.write(output_lines)
                
        os.system("mv " + outfile_name + " " + output_path)    
                      
main()
        