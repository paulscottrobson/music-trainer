// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		song.agc
//		Purpose:	Song Class, represents the contents of a .music file.
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																Song Object Members and Sub Members
// ****************************************************************************************************************************************************************

type Strum
	frets as integer[1]																				// Frets numbered from 1 (G:0232 will map [1]=0 [2]=2 [3]=3 [4]=2
	volume as integer 																				// Volume 0..100
	time as integer 																				// Position in bar in thousandth of a beat
	chordName$ as string 																			// Name of chord in lower case
	fretDesc$ as string 																			// Fret name in 0232 format, "" if not chordable (e.g. high frets)
	direction as integer 																			// Strum direction (-1 = up, 1 = down)
	displayChord as integer 																		// Non zero if should be displayed as chord.
	_nextChord$ as string 																			// Name of next chord.
endtype

type Bar 
	beats as integer 																				// Beats in the bar
	strumCount as integer 																			// Number of strum events in the bar.
	strums as Strum[1]																				// Strum events in bar
	lyric$ as String 																				// Lyrics associated with this bar.
endtype

type Song 
	tempo as integer 																				// Tempo in beats / minute
	beats as integer 																				// Beats in a bar
	barCount as integer 																			// Number of bars in song
	bars as Bar[1]																					// Bar data
endtype

// ****************************************************************************************************************************************************************
//																	Create a song object
// ****************************************************************************************************************************************************************

function Song_New(song ref as Song)
	song.tempo = 120
	song.beats = 4
	song.barCount = 0 																				// Clear song array.
	song.bars.length = 1
endfunction

// ****************************************************************************************************************************************************************
//																	Delete a song object
// ****************************************************************************************************************************************************************

function Song_Delete(song ref as Song)
endfunction

// ****************************************************************************************************************************************************************
//																   Load the named song in.
// ****************************************************************************************************************************************************************

function Song_Load(song ref as Song,fileName as String)
	fileName = IOAccessFile(fileName)																// Access the file name
	ASSERT(GetFileExists(fileName),"SLD:NoFile"+fileName)											// File exists ?
	handle = OpenToRead(fileName) 																	// Open file to read.
	currentBar = 0 																					// Number of current bar (last one in the bars list)
	while FileEOF(handle) = 0																		// Keep reading lines.
		line$ = ReadLine(handle)
		if line$ <> "" and left(line$,1) <> "#"														// not blank or comment.
			if FindString(line$,":=") > 0 															// found an assign ?
				_Song_DoAssignment(song,line$)
			else
				barNumber = Val(GetStringToken(line$,".",1))										// Get the bar number from the line.
				if barNumber <> currentBar 															// New bar ?
					currentBar = barNumber															// The current bar is this one.
					inc song.barCount 																// One extra bar
					if song.barCount > song.bars.length then song.bars.length = song.barCount + 16	// Expand the bars array if necessary
					song.bars[song.barCount].lyric$ = "" 											// Clear the bar sub object
					song.bars[song.barCount].strumCount = 0 										// No strums as yet.
					song.bars[song.barCount].beats = song.beats 									// Copy beats in
				endif
				_Song_ProcessLine(song,mid(line$,FindString(line$,".")+1,9999))						// Process line without the bar number 														// It is <chord> [strum] or "lyric
			endif
		endif
	endwhile
	CloseFile(handle)																				// Close file.
	_Song_SetupNextChord(song)																		// Set up next chord elements
endfunction

// ****************************************************************************************************************************************************************
//															Handle a := b assignments
// ****************************************************************************************************************************************************************

function _Song_DoAssignment(song ref as Song,assign$ as String)
	assign$ = mid(assign$,FindString(assign$,":")+1,9999)											// Throw away the positional prefix.
	value$ = mid(assign$,FindString(assign$,":=")+2,9999)											// This is the RHS of the assignment
	select TrimString(Lower(GetStringToken(assign$,":=",1))," ")
		case "tempo"																				// Set bpm
			song.tempo = Val(value$)
		endcase
		case "beats" 																				// Set beats per bar
			song.beats = Val(value$)
		endcase
		case default
			ERROR("Bad assignment "+assign$)
		endcase
	endselect
endfunction

// ****************************************************************************************************************************************************************
//												Handle bbbb.aaa:command where command is a chord, strum or lyric
// ****************************************************************************************************************************************************************

