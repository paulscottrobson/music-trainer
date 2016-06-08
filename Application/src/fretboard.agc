// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		fretboard.agc
//		Purpose:	Fretboard class (background)
//		Date:		7th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																Bar Rendering Class
// ****************************************************************************************************************************************************************

type Fretboard
	isVisible as integer
	y as integer
	height as integer
	depth as integer
	alpha# as float
	strings as integer
	baseID as integer
endtype

// ****************************************************************************************************************************************************************
//															 	Create a fretboard
// ****************************************************************************************************************************************************************

function Fretboard_New(fb ref as Fretboard,height as integer,depth as integer, strings as integer,baseID as integer)
	fb.isVisible = 1
	fb.y = 0
	fb.height = height
	fb.depth = depth 
	fb.alpha# = 1.0
	fb.strings = strings
	fb.baseID = baseID
	CreateSprite(fb.baseID,IDFRETBOARD)
	SetSpriteSize(fb.baseID,ctrl.scWidth,height*1.25*PCSTRINGS/100)	
	for i = 1 to strings
		CreateSprite(fb.baseID+i,IDSTRING)
		sz# = ctrl.scWidth / GetSpriteWidth(fb.baseID+i)
		SetSpriteScale(fb.baseID+i,sz#,sz#/2.0)
	next i
endfunction

// ****************************************************************************************************************************************************************
//																	Delete a fretboard
// ****************************************************************************************************************************************************************

function Fretboard_Delete(fb ref as Fretboard)
	if fb.isVisible <> 0
		DeleteSprite(fb.baseID)
		for i = 1 to fb.strings
			DeleteSprite(fb.baseID+i)
		next i
		fb.isVisible = 0
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move a fretboard
// ****************************************************************************************************************************************************************

function Fretboard_Move(fb ref as Fretboard,y as integer)
	fb.y = y
	alpha = fb.alpha# * 255
	if fb.isVisible <> 0
		SetSpritePosition(fb.baseID,0,y-GetSpriteHeight(fb.baseID)/10)
		SetSpriteDepth(fb.baseID,fb.depth)
		SetSpriteColorAlpha(fb.baseID,alpha)
		for i = 1 to fb.strings
			SetSpritePosition(fb.baseID+i,0,fb.y + fb.height * PCSTRINGS / 100.0 * (i - 0.5) / fb.strings)
			SetSpriteDepth(fb.baseID+i,fb.depth-1)
			SetSpriteColorAlpha(fb.baseID+i,alpha)
		next i
	endif
endfunction

