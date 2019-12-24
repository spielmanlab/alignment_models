import os
import sys
import re 
import statistics


""""

goals: get most common model percentage (example: if 40 are one model and 20 are another, the most common model percentage
would be 66% 
need the most common model percentage for each name

ok so in the csv i'm working with, there are 50 of the same names, but under each name there might be a different model
so one, sort model by name


so need to import statistics, need to find max number of models per name, then divide it by 50


can also do R - repae


how many models are there - sets in python, append things 
set() - add new things to set with .add, and then count (are you this one - dictionary )

if the key is noit in the dictionary, put it in, then count it in 


"""

aa_ranked_csv = "../aa_ranked_models.csv"
nt_ranked_csv = "../nt_ranked_models.csv"

aa_infile = open(aa_ranked_csv,"r")
nt_infile = open(nt_ranked_csv,"r")
outfile = open("most_common.csv","w")
header = "name,most_common_model_percentage"


for line in aa_infile:
    #print(line)
    splitlists = line.split(",")
    #print(splitlists)
    
    #print(splitlists)
    splitlists.remove(splitlists[1])
    name = splitlists[0]
    model = splitlists[1]
    
    it= iter(splitlists)
    print(dict(zip(it,it)))
    
    
    
    
    
    # for name,model in zip(splitlists):
#         print(f"name:{name}")
#     
    
    
   
    




# for line in aa_infile:
#     #print(line)
#     linelist = line.split(",")
#     linelist.remove(linelist[1])
#     name=linelist[0]
#     model = linelist[1]
#     ic_type=linelist[2]
#     z= name.strip(".aa.fas")
#     a = z.rsplit(".")
#     #print(a)
#     for item in a:
#         lan = item[15:19]
#         #print(lan)
#         if lan == lan:
#             print(lan)
            
    
    
    #print(model)
  
















# 
# for line in aa_infile:
#     #print(line)
#     strlists= line.split(",")
#     strlists.remove(strlists[0])
#     strlists.remove(strlists[0])
#     strlists.remove(strlists[1])
#     model = strlists[0]
#     #print(strlists)
#     
#     for item in strlists:
#         #print(item)
#         z = item.startswith(item[0])
#         if z == z:
#             print(item)
    #print(strlists)
    #model = strlist[2]
    
   #  for line in strlists:
#         print(line) 
#     
    
   #  print(model)
#     print(strlist.count(model))
    
#     
#     
#     unique = set(strlist)
#     print(unique)
#     
    
    
    
    #print(model)
   #  unique = set(strlist) 
#     for item in unique:
#         print(type(item))
        #print(strlist.count(item))    
    
   #  if model == model:
#         #print(type(model))
#         print(str.count(model))
#        # z = str.count(model,0,5)
#       #  print(z)



aa_infile.close()
nt_infile.close()
outfile.close()