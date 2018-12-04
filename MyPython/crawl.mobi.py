#-*- coding: UTF-8 -*- 
#http://blog.csdn.net/hongjinlongno1/article/details/51648687
import sys
import time

cache = {
	'http://udacity.com/cs101x/urank/index.html': """<html>
<body>
<h1>Dave's Cooking Algorithms</h1>
<p>
Here are my favorite recipies:
<ul>
<li> <a href="http://udacity.com/cs101x/urank/hummus.html">Hummus Recipe</a>
<li> <a href="http://udacity.com/cs101x/urank/arsenic.html">World's Best Hummus</a>
<li> <a href="http://udacity.com/cs101x/urank/kathleen.html">Kathleen's Hummus Recipe</a>
</ul>

<td nowrap>mobi</td>
<td nowrap>pdf</td>
<td nowrap>epub</td>

For more expert opinions, check out the 
<a href="http://udacity.com/cs101x/urank/nickel.html">Nickel Chef</a> 
and <a href="http://udacity.com/cs101x/urank/zinc.html">Zinc Chef</a>.
</body>
</html>

""",
	'http://udacity.com/cs101x/urank/zinc.html': """<html>
<body>
<h1>The Zinc Chef</h1>
<p>
I learned everything I know from 
<a href="http://udacity.com/cs101x/urank/nickel.html">the Nickel Chef</a>.
</p>
<p>
For great hummus, try 
<a href="http://udacity.com/cs101x/urank/arsenic.html">this recipe</a>.

<td nowrap>mobi</td>
<td nowrap>pdf</td>

</body>
</html>

""",
	'http://udacity.com/cs101x/urank/nickel.html': """<html>
<body>
<h1>The Nickel Chef</h1>
<p>
This is the
<a href="http://udacity.com/cs101x/urank/kathleen.html">
best Hummus recipe!
</a>

<td nowrap>pdf</td>
<td nowrap>epub</td>

</body>
</html>

""",
	'http://udacity.com/cs101x/urank/kathleen.html': """<html>
<body>
<h1>
Kathleen's Hummus Recipe
</h1>
<p>

<ol>
<li> Open a can of garbonzo beans.
<li> Crush them in a blender.
<li> Add 3 tablesppons of tahini sauce.
<li> Squeeze in one lemon.
<li> Add salt, pepper, and buttercream frosting to taste.
</ol>

<td nowrap>mobi</td>
<td nowrap>epub</td>

</body>
</html>

""",
	'http://udacity.com/cs101x/urank/arsenic.html': """<html>
<body>
<h1>
The Arsenic Chef's World Famous Hummus Recipe
</h1>
<p>

<td nowrap>pdf</td>
<td nowrap>epub</td>

<ol>
<li> Kidnap the <a href="http://udacity.com/cs101x/urank/nickel.html">Nickel Chef</a>.
<li> Force her to make hummus for you.
</ol>

</body>
</html>

""",
	'http://udacity.com/cs101x/urank/hummus.html': """<html>
<body>
<h1>
Hummus Recipe
</h1>
<p>

<td nowrap>pdf</td>
<td nowrap>pdf</td>

<ol>
<li> Go to the store and buy a container of hummus.
<li> Open it.
</ol>

</body>
</html>

""",
}

def get_page(url):
	if url in cache:
		return cache[url]
	return ""

'''
def get_page(url):
	try:
		import urllib
		return urllib.urlopen(url).read()
	except:
		return ""
'''
def get_next_url(content):
	start_url=content.find('a href=')
	if start_url==-1:
		return None,0
	start_quote=content.find('"',start_url)
	end_quote=content.find('"',start_quote+1)
	url=content[start_quote+1:end_quote]
	return url, end_quote

def get_all_link(content):
	arr=[]
	while content:
		url,end_pos=get_next_url(content)
		if url:
			arr.append(url)
			content=content[end_pos:]
		else:
			break
	return arr

def union(a,b):
	for e in b:
		if e not in a:
			a.append(e)

'''
def add_page_to_index(index, url, content):
	words = content.split()
	for word in words:
		add_to_index(index, word, url)

def add_to_index(index, key, url):
	if key in index:
		if url not in index[key]:
			index[key].append(url)
	else:
		index[key]=[url]
'''

def find_format(index, url, content):
	words = content.split()
	for word in words:
		if word=='<td nowrap>mobi</td>':
			if url not in index[mobi]:
				index[mobi].append(url)
		if word=='<td nowrap>pdf</td>':
			if url not in index[pdf]:
				index[pdf].append(url)
		if word=='<td nowrap>epub</td>':
			if url not in index[epub]:
				index[epub].append(url)



def crawl_web(url):
	tocrawl=[url]
	crawled=[]
	graph={}
	index={}
	while tocrawl:
		entry=tocrawl.pop()
		if entry not in crawled:
			content=get_page(entry)
			find_format(index, entry, content)
			outlinks=get_all_link(content)
			graph[entry]=outlinks
			union(tocrawl,outlinks)
			crawled.append(entry)
			#time.sleep(3)
	return index, graph

def compute_ranks(graph):
	d = 0.8 # damping factor
	numloops = 10

	ranks = {}
	npages = len(graph)
	for page in graph:
		ranks[page] = 1.0 / npages

	for i in range(0, numloops):
		newranks = {}
		for page in graph:
			newrank = (1 - d) / npages
			for node in graph:
				if page in graph[node]:
					newrank = newrank + d * (ranks[node] / len(graph[node]))
			newranks[page] = newrank
		ranks = newranks
	return ranks

def look_up(index, key):
	if key in index:
		return index[key]
	else:
		return None


def lucky_search(index, ranks, key):
	max=0
	out='None'
	if key in index:
		while index[key]:
			entry=index[key].pop()
			if ranks[entry]>max:
				max=ranks[entry]
				out=entry
		return out
	else:
		return out

def time_execution(code):
	start = time.clock()
	result = eval(code)
	run_time = time.clock() - start
	return result, run_time


if len(sys.argv)!=2:
	print "	Usage: "+sys.argv[0]+" <seed_url>"
	sys.exit()

seed = sys.argv[1]
(index, graph), crawl_time =time_execution("crawl_web(seed)")
ranks, rank_time =time_execution("compute_ranks(graph)")
print index
print graph
print ranks
#print crawl_time
#print rank_time
#print lucky_search(index, ranks, 'mobi')
#print look_up(index, 'mobi')
