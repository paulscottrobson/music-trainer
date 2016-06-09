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
	overridePos# as Float 																			// Override position with this.
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
	po.overridePos# = -1 																			// No override
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
	if po.isInitialised <> 0																		// If intialised
		if po.overridePos# >= 0																		// If set by drag/click use that
			pos# = po.overridePos#
			po.overridePos# = -1
		endif
		if pos# >= po.pos#[PO_RIGHT] 																// Limit at RHS, if RHS at end stop else back to left
			if po.pos#[PO_RIGHT] <> po.barCount+1 then pos# = po.pos#[PO_LEFT] else pos# = po.barCount+1
		endif
		po.pos#[PO_POS] = pos#																		// Update position and the sprites
		for i = 1 to 3
			x = po.x + po.width * po.pos#[i] / (po.barCount+1)
			SetSpritePositionByOffset(po.baseID+i,x,po.y)
		next i
	endif
endfunction pos#

// ****************************************************************************************************************************************************************
//															  Handle Clicks (and drags)
// ****************************************************************************************************************************************************************

function Position_ClickHandler(po ref as Positioner,rm ref as RenderManager,song ref as Song,ci ref as ClickInfo)
	if po.isInitialised <> 0																		// If initialised and clicked
		bRadius = GetSpriteWidth(po.baseID+1)/2
		if ci.x >= po.x-bRadius and ci.x <= po.x+po.width+bRadius and ci.y >= po.y-po.height/2 and ci.y <= po.y+po.height/2 		
			hitTest = 0																				// Hit one of the circles
			for i = 1 to 3 
				if GetSpriteHitTest(po.baseID+i,ci.x,ci.y) <> 0 and hitTest <> 2 then hitTest = i
			next i
			if hitTest = 0 																			// Not hit a circle, just move
				pos# = (ci.x - po.x)  * (po.barCount+1.0) / po.width
				po.overridePos# = pos#
				PlaySound(ISPING)
			else
				min# = 0.0																			// Range allowed
				max# = po.barCount+1.0
				if hitTest = PO_LEFT then max# = po.pos#[PO_RIGHT]									// Stops min/max being swapped
				if hitTest = PO_RIGHT then min# = po.pos#[PO_LEFT]
				while GetPointerState() <> 0														// Wait for release
					pos# = (GetPointerX() - po.x)  * (po.barCount+1.0) / po.width					// Calc new position
					if pos# < min# then pos# = min#													// Put in range
					if pos# > max# then pos# = max#
					po.pos#[hitTest] = pos#															// Save value
					x = po.x + po.width * po.pos#[hitTest] / (po.barCount+1)						// Move ball sprite
					SetSpritePositionByOffset(po.baseID+hitTest,x,po.y)		
					if hitTest = PO_POS																// If position
						po.overridePos# = pos#														// Will be the new position
						RenderManager_MoveScroll(rm,song,pos#)										// Scroll image to suit
					endif			
					Sync()																			// Update display
				endwhile																			
				PlaySound(ISPING)
			endif
		endif
	endif
endfunction

