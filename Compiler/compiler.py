# ***************************************************************************************************************************
# ***************************************************************************************************************************
#
#		Name:		compiler.py
#		Purpose: 	Strum Compiler
#		Author:		Paul Robson
#		Date:		20 June 2016
#
# ***************************************************************************************************************************
# ***************************************************************************************************************************

import sys,re,os
from chords import Chord,ChordDictionary

# ***************************************************************************************************************************
#													Represents a bar
# ***************************************************************************************************************************

class Bar:
	def __init__(self):
		self.lyrics = ""
		self.strums = []

	def appendLyric(self,lyric):
		self.lyrics = (self.lyrics+" "+lyric).strip()
		while self.lyrics.find("  ") >= 0:
			self.lyrics = self.lyrics.replace("  "," ")

	def appendStrumPair(self,pair):
		self.strums.append(pair)
		return len(self.strums)

# ***************************************************************************************************************************
#								Represents a single strum pair, which depends on the pattern
# ***************************************************************************************************************************

class StrumPair:
	def __init__(self,chord,patternID):
		self.chord = chord
		self.patternID = patternID

# ***************************************************************************************************************************
#														Strum file compiler
# ***************************************************************************************************************************

class Compiler:
	#
	#	Report errors
	#
	def reportError(self,message,line):
		print("Error '{0}' at {1}".format(message,line+1))
		sys.exit(1)
	#
	#	Compile one source file to a collection of bar information.
	#
	def compile(self,sourceCode):
		sourceCode.append("")																		# add extra blank line just in case.
		self.dictionary = ChordDictionary()															# get a new dictionary instance.
		sourceCode = [x if x.find("#") < 0 else x[:x.find("#")] for x in sourceCode]				# remove spaces.
		self.equates = { "tempo":"120","swing":"no","beats":"4","pattern1":"d-d-d-d-" }				# initial equates
		for eq in [x for x in sourceCode if x.find(":=") >= 0]:										# process equates
			key = eq.split(":=")[0].strip().lower()													# key
			if key.find(".") >= 0:																	# is it a.b := c, if so load into dictionary
				self.dictionary.append(key.split(".")[0].strip(),key.split(".")[1].strip(),eq.split(":=")[1].strip())
			else:
				self.equates[key] = eq.split(":=")[1].strip().lower()								# set value.


		self.sourceCode = [x.rstrip() if x.find(":=") < 0 else "" for x in sourceCode]				# remove equates, trailing spaces
		self.createChordLyricStrings()
		self.createBarData()
	#
	#	Create the two long strings of chord data and lyric data
	#
	def createChordLyricStrings(self):
		self.chordData = ""																			# chord information
		self.lyricData = ""																			# lyric information.
		self.lineNumber = 0																			# current line pointer
		#
		#	Convert music into two single strings, the lyric string has bars where line counts are (+2 per line)
		#
		while self.lineNumber < len(self.sourceCode):												# keep going until finished.
			while self.lineNumber < len(self.sourceCode) and self.sourceCode[self.lineNumber] == "":# skip over any blank lines
				self.lineNumber+=1
				self.chordData += " "
				self.lyricData += "|"
			if self.lineNumber < len(self.sourceCode):												# found some code ?
				self.chordData += self.sourceCode[self.lineNumber]									# append it to chord/lyric data
				self.lyricData += self.sourceCode[self.lineNumber+1]										
				if self.chordData.find("\t") >= 0 or self.lyricData.find("\t") >= 0:				# check for TABs
					self.reportError("Line contains TAB characters",self.lineNumber)
				self.lineNumber += 2																# skip over those lines.
				ls = len(self.chordData) if len(self.chordData) > len(self.lyricData) else len(self.lyricData)
				self.chordData = self.chordData + (" " * (ls - len(self.chordData))) + "  "			# pad out to same length
				self.lyricData = self.lyricData + (" " * (ls - len(self.lyricData))) + "||"			# add two bar seperators, two lines.
				assert len(self.chordData) == len(self.lyricData)									# check.
	#
	#	Create the bar data from the chord and lyric data.
	#
	def createBarData(self):
		self.currentPattern = 1																		# currently pattern 1.
		self.chordData = self.chordData.lower()														# chord data always L/C
		self.barList = [Bar()]																		# List of bars.
		self.compileLineNumber = 1																	# line number when compiling.

		while self.chordData != "":																	# compile the whole string pair.
			while self.chordData[0] == ' ' and self.lyricData[0] == ' ':							# remove any leading spaces where they
				self.chordData = self.chordData[1:]													# BOTH have them.
				self.lyricData = self.lyricData[1:]

			m = re.match("^\\@([1-9])",self.chordData)												# pattern switch ?
			if m is not None:
				self.currentPattern = int(m.group(1))												# set current pattern
				if self.lyricData[:2] != "  ":														# error if not mirrored by two spaces
					self.reportError("Pattern setting can not happen over lyric",self.compileLineNumber)
				if "pattern"+str(self.currentPattern) not in self.equates:							# do we not know this pattern ?
					self.reportError("Unknown pattern "+str(self.currentPattern),self.compileLineNumber)
				self.chordData = self.chordData[2:]													# chuck the @x and the spaces.
				self.lyricData = self.lyricData[2:]
			elif self.chordData[0] == ' ' and self.lyricData[0] == '|':								# if space/bar (e.g. line seperator normal place)
				self.chordData = self.chordData[1:]													# chuck the space and bar
				self.lyricData = self.lyricData[1:]
				self.compileLineNumber += 1 														# one extra line.
			else:
				m = re.match("^([a-gx][\\#b]?[a-z0679]*)([\\/\\.]*)\\s*",self.chordData)
				if m is None:
					self.reportError("Syntax in Music",self.compileLineNumber)
				lenSection = len(m.group(0))														# this is the whole bit to chop.
				chordName = m.group(1)																# this is the chord name
				beatDesc = "/"+m.group(2)															# this is the beat pattern / and .
				lyrics = self.lyricData[:lenSection].strip()										# these are the lyrics for this bit.
				self.chordData = self.chordData[lenSection:]										# strip the used bits off.
				self.lyricData = self.lyricData[lenSection:]
				self.compileLineNumber += len([x for x in lyrics if x == "|"])						# count number of new line markers and add
				lyrics = lyrics.replace("|"," ")													# change bar markers back to spaces.
				self.barList[-1].appendLyric(lyrics)												# add lyrics.

				size = 0
				for b in beatDesc:
					pair = StrumPair(chordName if b == "/" else "x",self.currentPattern)			# create a strum pair, maybe no strum.
					size = self.barList[-1].appendStrumPair(pair)									# append and get length
					if size > int(self.equates["beats"]):											# overflowed bar ?
						self.reportError("Bar overflow",self.compileLineNumber)
				if size == int(self.equates["beats"]):												# do we need a new bar ?
					self.barList.append(Bar())
	#
	#	Score a specific transposition in semi tones for a specific instrument.
	#
	def scoreTransposition(self,instrument,transpose):
		chordCount = {}																				# count chords used.
		chordAdjust = {}																			# amount of reductions for each chord.
		for b in self.barList:																		# look through all bars
			for s in b.strums:																		# and strums
				if s.chord != "x":		
					chord = Chord.transpose(s.chord,transpose)										# the chord transposed
					if chord not in chordCount:
						chordCount[chord] = 0														# none so far					
						chordAdjust[chord] = -30													# score if we can't do it full stop
						cInst = self.dictionary.find(instrument,chord)								# get the instance
						if cInst is not None:
							chordAdjust[chord] = -(cInst[3]*cInst[3])
					chordCount[chord] += 1															# one chord of this type.
		score = 0
		for c in chordCount.keys():																	# calculate the overall score
			score = score + chordCount[c] * chordAdjust[c]
		return score
	#
	#	Render the compiled data.
	#
	def render(self,fileHandle):
		self.writeLine(fileHandle,100,1,"beats := {0}".format(self.equates["beats"]))				# output beats/bar and tempo
		self.writeLine(fileHandle,100,2,"tempo := {0}".format(self.equates["tempo"]))
		barNumber = 1001 
		for bar in self.barList:																	# render all bars.
			if bar.lyrics != "":																	# lyric first if any
				self.writeLine(fileHandle,barNumber,0,'"'+bar.lyrics)
			# TODO: Render individual strums where appropriate.
			barNumber += 1 																			# next bar.
	#
	#	Output a single line.
	#
	def writeLine(self,handle,time,subtime,line):									
		handle.write("{0:05}.{1:04}:{2}\n".format(time,subtime,line))

c = Compiler()
src = open("windows.strum").readlines()
c.compile(src)
#print(c.scoreTransposition("ukulele",0))
c.render(sys.stdout)

