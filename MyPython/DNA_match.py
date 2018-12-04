#-*-coding:utf-8-*-'
import time,datetime
import pandas as pd
from Levenshtein import hamming

########################################################################
'''
creator: liuying
步骤：
0.读入待分析数据，将分组标记列1、列2单独存进一个dataframe，并去重，得到分组信息
1.循环步骤0得到的分组信息，按组取数，用dna_list存起来
2.两个循环。将组内每个dna序列与字典的每个key逐一比对，相似则添加进对应key的value里
（每个value为列表，代表一个分组）；如都不相似，则新建key
3.经过步骤2后，得到初步的分组结果；此时，如果value的列表只有一个元素，则说明，
这个key所代表的dna序列，与其它dna序列都不相似。
把所有这些与其它dna序列不相似的找出来，归到另一个组：dna_result_dict['no_match']
'''
#######################################################################
# 记录时间，用于查看程序耗时
t1 = time.time()
print 'begin,', t1
df = pd.read_csv('bowtief_chr.sam_1.csv',header=None)

df_group = df[[0,1]]        #分组信息在第1第2列
df_group = df_group.drop_duplicates()    #去重
print '共有%d大组' % len(df_group)

result_list = []  #用于存放结果
#group_cnt=1
group_cnt=0

for index, row in df_group.iterrows():    #row是df_group的每行
    group_cnt +=1
    if group_cnt <39490:
        continue
    print index

    groupname1, groupname2 = row[0], row[1]
    dna_series = df[(df[0] == groupname1) & (df[1] == groupname2)][2]

    #前者存数据，后者存结果
    dna_list = list(dna_series)  #将大组数据存进一个list
    dna_result_dict = {}

    for dna in dna_list:
        isNewKey = True
        for key in dna_result_dict.keys():
            if hamming(dna,key)<3:                 #小于3则相似
                dna_result_dict[key].append(dna)
                isNewKey = False
                break
        if isNewKey:
            dna_result_dict[dna] = [dna]

    #不相似的归到一组
    no_match_list = []
    group_index = 1
    for key, value in dna_result_dict.iteritems():
        if len(value) == 1:
            no_match_list.append(key)
            # del dna_result_dict[key]
        else:
            result_list.append([groupname1, groupname2, group_index, value])
            group_index += 1

    # dna_result_dict['no_match'] = no_match_list   #这个字典为分组结果
    if no_match_list:
        result_list.append([groupname1, groupname2, 0, no_match_list])
	print '第%d组分类完成'% group_cnt, (datetime.datetime.now()).strftime('%Y-%m-%d %H:%M:%S')
	#group_cnt += 1
#将最后结果存到csv
column_names = ['groupname1', 'groupname2', 'groupname3', 'text']
df_result = pd.DataFrame(columns=column_names, data=result_list)
df_result.to_csv('result_new.csv')

#记录时间，用于查看程序耗时
t2 = time.time()
print 'end,', t2
print 'total time:', t2-t1

