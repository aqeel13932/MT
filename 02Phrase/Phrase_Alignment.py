
# coding: utf-8

# # Naive Approche with preprocessing for optimization.

# In[1]:

import numpy as np
import itertools
import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
MAX_LENGTH=5


# ### Some form of optimization (Preprocessing, creating dictionary to fasten source to destination and destination to source check)

# In[2]:

def AlignemtnToDictionary(alignmnt):
    """Convert alignment of form ['0-0','0-1'] to two dictionaries from source to destination and vice versa.
    Args:
        * alignmnt: list of strings contain the alignments. ['0-0','0-1','1-1'] etc..
    Return:
        * srcdic: source dictionary {0:[0,1],1:[1]}
        * destdic: destination dictioanry {0:[0],1:[0,1]}"""
    ls = map(lambda x:x.split('-'),alignmnt)
    ls = map(lambda x:(int(x[0]),int(x[1])),ls)
    srcdic ={}
    destdic ={}
    for element in ls:
        if element[0] not in srcdic:
            srcdic[element[0]]=[]
        srcdic[element[0]].append(element[1])
        if element[1] not in destdic:
            destdic[element[1]]=[]
        destdic[element[1]].append(element[0])
    return srcdic,destdic


def CheckListInList(lst,cond):   
    for c in cond:
        if c not in lst:
            return False
    return True

#Check if all source allignments in destination and all distination allignments in source
def IsOk(src,dst,alignment):
    for j in src: 
        try:
            condition = alignment[0][j]
            if CheckListInList(dst,condition):
                continue
            else:
                return False
        #This happen when Source is not allignemt with any thing
        except KeyError:
            continue
    for j in dst:
        try:
            condition = alignment[1][j]
            if CheckListInList(src,condition):
                continue
            else:
                return False
        #This happen When Destination is not alligned with anything.
        except KeyError:
            continue
    return True


# In[3]:

with open('eu.en') as s:
    source = map(lambda x: x.strip().split(),s.readlines())
with open('eu.et') as d:
    dest = map(lambda x: x.strip().split(),d.readlines())
with open('alignment.idxs') as al:
    alignements = map(lambda x:AlignemtnToDictionary(x.strip().split()),al.readlines())


# with open('00src') as s:
#     source = map(lambda x: x.strip().split(),s.readlines())
# with open('01dest') as d:
#     dest = map(lambda x: x.strip().split(),d.readlines())
# with open('02al') as al:
#     alignements = map(lambda x:AlignemtnToDictionary(x.strip().split()),al.readlines())

# In[4]:

srcCounter={}
destCounter={}
srcdesLink={}
def AddSrc(st):
    global srcCounter
    st = tuple(st)
    if st in srcCounter:
        srcCounter[st]+=1
    else:
        srcCounter[st]=1
        
def AddDest(st):
    global destCounter
    st = tuple(st)
    if st in destCounter:
        destCounter[st]+=1
    else:
        destCounter[st]=1
        
def AddLink(sst,dst):
    global srcdesLink
    sst = tuple(sst)
    dst = tuple(dst)
    if (sst,dst) in srcdesLink:
        srcdesLink[(sst,dst)]+=1
    else:
        srcdesLink[(sst,dst)]=1


# In[5]:

#Loop over all sentences
for sindx in range(len(source)):
    if sindx%1000==0:
        print sindx
    s= source[sindx]
    d= dest[sindx]
    al = alignements[sindx]
    #THe maximum window size for this sentence
    smws = min(MAX_LENGTH,len(s)+1)
    dmws = min(MAX_LENGTH,len(d)+1)
    #Loop over all window sizes for source sentence
    #sws for source window size
    for sws in range (1,smws):
        #ss : for source start position
        for ss in range(len(s)-sws+1):
            #dws : for destination window size
            for dws in range(1,dmws):
                #if (sws==1) and (dws==1):
                #    print 'Add Directly then continue'
                #ds : for destination window
                for ds in range(len(d)-dws+1):
                    
                    if IsOk(range(ss,ss+sws),range(ds,ds+dws),al):
                        AddSrc(s[ss:ss+sws])
                        AddDest(d[ds:ds+dws])
                        AddLink(s[ss:ss+sws],d[ds:ds+dws])
        


# In[6]:

with open('output.txt','w') as f:
    for i in srcdesLink:
        f.write('{}\t{}\t{}\t{}\n'.format(' '.join(i[0]),' '.join(i[1]),(srcdesLink[i]*1.0/srcCounter[i[0]]),(srcdesLink[i]*1.0/destCounter[i[1]])))


# In[ ]:



