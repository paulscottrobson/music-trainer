###########################################################################################################################
###########################################################################################################################
#
#											CHORD DICTIONARY
#
###########################################################################################################################
###########################################################################################################################

class BaseDictionary:
	def __init__(self):
		self.chordMapping = { "x":"x"} 													# chord name -> chord fretting.
		self.normMapping = { "db":"c#","d#":"eb","gb":"f#","ab":"g#","a#":"bb"}			# map c# eb f# g# bb
		chords = self.getChordData()													# get chords.
		chords = chords.replace("\t"," ").replace("\n","")								# replace tabs and returns.
		for c in [x for x in chords.split() if x != ""]:								# get chords in the list.
			c = c.lower().split(":")													# split into name and fretting
			self.chordMapping[self.normalise(c[0])] = c[1].strip()						# save in mapping.

	def getChord(self,chordName):
		chordName = chordName.lower().strip()											# l/c, no spaces
		return "" if chordName not in self.chordMapping else self.chordMapping[chordName]

	def normalise(self,name):
		name = name.lower()																# make lower case
		if name[:2] in self.normMapping:												# convert where required
			name = self.normMapping[name[:2]] + name[2:]
		return name

class UkuleleDictionary(BaseDictionary):
	def getChordData(self):
		return """
			C:0003 Db:1114 D:2220 Eb:3331 E:4442 F:2010 Gb:3121 G:0232 Ab:1343 A:2100 Bb:3211 B:4322
			Cm:0333 Dbm:1104 Dm:2210 Ebm:3321 Em:0432 Fm:1013 Gbm:2120 Gm:0231 Abm:1342 Am:2000 Bbm:3111 Bm:4222
			C7:0001 Db7:1112 D7:2223 Eb7:3131 E7:1202 F7:2313 Gb7:3424 G7:0212 Ab7:1323 A7:0100 Bb7:1211 B7:2322
		"""