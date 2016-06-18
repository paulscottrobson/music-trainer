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
				targetFile = ".".join(fullPath.split(".")[:-1])+".ukulele"					# create object file name
				targetFile = targetFile.lower().replace("&","and").replace(":"," ")				# tidy up name for URL/Filename
				targetFile = targetFile.replace("'","")
				compileFile = True
				if os.path.isfile(targetFile):
					compileFile = os.path.getmtime(fullPath) > os.path.getmtime(targetFile)
				if compileFile:
					print("Compiling '"+f+"'")
					tgt = StrumCompiler(fullPath).save(targetFile)
				indexFile.append(targetFile[len(root)+1:])
		if len(indexFile) != 0:
			indexFile.sort()
			open(root+os.sep+"index.txt","w").write("\n".join(indexFile))

compileTree("..\\Application\\media\\music")

#StrumCompiler("..\\Application\\media\\music\\test.strum").save()