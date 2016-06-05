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
		for f in files:
			fullPath = root + os.sep + f
			if fullPath[-6:] == ".strum":
				print("Compiling '"+f+"'")
				StrumCompiler(fullPath).save()

compileTree("..\\Application")
