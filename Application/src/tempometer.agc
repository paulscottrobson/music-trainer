// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		tempometer.agc
//		Purpose:	Tempo Meter/Controller class
//		Date:		7th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																TempoMeter Objects
// ****************************************************************************************************************************************************************

type TempoMeter
	isVisible as integer																			// Non zero if visible
	isPaused as integer 																			// True if paused
	tempoPos# as float 																				// Position of tempo meter -TEMPO_MAX .. TEMPO_MAX
	baseID as integer																				// Base ID for sprites (2)
	x,y as integer																					// Position
	width as integer																				// Width
	depth as integer																				// Depth
	alpha# as float																					// Alpha
endtype

#constant TEMPO_MAX		7
#constant TEMPO_ANGLE 	112.5

// ****************************************************************************************************************************************************************
//															Create a tempometer object
// ****************************************************************************************************************************************************************

function TempoMeter_New(tm ref as TempoMeter,width as integer, depth as integer,baseID as integer)
	tm.isVisible = 1 																				// Setup object
	tm.baseID = baseID
	tm.width = width
	tm.depth = depth 
	tm.alpha# = 1.0
	tm.isPaused = 0
	tm.tempoPos# = 0.0
	CreateSprite(tm.baseID,IDMETER)																	// Create body
	sz# = (width+0.0) / GetSpriteWidth(tm.baseID) 
	SetSpriteScale(tm.baseID,sz#,sz#)
	SetSpriteOffset(tm.baseID,GetSpriteWidth(tm.baseID)*0.5,GetSpriteHeight(tm.baseID)*0.43)
	CreateSprite(tm.baseID+1,IDMETERNEEDLE)															// Create needle
	SetSpriteScale(tm.baseID+1,sz#,sz#)
	SetSpriteOffset(tm.baseID+1,GetSpriteWidth(tm.baseID+1)*0.5,GetSpriteHeight(tm.baseID+1)*0.80)
	SetSpriteAngle(tm.baseID+1,0)
endfunction

// ****************************************************************************************************************************************************************
//															Delete a tempometer object
// ****************************************************************************************************************************************************************

function TempoMeter_Delete(tm ref as TempoMeter)
	if tm.isVisible <> 0
		tm.isVisible = 0
		DeleteSprite(tm.baseID)
		DeleteSprite(tm.baseID+1)
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Move a tempometer object
// ****************************************************************************************************************************************************************

function TempoMeter_Move(tm ref as TempoMeter,x as integer,y as integer)
	tm.x = x
	tm.y = y
	if tm.isVisible <> 0 
		alpha = tm.alpha# * 255
		SetSpritePositionByOffset(tm.baseID,x,y)
		SetSpriteColorAlpha(tm.baseID,alpha)
		SetSpriteDepth(tm.baseID,tm.depth)
		SetSpritePositionByOffset(tm.baseID+1,x,y)
		SetSpriteColorAlpha(tm.baseID+1,alpha)
		SetSpriteDepth(tm.baseID+1,tm.depth-1)
	endif
endfunction

// ****************************************************************************************************************************************************************
//															Handle clicks for tempometer
// ****************************************************************************************************************************************************************

function TempoMeter_ClickHandler(tm ref as TempoMeter,ci ref as ClickInfo)
	if tm.isVisible <> 0 
		if GetSpriteHitTest(IDB_METER,ci.x,ci.y) <> 0 or (FindString("PFSR",ci.key$) > 0 and ci.key$ <> "")
			bottomZone = ci.y > GetSpriteY(IDB_METER) + GetSpriteHeight(IDB_METER)*0.55
			if bottomZone <> 0 or ci.key$ = "S" or ci.key$ = "F" or ci.key$ = "R"
				dir = 1																				// Which way/
				if ci.x < GetSpriteX(IDB_METER)+GetSpriteWidth(IDB_METER)/2 then dir = -1
				if ci.key$ = "S" then dir = -1														// Keyboard
				if ci.key$ = "F" then dir = 1
				tm.tempoPos# = tm.tempoPos# + dir 													// Adjust position.
				if ci.key$ = "R" then tm.tempoPos# = 0
				if abs(tm.tempoPos#) > TEMPO_MAX then tm.tempoPos# = TEMPO_MAX * dir 				// Max out
				SetSpriteAngle(IDB_METER+1,TEMPO_ANGLE * tm.tempoPos# / TEMPO_MAX)					// Set the angle
			else
				PlaySound(ISPING)
				tm.isPaused = (tm.isPaused = 0)
				if tm.isPaused
					SetSpriteColor(IDB_METER,255,64,64,255)
				else
					SetSpriteColor(IDB_METER,255,255,255,255)
				endif
			endif
		endif
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Scale a positional offset
// ****************************************************************************************************************************************************************

function TempoMeter_ScalePositionAdjustment(tm ref as TempoMeter,offset# as float)
	move# = 0.0																						// result adjustment
	if tm.isPaused = 0 																				// if not paused
		move# = offset# + offset# * tm.tempoPos# / 10.0												// Adjust by 10% of adjustment for evert tempo position
	endif
endfunction move#
