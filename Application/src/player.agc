// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		player.agc
//		Purpose:	Sound Player Class class
//		Date:		7th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																SoundPlayer Objects
// ****************************************************************************************************************************************************************

type Player
	isInstantiated as integer 																		// True if sound loaded
	isSoundOn as integer 																			// True if sound on.
	fretMax as integer 																				// How many frets are supported
	strings as integer 																				// Number of strings
	baseSoundID as integer[1]																		// Base sound for each string
	nextStrum as integer[1]																			// Strumming positions next strum
	nextStrumTime as integer[1]																		// Time when strum occurs
	nextVolume as integer 																			// Volume of next strum
	nextDirection as integer 																		// Direction of next strum
	lastPos# as float 																				// Time of previous update
endtype

// ****************************************************************************************************************************************************************
//																Create a player object
// ****************************************************************************************************************************************************************

function Player_New(pl ref as Player,tuning$ as string,fretMax as integer,isDiatonic as integer)
	pl.isInstantiated = 1 																			// Setup object
	pl.isSoundOn = 1
	pl.fretMax = fretMax
	pl.lastPos# = 0.0
	pl.strings = CountStringTokens(tuning$,",")														// Get number of strings
	pl.baseSoundID.length = pl.strings 																// Set up arrays
	pl.nextStrum.length = pl.strings
	pl.nextStrumTime.length = pl.strings
	currentID = ISB_PLAYERBASE																		// IDs to load.
	for i = 1 to pl.strings		
		pl.nextStrumTime[i] = 0																		// Zero all strum time		
		pl.baseSoundID[i] = currentID																// Save base ID
		note = Val(GetStringToken(tuning$,",",i))													// Get the base note.
		for j = 0 to fretMax
			LoadSound(currentID,SFXDIR+"notes/"+str(note)+".wav")									// Load in note
			inc note 																				// Next note (fix for diatonic)
			inc currentID																			// Next ID
		next j			
	next i	
endfunction

// ****************************************************************************************************************************************************************
//															Delete a player object
// ****************************************************************************************************************************************************************

function Player_Delete(pl ref as Player)
	if pl.isInstantiated <> 0
		pl.isInstantiated = 0
		for i = 1 to pl.strings																		// For each string	
			for j = 0 to pl.fretMax																	// Delete all the fret notes
				DeleteSound(pl.baseSoundID[i]+j)
			next j
		next i
	endif
endfunction

// ****************************************************************************************************************************************************************
//															  Turn sound on/off
// ****************************************************************************************************************************************************************

function Player_SetSound(pl ref as Player,isOn as integer)
	pl.isSoundOn = isOn
endfunction

// ****************************************************************************************************************************************************************
//															   Update the player
// ****************************************************************************************************************************************************************

function Player_Update(pl ref as Player,song ref as Song,pos# as float)
	if pl.isInstantiated <> 0 and pl.isSoundOn <> 0
		timeMS = GetMilliseconds()																	// Get time
		for i = 1 to pl.strings																		// For each string
			if pl.nextStrumTime[i] <> 0 and timeMS > pl.nextStrumTime[i]							// If strum pending and strum due
				pl.nextStrumTime[i] = 0																// Cancel pending
				if pl.nextStrum[i] >= 0																// If a strum
					PlaySound(pl.baseSoundID[i]+pl.nextStrum[i],pl.nextVolume)						// play it
				endif
			endif
		next i
		bar = floor(pos#)																			// This is the bar
		for s = 1 to song.bars[bar].strumCount														// For each strum in bar
			time# = bar + song.bars[bar].strums[s].time / 1000.0 									// Calculate strum time
			if pl.lastPos# < time# and pos# >= time# 												// Time to play ?
				for i = 1 to pl.strings
					pl.nextStrum[i] = song.bars[bar].strums[s].frets[i]
					pl.nextStrumTime[i] = timeMS+(i-1) * 30
					if pl.nextDirection < 0 then pl.nextStrumTime[i] = timeMS + (pl.strings-i)*30
				next i
				pl.nextVolume = song.bars[bar].strums[s].volume
				pl.nextDirection = song.bars[bar].strums[s].direction
			endif
		next s		
		pl.lastPos# = pos#																			// Save the current position as the last
	endif
	
endfunction
