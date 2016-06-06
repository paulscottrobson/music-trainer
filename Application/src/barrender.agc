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
	positions as integer[1]																			// Positions of strums
	stringCount as integer
endtype

global _BarRenderMaxWidth as integer																// Max Width for font size given.
global _BarRenderMaxHeight as integer																// Max Height for font size given.
global _BarRenderTestFontSize as integer															// Given font size
global _BarRender_ChordList$ as string 																// List of known chords

// ****************************************************************************************************************************************************************
//																		Create Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_New(rdr ref as BarRender,bar ref as bar,width as integer,height as integer,depth as integer,baseID as integer)
	rdr.baseID = baseID 																			// Set up structure
	rdr.width = width
	rdr.height = height
	rdr.depth = depth
	rdr.alpha# = 1.0
	rdr.positions.length = bar.strumCount
	rdr.stringCount = 0
	CreateSprite(baseID,IDRECTANGLE)																// S+0 is the background frame for debuggin
	SetSpriteSize(baseID,width,height)
	SetSpriteColor(baseID,Random(40,180),Random(40,180),Random(40,180),80)							// Alpha does not affect this object. Random helps adjacent stand out.
	if bar.lyric$ <> ""																				// Does the bar lyric exist.
		_BarRender_CreateLyric(rdr,bar)																// The Lyric is T+0
	endif
	for i = 1 to bar.strumCount 																	// Look at all the strums
		rdr.positions[i] = bar.strums[i].time														// Save the position
		if bar.strums[i].chordName$ <> ""															// Is it a chord
			_BarRender_CreateChord(rdr,bar,bar.strums[i],rdr.baseID+i+10)							// S+strum T+strum is are the ids used.
		else
			rdr.stringCount = bar.strums[i].frets.length
			for s = 1 to bar.strums[i].frets.length 												// For each fret
				fret = bar.strums[i].frets[s]
				if fret >= 0																		// If there render it using S/T = strum x 20 + string
					_BarRender_CreatePick(rdr,bar.strums[i].time,fret,s,bar.strums[i].frets.length,rdr.baseID+i * 20 + s)
				endif
			next s
		endif
	next i
	CreateSprite(baseID+1,IDFRET)																	// S+1 is the fret
	scale# = height * PCSTRINGS / 100.0 / GetSpriteHeight(baseID+1)
	SetSpriteScale(baseID+1,scale#,scale#)

	BarRender_Move(rdr,100,100)																		// Move to an arbitrary position so it is drawn and positioned.
endfunction

// ****************************************************************************************************************************************************************
//																		Delete Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_Delete(rdr ref as BarRender)
	if GetSpriteExists(rdr.baseID) <> 0																// Check not already deleted
		DeleteSprite(rdr.baseID)																	// S+0
		if GetTextExists(rdr.baseID) <> 0 then DeleteText(rdr.baseID)								// T+0 if exists
		
		DeleteSprite(rdr.baseID+1)																	// S+1
		
		for i = 1 to rdr.positions.length 															// Look at all the strums
			if GetSpriteExists(rdr.baseID+i+10) <> 0												// Is it a chord (e.g. S+10 exists)
				DeleteSprite(rdr.baseID+i+10)														// Delete S/T + strum
				DeleteText(rdr.baseID+i+10)		
			else
				for s = 1 to rdr.stringCount 														// For each string
					n = rdr.baseID+i * 20 + s
					if GetSpriteExists(n) <> 0														// If it was created, delete it.
						DeleteSprite(n)
						DeleteText(n)
					endif
				next s
			endif
		next i
	endif
endfunction

// ****************************************************************************************************************************************************************
//																		  Move Bar Renderer
// ****************************************************************************************************************************************************************

function BarRender_Move(rdr ref as BarRender,x as integer,y as integer)
	rdr.x = x																						// Save new position
	rdr.y = y
	alpha = rdr.alpha# * 255 																		// Calculate actual alpha value
	SetSpritePosition(rdr.baseID,x,y)																// S+0 background
	SetSpriteDepth(rdr.baseID,rdr.depth)															// Note we don't change ALPHA here.
	
	if GetTextExists(rdr.baseID) <> 0																// Lyric T+0 may have no lyric.
		SetTextPosition(rdr.baseID,x+rdr.width/2-GetTextTotalWidth(rdr.baseID)/2,y+rdr.height-GetTextTotalHeight(rdr.baseID))
		SetTextDepth(rdr.baseID,rdr.depth-1)
		SetTextColorAlpha(rdr.baseID,alpha)
	endif
	
	SetSpritePosition(rdr.baseID+1,x-GetSpriteWidth(rdr.baseID+1)/2,y)								// S+1 fret marker
	SetSpriteDepth(rdr.baseID+1,rdr.depth-1)
	SetSpriteColorAlpha(rdr.baseID+1,alpha)
	
	for i = 1 to rdr.positions.length 																// Look at all the strums
		xPos = x + rdr.width * rdr.positions[i] / 1000 												// Calculate x position
		if GetSpriteExists(rdr.baseID+i+10) <> 0													// Is it a chord (e.g. S+10 exists)
			_BarRender_MoveChord(rdr,xPos,y,rdr.baseID+i+10)
		else
			for s = 1 to rdr.stringCount 															// For each string
				n = rdr.baseID+i * 20 + s
				if GetSpriteExists(n) <> 0														// If it was created, delete it.
					// TODO:Move the sprite/text pair (this is a fingerpick marker)
				endif
			next s
		endif
	next i
	
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
	
	lyric$ = bar.lyric$																				// Get lyric
	if FindString(lyric$,"%") = 0 then lyric$ = ReplaceString(lyric$," ","%",9999)					// If no stretch point given, make them all stretch points
	if FindString(lyric$,"%") = 0 then lyric$ = lyric$ + "%" 										// If no spaces left justify by default.
	lyric$ = ReplaceString(lyric$,"%","|",9999)														// Use a bar rather than % as its nearer to the size of a space
	lastLyric$ = lyric$
	while GetTextTotalWidth(rdr.baseID) < rdr.width  												// While not overflowed and not word on its own
		lastLyric$ = lyric$ 																		// Save old lyrics and increase padding
		lyric$ = ReplaceString(lyric$,"|","| ",9999)
		SetTextString(rdr.baseID,lyric$)															// Update so we can measure it.
	endwhile
	SetTextString(rdr.baseID,ReplaceString(lastLyric$,"|"," ",9999))								// Set text to last before fitting
endfunction

// ****************************************************************************************************************************************************************
//														Create/Move in chord mode (e.g. arrow)
// ****************************************************************************************************************************************************************

function _BarRender_CreateChord(rdr ref as BarRender,bar ref as bar,strum ref as Strum,id as integer)
	CreateSprite(id,IDARROW)
	SetSpriteSize(id,rdr.width / bar.beats / 2,rdr.height * PCSTRINGS / 100 * strum.volume / 100)	// Size of arrow
	if strum.direction > 0 then SetSpriteFlip(id,0,1) else SetSpriteFlip(id,0,0)					// Up or down strum
	a$ = strum.chordName$																			// Get chord name and case it
	a$ = Upper(left(a$,1))+Lower(mid(a$,2,99))
	CreateText(id,a$)																				// Create text label
	SetTextSize(id,GetSpriteWidth(id)/1.4)								
	if len(a$) > 2 then SetTextSize(id,GetSpriteWidth(id)/2.8)										// So it can display C7sus
	SetTextSpacing(id,-GetTextSize(id)/6)															// Compress the spacing a bit.
	SetTextFontImage(id,IDFRAMEFONT)																// Use the white framed font.
	
	a$ = Lower(strum.chordName$) 																	// Get name.
	if FindString(_BarRender_ChordList$,a$+",") = 0 												// If not in the list add it
		_BarRender_ChordList$ = _BarRender_ChordList$ + a$ + ","									
	endif
	for i = 1 to CountStringTokens(_BarRender_ChordList$,",")										// Find it
		if GetStringToken(_BarRender_ChordList$,",",i) = a$											// If found, i is the base for the colour.
			col$ = COLOUR_SET																		// List of possible colours
			p = mod(i-1,len(col$)/4) * 4 + 2														// Work out which to use
			SetSpriteColorRed(id,Val(mid(col$,p+0,1),16)*15+15)										// And colour the sprite
			SetSpriteColorGreen(id,Val(mid(col$,p+1,1),16)*15+15)
			SetSpriteColorBlue(id,Val(mid(col$,p+2,1),16)*15+15)

		endif
	next i
endfunction

function _BarRender_MoveChord(rdr ref as BarRender,xPos as integer,yTop as integer,id as integer)
	alpha = rdr.alpha# * 255
	yc = yTop+rdr.height * PCSTRINGS / 100 / 2
	SetSpritePositionByOffset(id,xPos,yc)
	SetSpriteColorAlpha(id,alpha)
	SetSpriteDepth(id,rdr.depth-2)
	SetTextPosition(id,xPos-GetTextTotalWidth(id)/2,yc - GetTextTotalHeight(id)/2)
	SetTextColorAlpha(id,alpha)
	SetTextDepth(id,rdr.depth-3)
endfunction
	
// ****************************************************************************************************************************************************************
//														Create a single fingerpick on one string
// ****************************************************************************************************************************************************************

function _BarRender_CreatePick(rdr ref as BarRender,pos as integer,fret as integer,stringNo as integer,stringCount as integer,id as integer)
	// TODO: Create fingerpick and associated text
endfunction

// ****************************************************************************************************************************************************************
//							Static method that measures all the lyrics at a given font size to see how big the biggest is
// ****************************************************************************************************************************************************************

function SBarRender_ProcessSongLyrics(song ref as Song)
	_BarRender_ChordList$ = "" 																		// Clear the bar chord list.
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

