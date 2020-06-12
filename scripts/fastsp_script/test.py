import os
import sys
import tempfile



   # we want perturbed_alignments_Drosophila_AA = overall_path that gets passed in as argv
    # then, list all the directories in there with os.listdir()
    ## AND get species, datatype variables HERE

   

    

    # should produce output CSV named like: <species>_<datatype>_alignment_scores.csv, e.g. Drosophila_AA_alignment_scores.csv



BAR = "_"
sl = "/"

overall_path = sys.argv[1] # eg, perturbed_alignments_Drosophila_AA

split_path = overall_path.split(BAR)
species = split_path[2]
#print(species)
datatype = split_path[3]
#print(datatype)

outfile_csv = species + BAR + datatype + BAR + "alignment_scores.csv"
#print(outfile_csv)


aln_dir = [x for x in os.listdir(overall_path) if os.path.isdir(os.path.join(overall_path,x))]
###HAVE TO USE OS.PATH.JOIN TO RECOGNIZE PATH 
print(aln_dir)

counter = 0 
for dir in aln_dir:
    file_path = os.path.join(overall_path,aln_dir[counter])
    counter +=1
    #print(file_path)
    fas_files = [x for x in os.listdir(file_path) if x.endswith(".fasta")]
    #print(fas_files)
    for i in range(50):
        file1 = fas_files[i]
        for j in range(50):
            file2 = fas_files[j]
            fasta2 = file_path+"/"+file2
            print(fasta2)
           # temp_infile = tempfile.NamedTemporaryFile()
           # 
           # cmd = "echo hello > " +  temp_infile.name
           # os.system(cmd)
           # #print(cmd)
           # 
           # with open(temp_infile.name, "r") as f:
           #     line3 = f.readlines()
           #     
           # word = line3[0]
           # x = word.split("l")
           # print(x)

    




    


            