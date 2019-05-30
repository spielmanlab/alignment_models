#python script for iq_sub

import re


iqf = open ("iqtree_sub.txt", "r")
for line in iqf:
	print (line)

#can't trust line numbers, can trust format and patterns 

s1 = "  1  Dayhoff       34598.308    63  69322.616    69333.353    69618.917"
#s1.strip() 
#print(s1)

#know what immutable means

list1 = s1.split()
print (list1)

# doesn't work: [
#for item in list1:
	# print (i, end= " ") 	
	#]

#this prints the string without commas, must ammend this list!!!
	
print (",".join(list1))

#join is opposite of split
#this string is practice but produce script
#testing out small pieces of code: copy and paste is great, but go to terminal then dir and then type "python 3 script_name"

#start using regular expressions
#notes for molly when she comes back to this: regular expression operators

#pseudocode:
#1. remove spaces
#2. turn into string into list into a string













