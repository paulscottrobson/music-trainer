import sys
from compiler import Compiler

def check(srcFile,music):
	comp = Compiler()
	src = open(srcFile).readlines()
	comp.compile(src)
	h = open("test.txt","w")
	comp.render(h,"ukulele",0)
	h.close()

	h = open("test.txt")
	o1 = h.readlines()
	h.close()
	h = open(music)
	o2 = h.readlines()
	h.close()	
	for i in range(0,len(o1)):
		if o1[i].strip() != o2[i].strip():
			print(srcFile,i,o1[i].strip(),o2[i].strip())
			sys.exit(0)

fList = [x.strip() for x in open("checklist.txt").readlines()]
for f in fList:
	if f[-6:] == ".strum":
		t = f[:-6]+".ukulele"
		t = t.replace("'","").replace("&","and")
		check(f,t)

# Rod stuff doesn't compile.