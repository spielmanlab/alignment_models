import os
import sys
import re 


aa_ranked_csv = "../aa_ranked_models.csv"
nt_ranked_csv = "../nt_ranked_models.csv"

aa_infile = open(aa_ranked_csv,"r")
nt_infile = open(nt_ranked_csv,"r")

outfile = open("most_common.csv","w")




for line in aa_infile:
    x= line.split(",")
    #print(x[2])
    model = x[2]
    print(model)
    if any(s in l for l in line for s in model):
        
    
   #  if model == model:
#         #print(type(model))
#         print(str.count(model))
#        # z = str.count(model,0,5)
#       #  print(z)



aa_infile.close()
nt_infile.close()
outfile.close()