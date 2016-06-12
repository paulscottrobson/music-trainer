#
#	These are Rods groupings.
#
rodChecks = {}
rodChecks["c"] = "C Am F G7 , C C0 Dm7 G7 , C C7 F Fm6 , C Am D7 G7, E7 Am D7 G7, E7 Am D7 G7 C"
rodChecks["f"] = "F Dm Bb C7,F F0 Gm7 C7, F F7 Bb Bbm6,F Dm G7 C7,A7 Dm G7 C7 F"
rodChecks["g"] = "G Em C D7, G G0 Am7 D7, G G7 C Cm6, G Em A7 D7, B7 Em A7 D7 G"
rodChecks["a"] = "A F#m D E7,A A0 Bm7 E7,A A7 D Dm6,A F#m B7 E7,C#7 F#m B7 E7 A"
rodChecks["d"] = "D Bm G A7,D D0 Em7 A7,D D7 G Gm6,D Bm E7 A7,F#7 Bm E7 A7 D"
#
#	These are chords that are done for everything.
#
oddChords = { "a0":"2323","bm7":"2222","dm6":"2212","c0":"2323","dm7":"2213",  \
			  "Fm6":"1213","em7":"0202","d0":"1212","gm6":"0201","f0":"1212","gm7":"0211",
			  "bbm6":"0111","am7":"0000","g0":"0101","Cm6":"2333" }

#
#	This is the header for every file, straight four strum.
#
header = "Tempo := 100; Swing := No; Pattern1 := d-d-d-d-; Beats := 4"
header = "\n".join([x.strip() for x in header.split(";")])
header = "\n# Automatically generated\n\n"+header+"\n\n"

c = oddChords.keys()
c.sort()
for n in c:
	header = header + "ukulele.{0} := {1}\n".format(n.lower(),oddChords[n])

header = header+"\n"
for noteKey in rodChecks.keys():																	# For every key (C F G A D)
	exNumber = 1																					# Numbers exercises.
	for repeat in range(4,0,-1):																	# blocks of 4,3,2,1
		for chordSet in [x.strip().lower() for x in rodChecks[noteKey].split(",")]:					# For each set of chords	
			chords = [x for x in chordSet.split(" ") if x.strip() != ""]							# Convert into a python list
			name = "Rod - {0:02} - Chords {2} x {1}.strum".format(exNumber,",".join(chords),repeat)
			group = "".join([(" "+c) * repeat for c in chords])										# one chord set, all chords repeated
			group = group * (6 / repeat)															# make all lines roughly the same
			group = (group + "\n\n\n") * 3															# Three lines of each
			tgtFile = "..\\Application\\media\\music\\uncle rod chord practice\\key of {0}\\{1}".format(noteKey,name)
			tgtFile = tgtFile.replace("#","sh")			
			render = "\n".join([x.strip() for x in (header+group).split("\n")])
			open(tgtFile,"w").write(render)
			exNumber += 1																			# Go to next chord

print("Generated "+str(exNumber*5))
#print(render)