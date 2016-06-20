# ***************************************************************************************************************************
# ***************************************************************************************************************************
#
#		Name:		chords.py
#		Purpose: 	Chord code and dictionary.
#		Author:		Paul Robson
#		Date:		20 June 2016
#
# ***************************************************************************************************************************
# ***************************************************************************************************************************

# ***************************************************************************************************************************
#										Class representing a single chord
# ***************************************************************************************************************************

class Chord:
	def __init__(self,name,strumDefinition):
		self.name = Chord.normalise(name.lower())												# name is stored normalised, no flats.
		self.strumDefinition = strumDefinition

	@staticmethod
	def normalise(chordName):
		chordName = chordName.lower()															# make l/c
		if len(chordName) > 1 and chordName[1] == 'b':											# convert flats to sharps.
			baseNote = chr(ord(chordName[0])-1) if chordName[0] != 'a' else 'g'					# so Bb will become A#, Ab becomes G#
			chordName = baseNote + '#' + chordName[2:]
		return chordName

	def render(self,isDownStrum,volume):
		render = ",".join([x for x in self.strumDefinition.upper()])							# create strum pattern
		if volume < 100:																		# add volume adjuster
			render = "@{0},{1}".format(volume,render)													
		render = "{0}[{1}]".format("d" if isDownStrum else "u",render)							# add strum direction
		return render

	def getName(self):
		return self.name 

	@staticmethod
	def reduce(name):
		name = Chord.normalise(name)															# normalise name
		strippers = [ "m","0","7","9","dim","sus" ]												# things you can reduce with it, backwards order
		remover = None
		for s in strippers:																		# find what you can remove
			if name[-len(s):] == s:
				remover = s
		if remover is not None:																	# chop chord back if found.
			remover = name[:-len(remover)]
		return remover

	@staticmethod
	def transpose(name,semitones):
		name = Chord.normalise(name)															# normalise name
		cLen = 1																				# get length of main chord name
		if len(name) > 1 and (name[1] == 'b' or name[1] == '#'):
			cLen = 2
		base = name[:cLen]																		# split into base and adjustments.
		stem = name[cLen:]
		tones = ["c","c#","d","d#","e","f","f#","g","g#","a","a#","b"]							# notes in order
		index = tones.index(base)																# this is its index
		index = (index + semitones + 1200) % 12 												# work out the new index
		return tones[index]+stem 																# and rebuild it.

# ***************************************************************************************************************************
#														Chord Dictionary
# ***************************************************************************************************************************
		
class ChordDictionary:
	def __init__(self):
		self.chords = { "ukulele": {} }															# chord data empty hashes
		self.setupUkulele()																		# set up for Ukulele

	def find(self,instrument,name):														
		chordName = Chord.normalise(name)														# normalise name.
		reductionCount = 0
		while chordName not in self.chords[instrument]:											# keep reducing until found or non existent.
			chordName = Chord.reduce(chordName)													# try reducing the chord to see if it exists
			if chordName is None:																# give up if reached the end.
				return None																		# this is things like C on a Merlin.
			reductionCount += 1																	# bump the count.
		return [self.chords[instrument][chordName],name,chordName,reductionCount]				# return a collection of information

	def load(self,instrument,chordData):
		chordData = chordData.replace("\t"," ").replace("\n"," ")								# tabs and returns become spaces
		for c in chordData.split():																# split it up
			base = Chord.normalise(c.split(":")[0])												# get the chord name, normalised.
			self.chords[instrument][base] = Chord(base,c.split(":")[1])							# create them.

	def append(self,instrument,chordName,chordDefinition):
		chordName = Chord.normalise(chordName)													# convert the name.
		self.chords[instrument][chordName] = Chord(chordName,chordDefinition)					# add it.

	def setupUkulele(self):																		# Uke chords
		chordInfo = """
			C:0003 Db:1114 D:2220 Eb:3331 E:4442 F:2010 Gb:3121 G:0232 Ab:1343 A:2100 Bb:3211 B:4322
			Cm:0333 Dbm:1104 Dm:2210 Ebm:3321 Em:0432 Fm:1013 Gbm:2120 Gm:0231 Abm:1342 Am:2000 Bbm:3111 Bm:4222
			C7:0001 Db7:1112 D7:2223 Eb7:3131 E7:1202 F7:2313 Gb7:3424 G7:0212 Ab7:1323 A7:0100 Bb7:1211 B7:2322
		"""
		self.load("ukulele",chordInfo)


#cd = ChordDictionary()
#cd.append("ukulele","gsus","0101")
#f = cd.find("ukulele","gsus")
#print(f,f[0].render(True,100))
