def CrossesCount(line):
    output = []
    largest=-10
    counter =0
    for x in [pair.split('-') for pair in line.strip().split()]:
        res = (int(x[0]),int(x[1]))
        output.append(res)
        if (res[0]>=largest):
            largest=res[0]
        else:
            counter+=1
    return counter

def CrossesCountDictionary(line,indmap):
    output = []
    largest=-10
    counter =0
    for x in [pair.split('-') for pair in line.strip().split()]:
        res = (indmap[int(x[0])],int(x[1]))
        output.append(res)
        if (res[0]>=largest):
            largest=res[0]
        else:
            counter+=1
    return counter
    
def TotalDistance():
	lined = open('forward.align')
	Total=0
	print('Started need around 47 seconds to finish')
	for i in range(5015000):
		l = lined.readline()
		Total+= CrossesCount(l)
	print('Finished primary Scoring')
	return Total




