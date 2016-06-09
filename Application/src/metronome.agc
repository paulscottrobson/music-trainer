// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		metronome.agc
//		Purpose:	Metronome class
//		Date:		7th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																Metronome Objects
// ****************************************************************************************************************************************************************

type Metronome
	isVisible as integer																			// Non zero if visible
	isTickOn as integer 																			// True if tick sfx plays
	baseID as integer																				// Base ID for sprites (2)
	x,y as integer																					// Position
	width as integer																				// Width
	depth as integer																				// Depth
	alpha# as float																					// Alpha
	lastBeat# as float 																				// Last beat position.
endtype

// ****************************************************************************************************************************************************************
//															Create a metronome object
// ****************************************************************************************************************************************************************

function Metronome_New(mt ref as Metronome,width as integer, depth as integer,baseID as integer)
	mt.isVisible = 1 																				// Setup object
	mt.isTickOn = 1
	mt.baseID = baseID
	mt.width = width
	mt.depth = depth 
	mt.alpha# = 1.0
	mt.lastBeat# = 0.0
	CreateSprite(baseID,IDMETRONOMEBODY)															// Create body
	sz# = width / GetSpriteWidth(baseID)															// Scale it
	SetSpriteScale(baseID,sz#,sz#)
	SetSpriteOffset(baseID,GetSpriteWidth(baseID)/2,GetSpriteHeight(baseID)*0.75)					// Set anchor point
	CreateSprite(baseID+1,IDMETRONOMEARM)															// Create arm
	SetSpriteScale(baseID+1,sz#,sz#)
	SetSpriteOffset(baseID+1,GetSpriteWidth(baseID+1)/2,GetSpriteHeight(baseID+1)*0.88)				// Set anchor point
endfunction

// ****************************************************************************************************************************************************************
//															Delete a metronome object
// ****************************************************************************************************************************************************************

function Metronome_Delete(mt ref as Metronome)
	if mt.isVisible <> 0
		DeleteSprite(mt.baseID)
		DeleteSprite(mt.baseID+1)
		mt.isVisible = 0
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Move a metronome object
// ****************************************************************************************************************************************************************

function Metronome_Move(mt ref as Metronome,x as integer,y as integer)
	mt.x = x
	mt.y = y
	if mt.isVisible <> 0 
		SetSpritePositionByOffset(mt.baseID,x,y)
		SetSpriteColorAlpha(mt.baseID,mt.alpha#*255)
		SetSpriteDepth(mt.baseID,mt.depth)
		SetSpritePositionByOffset(mt.baseID+1,x,y)
		SetSpriteColorAlpha(mt.baseID,mt.alpha#*255)
		SetSpriteDepth(mt.baseID+1,mt.depth-1)
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Update a metronome object
// ****************************************************************************************************************************************************************

function Metronome_Update(mt ref as Metronome,bar# as float,beats as integer)
	if mt.isVisible <> 0 and mt.isTickOn <> 0 
		beat# = bar# * beats 																		// Beat position
		bar# = bar# * beats / 2 																	// Scale up to beats (2 beats per cycle)
		bar# = bar# - floor(bar#)																	// Offset in beat 0->1
		if bar# > 0.5 then bar# = 1.0-bar# 															// Back and forth.
		SetSpriteAngle(mt.baseID+1,-45+180*bar#)													// Update the graphic

		if floor(mt.lastBeat#) <> floor(beat#) and mt.isTickOn <> 0									// New beat and sound on
			if mod(floor(beat#),beats) = 0 then vol = 100 else vol = 40								// Accentuate first beat of bar
			PlaySound(ISMETRONOME,vol)
		endif
		mt.lastBeat# = beat#	
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Turn metronome on/off
// ****************************************************************************************************************************************************************

function Metronome_SetSound(mt ref as Metronome,isOn as integer)
	mt.isTickOn = isOn
endfunction

// ****************************************************************************************************************************************************************
//															Handle clicks for metronome
// ****************************************************************************************************************************************************************

function Metronome_ClickHandler(mt ref as Metronome,ci ref as ClickInfo)
	if mt.isVisible <> 0
		if GetSpriteHitTest(mt.baseID,ci.x,ci.y) <> 0 
			mt.isTickOn = (mt.isTickOn = 0)
			PlaySound(ISPING)
		endif
	endif
endfunction

