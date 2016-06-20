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

	def reportError(self,message,line):
		print("Error '{0}' at {1}".format(message,line+1))
		sys.exit(1)

	def compile(self,sourceCode):
		sourceCode.append("")																		# add extra blank line just in case.
		sourceCode = [x if x.find("#") < 0 else x[:x.find("#")] for x in sourceCode]				# remove spaces.
		self.equates = { "tempo":"120","swing":"no","beats":"4","pattern1":"d-d-d-d-" }				# initial equates
		for eq in [x for x in sourceCode if x.find(":=") >= 0]:										# process equates
			self.equates[eq.split(":=")[0].strip().lower()] = eq.split(":=")[1].strip().lower()
		self.sourceCode = [x.rstrip() if x.find(":=") < 0 else "" for x in sourceCode]				# remove equates, trailing spaces
		self.createChordLyricStrings()
		self.createBarData()

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

c = Compiler()
src = open("windows.strum").readlines()
c.compile(src)
print(c.equates)
for b in c.barList:
	print("-".join([x.chord for x in b.strums]),b.lyrics)