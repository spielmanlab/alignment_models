import dendropy ### Full documentation: https://dendropy.org/
import numpy as np
import os

path_to_alignments = "../selectome_nt_output/"

## One example, but you'll need to loop ..........
path2 = "ENSGT00390000000018.Euteleostomi.003.nt.fas_alnversions/"
file = "ENSGT00390000000018.Euteleostomi.003.nt.fas_alnversion_1.fasta"
output_tree_file = path_to_alignments + path2 + file + ".tree"
print(path_to_alignments + path2 + file)

### make a tree with FastTree
## args for aa:   blank 
## args for nt:   -nt -gtr
os.system("FastTree -nt -gtr -nosupport -quiet " + path_to_alignments + path2 + file + " > " + output_tree_file)


tree = dendropy.Tree.get(
    path=output_tree_file,
    schema="newick")
    
#### Sum of branch lengths is called tree length. It tells you the total amount of substitutions across the tree (how much evolution happened here?)
print(tree.length())

# https://dendropy.org/primer/phylogenetic_distances.html
pdc = tree.phylogenetic_distance_matrix()
print(pdc.mean_pairwise_distance()) #### average pairwise distance between sequences