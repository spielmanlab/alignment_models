#python script for iq_sub

import re
counter = 1


with open ("iqtree_sub.txt", "r") as iqf:
	f_content = iqf.read()
	iqf.close()
	print (f_content)


#can't trust line numbers, can trust format and patterns 

s1 = "  1  Dayhoff       34598.308    63  69322.616    69333.353    69618.917"
list1 = s1.split()
print (list1)
#immutable - unchangeable
print (",".join(list1))

#join is opposite of split
#this string is practice but produce script
#testing out small pieces of code: copy and paste is great, but go to terminal then dir and then type "python 3 script_name"

 


#pseudocode:
#1. remove spaces
#2. turn into string into list into a string













