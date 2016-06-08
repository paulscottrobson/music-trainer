// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		positioner.agc
//		Purpose:	Positoner bar
//		Date:		8th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

type Positioner
	isInitialised as integer																		// Non zero when iniialised
	x,y,width,height,depth as integer																// Basic positional stuff
	alpha# as Float
	songStart#,songEnd# as float 																	// Song positions
	barCount as integer 																			// Number of bars
	baseID as integer 																				// Base ID
endtype

// ****************************************************************************************************************************************************************
//																	Create new Positioner
// ****************************************************************************************************************************************************************

function Positioner_New(po ref as Positioner,song ref as Song,width as integer,height as integer,depth as integer,baseID as integer)
	po.isInitialised = 1																			// Mark initialised
	po.width = width 																				// Set up
	po.height = height
	po.depth = depth 
	po.songStart# = 0.0
	po.songEnd# = song.barCount+1.0
	po.barCount = song.barCount
	po.baseID = baseID
	po.alpha# = 1.0
	Positioner_Move(po,100,100)
endfunction

// ****************************************************************************************************************************************************************
//																	Delete the Positioner
// ****************************************************************************************************************************************************************

function Positioner_Delete(po ref as Positioner)
	if po.isInitialised <> 0
		po.isInitialised = 0
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move the chord Helper
// ****************************************************************************************************************************************************************

function Positioner_Move(po ref as Positioner,x as integer,y as integer)
	if po.isInitialised <> 0
		po.x = x																					// Update position
		po.y = y
	endif
endfunction

// ****************************************************************************************************************************************************************
//															   Update the Helper
// ****************************************************************************************************************************************************************

function Positioner_Update(po ref as Positioner,pos# as float)
	if po.isInitialised <> 0
	endif
endfunction

