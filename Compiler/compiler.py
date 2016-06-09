###########################################################################################################################
###########################################################################################################################
#
#													MUSIC COMPILER
#
###########################################################################################################################
###########################################################################################################################

import os,sys,re 

from utilities import Bar,Strum,DownStrum,UpStrum,FileLoader
from dictionary import UkuleleDictionary
from strumcompiler import StrumCompiler


def compileTree(directory):
	for root,dirs,files in os.walk(directory):
		indexFile = ["("+x+")" for x in dirs]
		for f in files:
			fullPath = root + os.sep + f
			if fullPath[-6:] == ".strum":
				print("Compiling '"+f+"'")
				tgt = StrumCompiler(fullPath).save()
				indexFile.append(tgt[len(root)+1:])
		if len(indexFile) != 0:
			indexFile.sort()
			open(root+os.sep+"index.txt","w").write("\n".join(indexFile))

compileTree("..\\Application\\media\\music")
