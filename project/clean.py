import os

toppath = "selectome_001_output/"

dirs = [x for x in os.listdir(toppath)]

for dir in dirs:
    name = dir.split(".")[0]
    aa = name + ".Euteleostomi.001.aa.fas_alnversions_selectedmodels"   
    nt = name + ".Euteleostomi.001.nt.fas_alnversions_selectedmodels"
    
    aa_exists = aa in dirs
    nt_exists = nt in dirs
    #print(aa, aa_exists)
    #print(nt, nt_exists)
    if aa_exists and nt_exists:
        continue
    else:
        try:
            os.system("rm -r  " + toppath + aa)
        except:
            pass
        try:
            os.system("rm -r  " + toppath + nt)
        except:
            pass
