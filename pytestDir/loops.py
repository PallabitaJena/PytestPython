
greeting = "Good Morning"
a = 4

if a > 2:
    print(" Condition matches")
    print("second line")
else:
    print("condition do not match")

print("if else condition code is completed")


#for loop

obj= [2, 3, 5, 7, 9]
for i in obj:
    print(i*2)


# sum of First Natural numbers 1+2+3+4+5 = 15
#range(i,j) -> i to j-1
summation = 0
for j in range(1, 6): # for(i=0;i<0;i++)
    summation = summation + j
print(summation)

print("*******************************")
for k in range(1, 10, 5):# for(i=0;i<0;i+5)
    print(k)
    print("**************SKIPPING FIRST INDEX*****************")
for m in range(10):
    print(m)

### While loop

it = 10

while it>1:
    if it == 9:
        it = it - 1
        continue
    if it == 3:
        break
    print(it)

    it = it - 1

print('while loop execution is done')


#In Python, function is a group of related statements that perform a specific task.
#Function Declaration


def GreetMe(name):
    print("Good Morning"+name)
    #Function Call


def AddIntegers(a, b):
    return a+b


GreetMe("Rahul Shetty")

print(AddIntegers(2, 3))






















