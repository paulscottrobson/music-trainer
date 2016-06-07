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
	for i = 1 to pl.strings																			// Zero all strum time
		pl.nextStrumTime[i] = 0
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
	endif
endfunction
