file = open('text.txt')

# line = file.readline()
# while line!="":
#     print(line)
#     line = file.readline()


for line in file.readlines():
    print(line)

file.close()

#below does not require file open or file close it would do automatically
#read the file and store all the lines in list
#reverese the list
#write back on text.txt
with open('text.txt', 'r') as reader:
    content = reader.readlines()
    reversed(content)
    with open('text.txt', 'w') as writer:
        for line in reversed(content):
         writer.write(line)


#or
with open('file1.txt') as reader:
    content = reader.read()
    print(content)


#or
with open('file1.txt') as reader:
    for line in reader:
        print(line.rstrip('\n'))