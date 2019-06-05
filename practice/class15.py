#if/else
#problem1
#a
x = 15
y = 0
if x > 0: 
	print (x, "is greater than", y)
else: 
	print (x, "is less than", y)
#b

if x > 0: 
	print (x, "is greater than", y)
elif x < 0:
	print (x, "is less than", y) 
else:
	print (x, "is equal to", y)

#problem 2

mylist = [19, 3, 2, 88, 56, 57, 11, 19, 9, 95]

if len(mylist) <= 10: 
	newlist = mylist[:3]
else: 
	newlist = mylist[:7]

new = sum(newlist)
print (new)

if new % 2 == 0:
	print ("The sum is even")
else:
	print("The sum is odd")

#problem3

a = 89.44
if  type(a) is int:
    print(a, "is an integer.")
elif type(a) is float:
    print(a, "is a float.")
elif type(a) is list:
    print(a, "is a list.")
elif type(a) is str:
    print(a, "is a list.") 


#loops
#problem1
#a

for i in range(11):
	print (2** (i))

#b

powers = []
for i in range(11):
	powers.append(2**i)
print (powers)

#problem2

protseq = "RTAHHCPLKLLAWS"
amino_weights = {'A':89.09, 'R':174.20, 'N':132.12, 'D':133.10, 'C':121.15,
                 'Q':146.15,'E':147.13,'G':75.07,'H':155.16,'I':131.17,
                 'L':131.17,'K':146.19,'M':149.21,'F':165.19,'P':115.13,
                 'S':105.09,'T':119.12,'W':204.23,'Y':181.19,'V':117.15}

weight = 0
for aa in protseq:
	weight += amino_weights[aa]
print (weight)
