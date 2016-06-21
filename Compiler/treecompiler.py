# ***************************************************************************************************************************
# ***************************************************************************************************************************
#
#		Name:		treecompiler.py
#		Purpose: 	Strum Compiler of whole music tree
#		Author:		Paul Robson
#		Date:		20 June 2016
#
# ***************************************************************************************************************************
# ***************************************************************************************************************************

from compiler import Compiler
import os,re

def processName(fileName):
	fileName = fileName.lower()																	# make L/C
	fileName = fileName.replace("'","").replace("&"," and ")									# process quote marks and "and" shorthand
	while fileName.find("  ") >= 0:																# remove double spaces
		fileName = fileName.replace("  "," ")
	return fileName

def renderMusic(compiler,fileName,instrument,transposition):
	assert re.match("^[0-9a-z\\.\\\\\\s\\-_,]+$",fileName) is not None,fileName					# validate the file name as okay.
	target = open(fileName+"."+instrument,"w")										
	compiler.render(target,instrument,transposition)
	target.close()

print("*** Recompiling the music tree ***")
for root,dirs,files in os.walk("..\\Application\\media\\music"):								# scan all music area
	for fileName in files:																		# scan all files.
		if fileName[-6:] == ".strum":															# found a strum file
			fullStem = (root + os.sep + fileName)[:-6]											# full file name without the .strum suffix
			targetStem = processName(fullStem)													# Output file name stem

			compileIt = not os.path.isfile(targetStem+".ukulele")								# compile it if it doesn't exist
			if not compileIt:																	# if it does exist, compile only if .strum newer
				compileIt = os.path.getmtime(fullStem+".strum") > os.path.getmtime(targetStem+".ukulele")

			if compileIt:
				print("Compiling '"+fileName+"'")
				compiler = Compiler()															# create a new compiler instance
				compiler.compile(open(fullStem+".strum").readlines())							# compile the music

				renderMusic(compiler,targetStem,"ukulele",0)
