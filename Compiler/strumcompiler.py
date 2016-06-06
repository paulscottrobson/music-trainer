###########################################################################################################################
###########################################################################################################################
#
#												STRUM FORMAT COMPILER
#
###########################################################################################################################
###########################################################################################################################

import re
from utilities import Bar,Strum,DownStrum,UpStrum,FileLoader,Compiler
from dictionary import UkuleleDictionary

###########################################################################################################################
#
#											Class that compiles .strum data
#
###########################################################################################################################

class StrumCompiler(Compiler):
	def compile(self):
		chords = ""
		lyrics = ""
		while not self.loader.isEOF():
			chordLine = ""																# Keep going till EOF or text
			while not self.loader.isEOF() and chordLine == "":
				chordLine = self.loader.get()
			if chordLine != "":															# if text found, its the chord
				if chords != "":														# add gap ?
					chords = chords + " "
					lyrics = lyrics + " "
				chords = chords + chordLine												# append chord and next line
				lyrics = lyrics + self.loader.get()										# which is lyrics
				rl = len(chords) if len(chords) > len(lyrics) else len(lyrics)			# make them the same length
				chords = chords + " " * (rl - len(chords))	
				lyrics = lyrics + " " * (rl - len(lyrics))
				assert len(chords) == len(lyrics)										# some tests
		assert chords.find("\t") < 0 and lyrics.find("\t") < 0,"TAB characters in file"	# we can't handle tabs, what size ?
		chords = chords.lower()															# make chord line lower case
		self.pattern = 1 																# current pattern.

		while chords != "":																# more to do.
			m = re.match("^\\@(\\d)\\s*",chords)										# found @<digit>
			if m is not None:
				self.pattern = int(m.group(1))											# switch pattern
				chunkSize = len(m.group(0))												# amount to remove
			else:
				m = re.match("^([a-gx][\\#b]?[a-z79]*)([\\s*\\/\\.]*)",chords)			# match against a chord
				assert m is not None,"Cannot process "+chords							# check okay.
				chunkSize = len(m.group(0))												# amount to remove
				self.music[self.barPosition].addLyric(lyrics[:chunkSize].strip())		# add lyrics if any.
				strums = "/"+m.group(2).replace(" ","")									# first strummed + the rest.
				assert self.beatPosition + len(strums) <= self.beats,"Bar overflow"		# check that the strums fit in this bar
				for s in strums:														# do each strum pair.
					if s == "/":														# if doing a strum here.
						self.generateChords(m.group(1).strip())							# generate the chords.
					self.beatPosition += 1 												# advance one beat position.
				if self.beatPosition == self.beats:										# reached end of bar
					self.barPosition += 1												# next bar.
					self.beatPosition = 0												# start of next bar.
					self.music.append(Bar(self.barPosition+1))							# new bar, adjust for bars at 1.

			chords = chords[chunkSize:]													# remove relevant bit.
			lyrics = lyrics[chunkSize:]

	def generateChords(self,chordName):
		chordFrets = self.getChord(chordName)											# get the Fret pattern				
		if chordFrets == "x":
			chordName = None		
		pattern = self.loader.ctrl("pattern"+str(self.pattern)).lower()					# get the pattern.
		pos = 1000 * self.beatPosition / self.beats 									# position			
		pChar = pattern[self.beatPosition * 2]											# associated beat
		vol = 100 if pChar == "d" or pChar == "u" else 50 								# du are loud others quiet.
		if pChar != '-':																# strum there ?
			self.music[self.barPosition].addStrum(DownStrum(pos,self.strings,vol,chordFrets).setChord(chordName))
		syncopate = 50																	# Syncopation or not.
		if self.loader.ctrl("swing")[0].lower() == 'y':
			syncopate = 60
		pos = pos + 1000 / self.beats * syncopate / 100 								# upstroke position
		pChar = pattern[self.beatPosition * 2+1]										# associated beat
		vol = 80 if pChar == "d" or pChar == "u" else 40 								# du are loud others quiet.
		if pChar != '-':																# strum there ?
			self.music[self.barPosition].addStrum(UpStrum(pos,self.strings,vol,chordFrets).setChord(chordName))

