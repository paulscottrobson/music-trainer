# ***************************************************************************************************************************
# ***************************************************************************************************************************
#
#		Name:		indexbuilder.py
#		Purpose: 	Rebuilds index files
#		Author:		Paul Robson
#		Date:		20 June 2016
#
# ***************************************************************************************************************************
# ***************************************************************************************************************************

import os

for root,dirs,files in os.walk("..\\application\\media\\music"):								# for each subdirectory
	indices = { "ukulele":[], "merlin":[] }														# indices of instruments that may exist here
	for k in indices.keys():																	# for each key
		for d in dirs:																			# add each dictionary 
			indices[k].append("("+d+")")
	for f in files:																				# for each file.
		if f.find(".") >= 0:																	# that has some sort of type
			fileType = f[f.rfind(".")+1:].lower()												# get type
			if fileType in indices:																# is it a known instrument ?
				indices[fileType].append(f)														# store it in that index


	for k in indices.keys():																	# for each type.
		open(root+os.sep+k+".index","w").write("\n".join(indices[k]))							# write the index out
print("Indices built successfully.")