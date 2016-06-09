###########################################################################################################################
###########################################################################################################################
#
#													UTILITY CLASSES
#
###########################################################################################################################
###########################################################################################################################

from dictionary import UkuleleDictionary

###########################################################################################################################
#
#				Class that loads in a file with the given name, strips the comments and equates out.
#
###########################################################################################################################

class FileLoader:
	def __init__(self,fileName,tabsAllowed = True):
		src = open(fileName).readlines()												# open file and read it in.
		src = [x.rstrip() for x in src]													# right strip everything
		src = [x for x in src if (x+" ")[0] != '#']										# remove comments
		self.assignments = { "tempo":"120","beats":"4","pattern1":"d-d-d-d-"}			# assignment default values
		self.assignments["instrument"] = "ukulele"										# default instrument.
		for assign in [x for x in src if x.find(":=") >= 0]:							# for all assignments
			n = assign.find(":=")														# find split points
			self.assignments[assign[:n].strip().lower()] = assign[n+2:].strip()			# save the assignment
		src = [x for x in src if x.find(":=") < 0]										# extract the non-assignments
		self.sourceCode = src 															# save the resulting source code.
		self.pointer = 0																# index into it.

	def isEOF(self):																	# test end of file
		return self.pointer >= len(self.sourceCode)

	def get(self):																		# get next line, return "" if EOF
		retVal = ""
		if not self.isEOF():
			retVal = self.sourceCode[self.pointer]
			self.pointer += 1
		return retVal

	def ctrl(self,key):
		key = key.lower().strip()
		return self.assignments[key] if key in self.assignments else ""

###########################################################################################################################
#
#									Representation of single strum or fingerpick event
#
###########################################################################################################################

class Strum:
	def __init__(self,position,strings,volume = 100,direction = 1,pattern = None):
		self.beatSubPosition = position 												# position 0-999 in bar.
		self.chord = None 																# No visual representation of a chord
		self.volume = volume 															# save percentage volume
		self.strings = strings 															# Number of strings
		self.frets = [ None ] * strings													# Fret positions (all no strum)
		if pattern is not None:															# Set the strum if appropriate.
				self.setStrum(pattern)														

	def setChord(self,chord):
		self.chord = chord
		return self

	def setStrum(self,pattern):
		pattern = ("XXXXXX" + pattern)[-self.strings:].upper()							# right justify with no-strum
		for i in range(0,self.strings):													# for each string.
			if pattern[i] == 'X':														# No strum
				self.frets[i] = None
			elif pattern[i] >= '0' and pattern[i] <= '9':								# standard fret positions.
				self.frets[i] = int(pattern[i])
			elif pattern[i] >= 'A' and pattern[i] <= 'Z':								# way up the fretboard A-Z
				self.frets[i] = ord(pattern[i]) - ord('A') + 10
			else:
				assert False, "Bad Pattern "+pattern+" in strum"
		return self 

	def render(self,barNumber):
		pos = Strum.toPosition(barNumber+1000,self.beatSubPosition)						# position prefix.
		render = ""
		if self.chord is not None:														# render chord if present
			render = render + pos + "<"+self.chord.lower()+">\n"
		if len([x for x in self.frets if x is not None]) > 0:							# if there is any strummed strings
			render = render + pos + self.direction + "["
			if self.volume < 100:														# volume setting
				render = render + "@"+str(self.volume)+","
			render = render + ",".join(["X" if x is None else str(x) for x in self.frets])
			render = render + "]\n"
		return render

	@staticmethod
	def toPosition(barNumber,beatSubPosition):									
		return "{0:05}.{1:04}:".format(barNumber,beatSubPosition)

class UpStrum(Strum):
	def __init__(self,position,strings,volume,pattern = None):
		self.direction = 'u'
		Strum.__init__(self,position,strings,volume,-1,pattern)

class DownStrum(Strum):
	def __init__(self,position,strings,volume,pattern = None):
		self.direction = 'd'
		Strum.__init__(self,position,strings,volume,1,pattern)

###########################################################################################################################
#
#												Representation of a bar.
#
###########################################################################################################################

class Bar:
	def __init__(self,barNumber):
		self.barNumber = barNumber 														# save bar number
		self.strums = [] 																# array of strums
		self.lyric = "" 																# lyric for this bar.

	def addStrum(self,strum):
		self.strums.append(strum)
		return self

	def addLyric(self,lyric):
		self.lyric = self.lyric + " " + lyric.strip()
		while self.lyric.find("  ") >= 0:
			self.lyric = self.lyric.replace("  "," ")
		self.lyric = self.lyric.strip()
		return self

	def render(self):
		render = ""
		if self.lyric.strip() != "":													# add lyric if exists
			render = render+Strum.toPosition(self.barNumber+1000,0)+'"'+self.lyric.rstrip()+"\n"	
		for s in self.strums:															# concatenate all strum renders
			render = render + s.render(self.barNumber)
		return render													

###########################################################################################################################
#
#													Compiler Base Class
#
###########################################################################################################################

class Compiler:
	def __init__(self,fileName):
		self.srcFile = fileName
		self.music = [ Bar(1) ]															# array of music
		self.stripList = [ "sus","dim","9","7","+","m" ]								# things to try removing.
		self.barPosition = 0															# in bar index 0
		self.beatPosition = 0															# on beat index 0
		self.loader = FileLoader(fileName) 												# save loader
		self.beats = int(self.loader.ctrl("beats"))										# read the beats in a bar.
		stringMapper = { "ukulele":4, "merlin":3 }
		self.strings = stringMapper[self.loader.ctrl("instrument").lower()]				# work out how many strings
		self.dictionary = UkuleleDictionary()											# working dictionary.
		self.compile()																	# compile the tune.

	def render(self):
		render = ""																		# build up the rendered song.
		for bar in self.music:
			render = render + bar.render()
		render = render + self.getAssign("instrument",0)
		render = render + self.getAssign("beats",1)
		render = render + self.getAssign("tempo",2)
		render = [x.strip() for x in render.strip().split("\n") if x.strip() != 0]		# split remove empty strings
		render.sort()																	# sort it		
		return "\n".join(render)

	def getAssign(self,key,id):
		return Strum.toPosition(100,id)+key.lower()+" := "+self.loader.ctrl(key.lower())+"\n"

	def getChord(self,chordName):
		chordName = chordName.lower()													# lower case.
		fretting = self.getChordAbsolute(chordName)										# get absolute fretting.
		for chop in self.stripList:
			if fretting == "" and chordName[-len(chop):] == chop:						# if not found and choppable
				chordName = chordName[:-len(chop)]										# chop the chord
				fretting = self.getChordAbsolute(chordName)								# and try again.
		return fretting

	def getChordAbsolute(self,chordName):
		chordName = chordName.lower()													# make L/C
		frets = self.dictionary.getChord(chordName)										# read from the dictionary.
		if frets == "":																	# if not found
			key = self.loader.ctrl("instrument").lower()+"."+chordName					# is it an assigned chord
			frets = self.loader.ctrl(key.lower())										# try it from there
		return frets

	def save(self):
		render = self.render()															# get result
		targetFile = ".".join(self.srcFile.split(".")[:-1])+".music"					# create object file name
		targetFile = targetFile.lower().replace("&","and").replace(":"," ")				# tidy up name for URL/Filename
		targetFile = targetFile.replace("'","")
		handle = open(targetFile,"w")													# write to file.
		handle.write(render)
		handle.close()
		return targetFile
		