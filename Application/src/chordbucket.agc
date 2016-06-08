// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chordbucket.agc
//		Purpose:	Chord Bucket class, object which is all the display objects for a chord in a song.
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
	isInitialised as integer 																		// Non zero if initialised
	chordCount as integer																			// Cords in bucket
	display as ChordDisplay[1]																		// Display element for chords
	chords as _Chord[1]																				// Chord Info
	baseID as integer																				// Base GFX ID
endtype

// ****************************************************************************************************************************************************************
//																	Create chordbucket object
// ****************************************************************************************************************************************************************

function ChordBucket_New(cb ref as ChordBucket,baseID as integer)
	cb.isInitialised = 1
	cb.chordCount = 0
	cb.display.length = 0
	cb.chords.length = 0	
	cb.baseID = baseID
endfunction

// ****************************************************************************************************************************************************************
//																	Erase chordbucket object
// ****************************************************************************************************************************************************************

function ChordBucket_Clear(cb ref as ChordBucket)
	if cb.isInitialised <> 0
		for i = 1 to cb.chordCount
			ChordDisplay_Delete(cb.display[i])
		next i
		cb.chordCount = 0
		cb.display.length = 0
		cb.chords.length = 0	
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Destroy ChordBucket Object
// ****************************************************************************************************************************************************************

function ChordBucket_Delete(cb ref as ChordBucket)
	if cb.isInitialised <> 0 then ChordBucket_Clear(cb)
	cb.isInitialised = 0
endfunction

// ****************************************************************************************************************************************************************
//																Load Song into ChordBucket
// ****************************************************************************************************************************************************************

function ChordBucket_Load(cb ref as ChordBucket,song ref as song,width as integer,height as integer,depth as integer)
	ASSERT(cb.isInitialised <> 0,"CBLA")
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
		ChordDisplay_New(cb.display[c],cb.chords[c].name$,cb.chords[c].fret$,cb.baseID+c*50,width,height,depth)
		ChordDisplay_Move(cb.display[c],-1000,-1000)												// Move it off screen
	next c
endfunction

// ****************************************************************************************************************************************************************
//															Find chord by name
// ****************************************************************************************************************************************************************

function ChordBucket_Find(cb ref as ChordBucket,chord$ as string)
	ASSERT(cb.isInitialised <> 0,"CBLF")
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
	ASSERT(cb.isInitialised <> 0,"CBLM")
	if id > 0 then ChordDisplay_Move(cb.display[id],x,y)
endfunction

// ****************************************************************************************************************************************************************
//																Set Alpha specified chord
// ****************************************************************************************************************************************************************

function ChordBucket_SetAlpha(cb ref as ChordBucket,id as integer,alpha# as float)
	ASSERT(cb.isInitialised <> 0,"CBLSA")
	if id > 0 
		cb.display[id].alpha# = alpha#
		ChordDisplay_Move(cb.display[id],cb.display[id].x,cb.display[id].y)
	endif
endfunction
