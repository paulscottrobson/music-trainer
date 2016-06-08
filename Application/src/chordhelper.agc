// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chordhelper.agc
//		Purpose:	Manages the Chord Helper
//		Date:		8th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

type ChordHelper
	isInitialised as integer																		// Non zero when iniialised
	x,y,depth as integer																			// Basic positional stuff
	cWidth,cHeight as integer																		// Size of individual chords, not the whole area
	bucket as ChordBucket																			// Bucket containing chords
	currentChord$ as string 																		// Current chord
	lastPos# as float 																				// Last position checked.
	spacing as integer 																				// Horizontal gap between chords
	chords as integer[2]																			// ID of chords in current/next/previous
	startTime,endTime as integer 																	// ms surrounding fade in/out move etc.
	baseID as integer 																				// base ID
endtype

// ****************************************************************************************************************************************************************
//																	Create new Chord Helper
// ****************************************************************************************************************************************************************

function ChordHelper_New(ch ref as ChordHelper,song ref as Song,cWidth as integer,cHeight as integer,depth as integer,baseID as integer)
	ch.isInitialised = 1																			// Mark initialised
	ch.depth = depth 																				// Save values
	ch.cWidth = cWidth
	ch.cHeight = cHeight
	ch.currentChord$ = "???" 																		// Forces change on any chord
	ch.lastPos# = 0.0 																				
	ch.spacing = cWidth / 10
	ch.chords[1] = 0
	ch.chords[2] = 0
	ch.startTime = GetMilliseconds()+99999999 														// Long way into future.
	ch.baseID = baseID
	ChordBucket_New(ch.bucket,ch.baseID)															// Create a bucket
	ChordBucket_Load(ch.bucket,song,cWidth,cHeight,depth)											// Load a song into it	
	firstChord$ = "" 																				// Get the first chord.
	for b = 1 to song.barCount
		for s = 1 to song.bars[b].strumCount 
			if firstChord$="" and song.bars[b].strums[s].chordName$ <> ""
				firstChord$ = song.bars[b].strums[s].chordName$
			endif
		next s
	next b
	
	id = ChordBucket_Find(ch.bucket,firstChord$)													// Set up as first chord.
	if id > 0 then _ChordHelper_ChangeDisplay(ch,0,id)
endfunction

// ****************************************************************************************************************************************************************
//																	Delete the Chord Helper
// ****************************************************************************************************************************************************************

function ChordHelper_Delete(ch ref as ChordHelper)
	if ch.isInitialised <> 0
		ch.isInitialised = 0
		ChordBucket_Delete(ch.bucket)																// Deleting the bucket object deletes all the graphics
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move the chord Helper
// ****************************************************************************************************************************************************************

function ChordHelper_Move(ch ref as ChordHelper,x as integer,y as integer)
	if ch.isInitialised <> 0
		if ch.chords[1] <> 0 
			xOffset = ch.bucket.display[ch.chords[1]].x - ch.x
			ChordBucket_Move(ch.bucket,ch.chords[2],x+xOffset,y)
		endif
		if ch.chords[2] <> 0 then ChordBucket_Move(ch.bucket,ch.chords[2],x+ch.cWidth+ch.spacing,y)
		ch.x = x																					// Update position
		ch.y = y
	endif
endfunction

// ****************************************************************************************************************************************************************
//															   Update the Helper
// ****************************************************************************************************************************************************************

function ChordHelper_Update(ch ref as ChordHelper,song ref as Song,pos# as float)
	if ch.isInitialised <> 0
		bar = floor(pos#)																			// This is the bar
		if abs(ch.lastPos# - pos#) > 0.5 then ch.currentChord$ = "????"								// Forces a redraw for a serious move
		for s = 1 to song.bars[bar].strumCount														// For each strum in bar
			time# = bar + song.bars[bar].strums[s].time / 1000.0 									// Calculate strum time
			if ch.lastPos# < time# and pos# >= time# 												// Time to play ?
				chord$ = song.bars[bar].strums[s].chordName$
				if chord$ <> ch.currentChord$ 														// Chord changed ?
					ch.currentChord$ = chord$ 
					chordID = ChordBucket_Find(ch.bucket,chord$)
					nextChordID = ChordBucket_Find(ch.bucket,song.bars[bar].strums[s]._nextChord$)
					_ChordHelper_ChangeDisplay(ch,chordID,nextChordID)								// Change the display
					//debug = debug + chord$ + " " + song.bars[bar].strums[s]._nextChord$+ " "+str(chordID)+" "+str(nextChordID)+";"
				endif
			endif
		next s		
		ch.lastPos# = pos#																			// Save last position.
		time = GetMilliseconds()																	// Get time
		if time > ch.startTime 
			pos# = (time-ch.startTime+0.0) / (ch.endTime-ch.startTime)								// Work out position as 0->1
			if time >= ch.endTime																	// Past the end.
				pos# = 1.0																			// Final position.
				ch.startTime = GetMilliseconds()+9999999											// Move start way into the future
			endif
			if ch.chords[1] <> 0 then ChordBucket_Move(ch.bucket,ch.chords[1],ch.x+(1-pos#)*(ch.cWidth+ch.spacing),ch.y)			
			if ch.chords[2] <> 0 then ChordBucket_SetAlpha(ch.bucket,ch.chords[2],pos#)
		endif
	endif

endfunction

// ****************************************************************************************************************************************************************
//								Update the displayed chords
// ****************************************************************************************************************************************************************

function _ChordHelper_ChangeDisplay(ch ref as ChordHelper,chordID as integer,nextChordID as integer)
	for i = 1 to 2
		if ch.chords[i] > 0 then ChordBucket_Move(ch.bucket,ch.chords[i],-1000,-1000)
	next i
	ch.chords[1] = chordID
	ch.chords[2] = nextChordID
	ch.startTime = GetMilliseconds()
	ch.endTime = GetMilliseconds()+300
	ChordBucket_Move(ch.bucket,ch.chords[1],ch.x,ch.y)
	if ch.chords[2] <> 0 then ChordBucket_Move(ch.bucket,ch.chords[2],ch.x+ch.cWidth+ch.spacing,ch.y)
	for i = 1 to 2
		if ch.chords[i] <> 0 then ChordBucket_SetAlpha(ch.bucket,ch.chords[i],1.0)
	next i
endfunction
