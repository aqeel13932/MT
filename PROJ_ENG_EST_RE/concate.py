import codecs

source = codecs.open('tc-tok-all.en')
dest = codecs.open('tc-tok-all.et')
mixed = codecs.open('mixed.txt','w')
for i in range(5015000):
    line= source.readline().strip()+' ||| '+ dest.readline()
    mixed.write(line)


