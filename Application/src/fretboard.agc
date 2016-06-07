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
endtype

// ****************************************************************************************************************************************************************
//															 	Create a fretboard
// ****************************************************************************************************************************************************************

function Fretboard_New(fb ref as Fretboard,height as integer,depth as integer, strings as integer)
	fb.isVisible = 1
	fb.y = 0
	fb.height = height
	fb.depth = depth 
	fb.alpha# = 1.0
	fb.strings = strings
	CreateSprite(IDB_FRETBOARD,IDFRETBOARD)
	SetSpriteSize(IDB_FRETBOARD,ctrl.scWidth,height*1.25*PCSTRINGS/100)	
	for i = 1 to strings
		CreateSprite(IDB_FRETBOARD+i,IDSTRING)
		sz# = ctrl.scWidth / GetSpriteWidth(IDB_FRETBOARD+i)
		SetSpriteScale(IDB_FRETBOARD+i,sz#,sz#/2.0)
	next i
endfunction

// ****************************************************************************************************************************************************************
//																	Delete a fretboard
// ****************************************************************************************************************************************************************

function Fretboard_Delete(fb ref as Fretboard)
	if fb.isVisible <> 0
		DeleteSprite(IDB_FRETBOARD)
		for i = 1 to fb.strings
			DeleteSprite(IDB_FRETBOARD+i)
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
		SetSpritePosition(IDB_FRETBOARD,0,y-GetSpriteHeight(IDB_FRETBOARD)/10)
		SetSpriteDepth(IDB_FRETBOARD,fb.depth)
		SetSpriteColorAlpha(IDB_FRETBOARD,alpha)
		for i = 1 to fb.strings
			SetSpritePosition(IDB_FRETBOARD+i,0,fb.y + fb.height * PCSTRINGS / 100.0 * (i - 0.5) / fb.strings)
			SetSpriteDepth(IDB_FRETBOARD+i,fb.depth-1)
			SetSpriteColorAlpha(IDB_FRETBOARD+i,alpha)
		next i
	endif
endfunction

