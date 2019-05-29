#python script for iq_sub

import re


iqf = open ("iqtree_sub.txt", "r")
print (iqf)

#can't trust line numbers, can trust format and patterns 

s1 = "  1  Dayhoff       34598.308    63  69322.616    69333.353    69618.917"
s1.strip()
list1 = s1.split()
print (list1)

# doesn't work: [
#for item in list1:
	# print (i, end= " ") 	
	#]

#this prints the string without commas, must ammend this list!!!
	
print (",".join(list1))


#start using regular expressions
#notes for molly when she comes back to this: regular expression operators

#pseudocode:
#1. remove spaces
#2. turn into string into list into a string













