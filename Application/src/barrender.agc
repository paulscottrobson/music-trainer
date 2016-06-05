// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		barrender.agc
//		Purpose:	Bar Rendering Class - responsible for rendering a bar on the screen
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																Bar Rendering Class
// ****************************************************************************************************************************************************************

type BarRender
	x,y as integer																					// Position of renderer
	width,height,depth as integer 																	// width and height and depth
	alpha# as float																					// Alpha setting
	baseID as integer 																				// Base ID of graphics
endtype

global _BarRenderMaxWidth as integer																// Max Width for font size given.
global _BarRenderMaxHeight as integer																// Max Height for font size given.
global _BarRenderTestFontSize as integer															// Given font size

// ****************************************************************************************************************************************************************
//																		Create Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_New(rdr ref as BarRender,bar ref as bar,width as integer,height as integer,depth as integer,baseID as integer)
	rdr.baseID = baseID 																			// Set up structure
	rdr.width = width
	rdr.height = height
	rdr.depth = depth
	rdr.alpha# = 1.0
	CreateSprite(baseID,IDRECTANGLE)																// S+0 is the background frame for debuggin
	SetSpriteSize(baseID,width,height)
	SetSpriteColor(baseID,0,0,64,64)																// Alpha does not affect this object.
	if bar.lyric$ <> ""																				// Does the bar lyric exist.
		_BarRender_CreateLyric(rdr,bar)
	endif
	
	BarRender_Move(rdr,100,100)
endfunction

// ****************************************************************************************************************************************************************
//																		Delete Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_Delete(rdr ref as BarRender)
	if GetSpriteExists(rdr.baseID) <> 0																// Check not already deleted
		DeleteSprite(rdr.baseID)
		if GetTextExists(rdr.baseID) <> 0 then DeleteText(rdr.baseID)
	endif
endfunction

// ****************************************************************************************************************************************************************
//																		  Move Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_Move(rdr ref as BarRender,x as integer,y as integer)
	rdr.x = x																						// Save new position
	rdr.y = y
	SetSpritePosition(rdr.baseID,x,y)																// +0 background
	SetSpriteDepth(rdr.baseID,rdr.depth)															// Note we don't change ALPHA here.
	
	if GetTextExists(rdr.baseID) <> 0																// Lyric T+0 may have no lyric.
		SetTextPosition(rdr.baseID,x+rdr.width/2-GetTextTotalWidth(rdr.baseID)/2,y+rdr.height-GetTextTotalHeight(rdr.baseID))
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Check to see if renderer off screen
// ****************************************************************************************************************************************************************

function BarRender_OffScreen(rdr ref as BarRender)
	isOff = (GetSpriteX(rdr.baseID) > ctrl.scWidth) or (GetSpriteX(rdr.baseID)+rdr.width < 0)		// Check off RHS and LHS using the bounding box.
endfunction

// ****************************************************************************************************************************************************************
//																	Create the lyric
// ****************************************************************************************************************************************************************

function _BarRender_CreateLyric(rdr ref as BarRender,bar ref as Bar)
	sx# = (rdr.width+0.0) / _BarRenderMaxWidth														// Work out scale for this size.
	sy# = rdr.height * (100-PCSTRINGS) / 100.0 / _BarRenderMaxHeight
	//debug = debug + str(sx#)+" " +str(sy#)+";"
	if sx# > sy# then sx# = sy#																		// sx# is now smappest
	CreateText(rdr.baseID,bar.lyric$)																// Create text object
	SetTextSize(rdr.baseID,_BarRenderTestFontSize * sx#)											// Set the text size according to the scale
	// TODO: % pad it out.
endfunction

// ****************************************************************************************************************************************************************
//							Static method that measures all the lyrics at a given font size to see how big the biggest is
// ****************************************************************************************************************************************************************

function BarRender_ProcessSongLyrics(song ref as Song)
	CreateText(IDTEMP,"")																			// Create a text to measure
	_BarRenderMaxWidth = 0
	_BarRenderMaxHeight = 0
	_BarRenderTestFontSize = 40																		// Measure using this font.
	SetTextSize(IDTEMP,_BarRenderTestFontSize)
	for i = 1 to song.barCount																		// Work through each lyric finding out how big it is.
		if song.bars[i].lyric$ <> ""
			SetTextString(IDTEMP,song.bars[i].lyric$)												// And pick the largest values.
			if GetTextTotalWidth(IDTEMP) > _BarRenderMaxWidth then _BarRenderMaxWidth = GetTextTotalWidth(IDTEMP)
			if GetTextTotalHeight(IDTEMP) > _BarRenderMaxHeight then _BarRenderMaxHeight = GetTextTotalHeight(IDTEMP)
		endif
	next i
	DeleteText(IDTEMP)																				// Throw away the working text
	//debug = debug + str(_BarRenderMaxWidth)+" x "+str(_BarRenderMaxHeight)
endfunction
