###########################################################################################################################
###########################################################################################################################
#
#													UTILITY CLASSES
#
###########################################################################################################################
###########################################################################################################################

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

###########################################################################################################################
#
#									Representation of single strum or fingerpick event
#
###########################################################################################################################

class Strum:
	def __init__(self,position,strings,direction = 1,pattern = None):
		self.beatSubPosition = position 												# position 0-999 in bar.
		self.chord = None 																# No visual representation of a chord
		self.volume = 100 if direction > 0 else 50										# save percentage volume
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
		pos = Strum.toPosition(barNumber,self.beatSubPosition)							# position prefix.
		render = ""
		if self.chord is not None:														# render chord if present
			render = render + pos + "<"+self.chord.lower()+">\n"
		if len([x for x in self.frets if x is not None]) > 0:							# if there is any strummed strings
			render = render + pos + "["
			if self.volume < 100:														# volume setting
				render = render + "@"+str(self.volume)+","
			render = render + ",".join(["X" if x is None else str(x) for x in self.frets])
			render = render + "]\n"
		return render

	@staticmethod
	def toPosition(barNumber,beatSubPosition):									
		return "{0:05}.{1:04}:".format(barNumber,beatSubPosition)

class UpStrum(Strum):
	def __init__(self,position,strings,pattern = None):
		Strum.__init__(self,position,strings,-1,pattern)

class DownStrum(Strum):
	def __init__(self,position,strings,pattern = None):
		Strum.__init__(self,position,strings,1,pattern)

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

	def setLyric(self,lyric):
		self.lyric = lyric.rstrip()
		return self

	def render(self):
		render = ""
		if self.lyric.strip() != "":													# add lyric if exists
			render = render+Strum.toPosition(self.barNumber,0)+'"'+self.lyric.rstrip()+"\n"	
		for s in self.strums:															# concatenate all strum renders
			render = render + s.render(self.barNumber)
		render = [x for x in render.split("\n") if x != ""]								# split into lines
		render.sort()																	# sort		
		return "\n".join(render)														# reassemble

