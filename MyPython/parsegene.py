#-*- coding:utf-8 -*-

import urllib2
import urllib
import time
from bs4 import BeautifulSoup

def getContent(url):
    html = urllib.urlopen(url)
    content = html.read()
    return content

if __name__ == "__main__":
    for i in range(1,140):
     	url = 'http://gen.lib.rus.ec/search.php?&req=mobi&phrase=1&view=simple&column=def&sort=def&sortmode=ASC&page='
	url += str(i)
	text = getContent(url)
	#print text
	soup = BeautifulSoup(text)
        print "******************page:"+str(i)+"*****************"
	#print soup.find_all('a').get('href')
	for div in soup.find_all(attrs={"class":"c"}):
                print  div.get_text()
		'''
                for tr in div.find_all('tr')[10]:
		    #print tr.get_text()
		    #print tr
		    #print tr.get('href')
		    #print tr.type 		    
		    for td in tr:
			print td
			lista = td.find('a')
			#print lista 
                        #li = lista.a['href']
                        #print li
		'''
	for alist in soup.find_all(attrs={'title':'Libgen'}):
	    hrefs = alist.get('href')
	    print hrefs
	    '''
	    text = getContent(hrefs)
            #print text
       
       	    soup = BeautifulSoup(text)
	    for tds in soup.find_all(attrs={"class":"dropdown_4columns"}):
		alists = tds.find_all('a')
		print alists.get('href')
	    '''
    	time.sleep(4)
