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
	pos# as Float[3]																				// Positions of the 'balls'
	barCount as integer 																			// Number of bars
	baseID as integer 																				// Base ID
endtype

#constant PO_LEFT 	1																				// The three ball markers
#constant PO_POS 	2
#constant PO_RIGHT	3

// ****************************************************************************************************************************************************************
//																	Create new Positioner
// ****************************************************************************************************************************************************************

function Positioner_New(po ref as Positioner,song ref as Song,width as integer,height as integer,depth as integer,baseID as integer)
	po.isInitialised = 1																			// Mark initialised
	po.width = width 																				// Set up
	po.height = height
	po.depth = depth 
	po.pos#[PO_LEFT] = 0.0
	po.pos#[PO_POS] = 0.0
	po.pos#[PO_RIGHT] = song.barCount + 1.0
	po.barCount = song.barCount
	po.baseID = baseID
	po.alpha# = 1.0
	Positioner_Move(po,-1,100)
	CreateSprite(po.baseID,IDSTRING)																// Use the string.
	SetSpriteSize(po.baseID,po.width,GetSpriteHeight(po.baseID))
	
	CreateSprite(po.baseID+1,IDBLUECIRCLE)															// S+1 is the start marker.
	CreateSprite(po.baseID+2,IDYELLOWCIRCLE)														// S+2 is the moving circle
	CreateSprite(po.baseID+3,IDBLUECIRCLE)															// S+3 is the end marker
	
	for i = 1 to 3
		sz# = height / GetSpriteHeight(po.baseID+i)
		if i = 2 then sz# = sz# * 0.75
		SetSpriteScale(po.baseID+i,sz#,sz#)
	next i
endfunction

// ****************************************************************************************************************************************************************
//																	Delete the Positioner
// ****************************************************************************************************************************************************************

function Positioner_Delete(po ref as Positioner)
	if po.isInitialised <> 0
		po.isInitialised = 0
		DeleteSprite(po.baseID)
		for i = 1 to 3
			DeleteSprite(po.baseID+i)
		next i
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move the chord Helper
// ****************************************************************************************************************************************************************

function Positioner_Move(po ref as Positioner,x as integer,y as integer)
	if po.isInitialised <> 0
		alpha = po.alpha# * 255
		if x < 0 then x = ctrl.scWidth/2 - po.width/2
		po.x = x																					// Update position
		po.y = y
		SetSpritePosition(po.baseID,x,y-GetSpriteHeight(po.baseID)/2)								// Update the bar
		SetSpriteColorAlpha(po.baseID,alpha)
		SetSpriteDepth(po.baseID,po.depth)
		for i = 1 to 3
			SetSpriteColorAlpha(po.baseID+i,alpha)
			if i <> 2 then depth = po.depth-1 else depth = po.depth-2
			SetSpriteDepth(po.baseID+i,depth)
		next i
		Positioner_Update(po,0.0)																	// Reposition
	endif
endfunction

// ****************************************************************************************************************************************************************
//															   Update the Helper
// ****************************************************************************************************************************************************************

function Positioner_Update(po ref as Positioner,pos# as float)
	if po.isInitialised <> 0
		if pos# > po.pos#[PO_RIGHT] then pos# = po.pos#[PO_LEFT]
		po.pos#[PO_POS] = pos#
		for i = 1 to 3
			x = po.x + po.width * po.pos#[i] / (po.barCount+1)
			SetSpritePositionByOffset(po.baseID+i,x,po.y)
		next i
	endif
endfunction pos#

