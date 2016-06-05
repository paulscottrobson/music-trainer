// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chordbucket.agc
//		Purpose:	Chord Bucket class, object which is all the chords in a song.
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Chord Bucket type
// ****************************************************************************************************************************************************************

type _Chord
	name$ as string
	fret$ as string
endtype

type ChordBucket
	chordCount as integer
	display as ChordDisplay[1]
	chords as _Chord[1]
endtype

// ****************************************************************************************************************************************************************
//																	Create chordbucket object
// ****************************************************************************************************************************************************************

function ChordBucket_New(cb ref as ChordBucket)
	cb.chordCount = 0
	cb.display.length = 0
	cb.chords.length = 0	
endfunction

// ****************************************************************************************************************************************************************
//																	Erase chordbucket object
// ****************************************************************************************************************************************************************

function ChordBucket_Clear(cb ref as ChordBucket)
	for i = 1 to cb.chordCount
		ChordDisplay_Delete(cb.display[i])
	next i
	cb.chordCount = 0
	cb.display.length = 0
	cb.chords.length = 0	
endfunction

// ****************************************************************************************************************************************************************
//																Destroy ChordBucket Object
// ****************************************************************************************************************************************************************

function ChordBucket_Delete(cb ref as ChordBucket)
	ChordBucket_Clear(cb)
endfunction

// ****************************************************************************************************************************************************************
//																Load Song into ChordBucket
// ****************************************************************************************************************************************************************

function ChordBucket_Load(cb ref as ChordBucket,song ref as song,width as integer,height as integer)
	ChordBucket_Clear(cb)																			// Clear chord array.
	for bar = 1 to song.barCount																	// Work through bars and strums
		for strum = 1 to song.bars[bar].strumCount
			chord$ = song.bars[bar].strums[strum].chordName$										// Get chord name
			fret$ = song.bars[bar].strums[strum].fretDesc$											// And fret descriptor
			if chord$ <> "" and fret$ <> "" and cb.chords.find(chord$) < 0							// If legit not found
				inc cb.chordCount																	// Add to the array
				cb.chords.length = cb.chordCount 								
				cb.chords[cb.chordCount].name$ = chord$
				cb.chords[cb.chordCount].fret$ = fret$
				cb.chords.sort()																	// Keep array in order.
			endif
		next strum
	next bar
	cb.display.length = cb.chordCount 																// Set display object size and create them.
	for c = 1 to cb.chordCount
		//debug = debug + cb.chords[c].name$+" "+cb.chords[c].fret$+";"
		ChordDisplay_New(cb.display[c],cb.chords[c].name$,cb.chords[c].fret$,IDB_CHORDBUCKET+c*50,width,height)
		ChordDisplay_Move(cb.display[c],-1000,-1000)												// Move it off screen
	next c
endfunction

// ****************************************************************************************************************************************************************
//															Find chord by name
// ****************************************************************************************************************************************************************

function ChordBucket_Find(cb ref as ChordBucket,chord$ as string)
	pos = 0
	chord$ = Lower(chord$)
	for i = 1 to cb.chordCount
		if cb.chords[i].name$ = chord$ then pos = i
	next i
endfunction pos

// ****************************************************************************************************************************************************************
//															Move specified chord
// ****************************************************************************************************************************************************************

function ChordBucket_Move(cb ref as ChordBucket,id as integer,x as integer,y as integer)
	if id > 0 then ChordDisplay_Move(cb.display[id],x,y)
endfunction

// ****************************************************************************************************************************************************************
//																Set Alpha specified chord
// ****************************************************************************************************************************************************************

function ChordBucket_SetAlpha(cb ref as ChordBucket,id as integer,alpha# as float)
	if id > 0 
		cb.display[id].alpha# = alpha#
		ChordDisplay_Move(cb.display[id],cb.display[id].x,cb.display[id].y)
	endif
endfunction
