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

print (file_lines)

counter = 1
for line in file_lines:
	print(counter, line)
	counter += 1
	
	