function _Song_ProcessLine(song ref as Song,line$ as String)
	beatPosition = Val(GetStringToken(line$,":",1))													// Get beat position
	line$ = mid(line$,FindString(line$,":")+1,9999)													// Remove position and colon.
	if left(line$,1) = chr(34)																		// Is it "<something>
		song.bars[song.barCount].lyric$	= TrimString(mid(line$,2,9999)," ")							// Store it in the lyric for this bar
	else
		pos = 0																						// Find that beat position if it exists.
		for i = 1 to song.bars[song.barCount].strumCount 
			if song.bars[song.barCount].strums[i].time = beatPosition then pos = i 
		next i
		if pos = 0 																					// Not found add it.
			inc song.bars[song.barCount].strumCount 												// Bump count of strums
			pos = song.bars[song.barCount].strumCount 												// Saves lots of typing
			if pos > song.bars[song.barCount].strums.length											// Make space.
				song.bars[song.barCount].strums.length = pos + 4
			endif
			song.bars[song.barCount].strums[pos].chordName$ = ""									// Initialise the new strum.
			song.bars[song.barCount].strums[pos].fretDesc$ = ""
			song.bars[song.barCount].strums[pos].frets.length = ctrl.strings
			for i = 1 to ctrl.strings																// Set to all no strum.
				song.bars[song.barCount].strums[pos].frets[i] = -1
			next i
			song.bars[song.barCount].strums[pos].direction = 1
			song.bars[song.barCount].strums[pos].time = beatPosition
			song.bars[song.barCount].strums[pos].volume = 100
			song.bars[song.barCount].strums[pos].displayChord = 0
		endif
		if left(line$,1) = "<"																		// Is it a chord annotation.
			line$ = mid(line$,2,len(line$)-2)														// Remove <>
			if lower(line$) = "x" then line$ = ""
			song.bars[song.barCount].strums[pos].chordName$ = Lower(line$)
			song.bars[song.barCount].strums[pos].displayChord = 1
		else																						// It must be a strum 
			if lower(mid(line$,1,1)) = "u" 															// First character is direction. If u
				song.bars[song.barCount].strums[pos].direction = -1 								// set it to -1
			endif
			line$ = mid(line$,3,len(line$)-3)														// Remove dir[]
			if left(line$,1) = "@"																	// Is there a set volume.
				i = FindString(line$,",")															// Find end of volume comma.
				song.bars[song.barCount].strums[pos].volume = val(mid(line$,2,i-2))					// Set the volume percent
				line$ = mid(line$,i+1,9999)
			endif
			
			fretDesc$ = ""																			// Copy fret data to strum and build 0232 descriptor
			for i = 1 to ctrl.strings
				fPos = Val(GetStringToken(line$,",",i))												// Get fret pos
				song.bars[song.barCount].strums[pos].frets[i] = fPos								// Save it
				fretDesc$ = fretDesc$ + str(fPos)													// Build descriptor
				if fPos > 9 then fretDesc$ = ""														// If off the end then clear it.
			next i
			if len(fretDesc$) = ctrl.strings 														// passed only if never cleared.
				song.bars[song.barCount].strums[pos].fretDesc$ = fretDesc$ 							// in which case the fret descriptor is okay.
			endif
		endif
	endif
endfunction	

// ****************************************************************************************************************************************************************
//															Convert bar to string for debugging
// ****************************************************************************************************************************************************************

function Song_BarToText(song ref as Song,n as integer)
	a$ = ""
	for i = 1 to song.bars[n].strumCount
		a$ = a$ + "@"+str(song.bars[n].strums[i].time)+":"+song.bars[n].strums[i].fretDesc$
		if song.bars[n].strums[i].chordName$ <> "" then a$ = a$ + "-"+song.bars[n].strums[i].chordName$
		if song.bars[n].strums[i].volume < 100 then a$ = a$ + ">"+str(song.bars[n].strums[i].volume)
		a$ = a$ + " "
	next i
	a$ = a$ + "'"+song.bars[n].lyric$+"'"
endfunction a$

// ****************************************************************************************************************************************************************
//												Set up the _nextChord$ fields which is used in the chord helper
// ****************************************************************************************************************************************************************

function _Song_SetupNextChord(song ref as Song)
	current$ = ""
	nextCurrent$ = ""
	for bar = song.barCount to 1 step -1 															// Work backwards through the song.
		for strum = song.bars[bar].strumCount to 1 step -1											// Work backwards through the strum.
			chord$ = lower(song.bars[bar].strums[strum].chordName$)									// Get current
			if chord$ = "x" then chord$ = ""														// Handle cancel chord.
			if chord$ <> current$ 																	// Have we reached a chord change.
				nextCurrent$ = current$ 															// Next chord becomes what this was.
				current$ = chord$
			endif
			song.bars[bar].strums[strum]._nextChord$ = nextCurrent$ 								// Set next chord
		next
	next
/*	
	for b = 1 to song.barCount
		for s = 1 to song.bars[b].strumCount
			a$ = song.bars[b].strums[s].chordName$
			debug = debug + a$ + " -> "+song.bars[b].strums[s]._nextChord$+";"
		next s
	next b
*/		
endfunction
