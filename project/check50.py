import os

toppath = "selectome_001_output/"

dirs = list(set([x.split(".")[0] for x in os.listdir(toppath)]))
#print( len(dirs) )
for dir in dirs:
    #print(dir)
    name = dir.split(".")[0]
    aa = name + ".Euteleostomi.001.aa.fas_alnversions_selectedmodels/"   
    nt = name + ".Euteleostomi.001.nt.fas_alnversions_selectedmodels/"
    
    assert(os.path.exists(toppath + aa)), "no aa path"
    aa_csvfiles = [x for x in os.listdir(toppath + aa) if x.endswith("csv")]
    aa_fasfiles = [x for x in os.listdir(toppath + aa) if x.endswith("fasta")]
    assert(len(aa_csvfiles) == 50 and len(aa_fasfiles) == 50), "BAD" + name 
    csvsizes = [os.path.getsize(toppath + aa+x) for x in aa_csvfiles]
    fassizes = [os.path.getsize(toppath + aa+x) for x in aa_fasfiles]
    assert( 0 not in csvsizes), "empty csv"
    assert( 0 not in fassizes), "empty fas"


    assert(os.path.exists(toppath + nt)), "no nt path"
    nt_csvfiles = [x for x in os.listdir(toppath + nt) if x.endswith("csv")]
    nt_fasfiles = [x for x in os.listdir(toppath + nt) if x.endswith("fasta")]
    assert(len(nt_csvfiles) == 50 and len(nt_fasfiles) == 50), "BAD" + name
    csvsizes = [os.path.getsize(toppath + nt+x) for x in nt_csvfiles]
    fassizes = [os.path.getsize(toppath + nt+x) for x in nt_fasfiles]
    assert( 0 not in csvsizes), "empty csv"
    assert( 0 not in fassizes), "empty fas"
