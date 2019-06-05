#problem1

#1a
filename = "road_not_taken.txt"

file_handle = open (filename, "r") 
fcontent = file_handle.read()
file_handle.close() 
#must always close file because if not, won't be accessible out of terminal

print(fcontent)

#1b
file_handle = open (filename, "r")
file_lines = file_handle.readlines()
file_handle.close()


counter = 1
for line in file_lines:
	print(counter, line)
	counter += 1
	
	
#1c 



# count_letters function
def count_letters(s):
    counts = {"a", "e", "i", "o", "u"} # vowel dict
    for c in s:
        if c in counts: # does letter exist in dict?
            counts[c]+= 1 # yes, increase count by 1
        else:
            counts[c]= 1 # no, set count to 1
    return counts # return result

# your code goes here

