// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		chorddisplay.agc
//		Purpose:	Chord Display Objects
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//															Chord Display Object Members
// ****************************************************************************************************************************************************************

type ChordDisplay
	baseID as integer 																				// Base graphics ID (needs 40)
	x,y as integer																					// Position of display
	depth as integer 																				// Physical depth
	alpha# as float 																				// Alpha value (0 -> 1)
	height,width as integer 																		// Physical size
	strings as integer 																				// Number of strings
	frets as integer 																				// Number of displayed frets
	fretting$ as String 																			// Fretting in X003 format.
	name$ as String 																				// Name of chord
endtype

// ****************************************************************************************************************************************************************
//														Create new Chord Display Object
// ****************************************************************************************************************************************************************

function ChordDisplay_New(cd ref as ChordDisplay,name$ as String,fretting$ as String,baseID as integer,width as integer,height as integer)
	ASSERT(GetSpriteExists(baseID) = 0,"CD1")
	cd.baseID = baseID																				// Save parameters, initialise others
	cd.depth = 90
	cd.alpha# = 1.0
	cd.height = height
	cd.width = width
	cd.strings = ctrl.strings
	cd.frets = 6
	cd.fretting$ = fretting$
	cd.name$ = name$
	CreateSprite(baseID,IDRECTANGLE)																// Create background rectangle (S+0)
	SetSpriteSize(baseID,width,height)
	SetSpriteColor(baseID,255,255,255,255)															// Make it white (frame)
	CreateSprite(baseID+9,IDRECTANGLE)																// Background (S+1)
	SetSpriteSize(baseID+9,width-4,height-4)
	SetSpriteColor(baseID+9,0,0,0,255)
	
	for i = 1 to cd.strings																			// Create strings (S+1..S+8)
		CreateSprite(baseID+i,IDSTRING)
		scale# = height * 9 / 10 / GetSpriteWidth(baseID+i) 										// Calculate scale to fit 90% of height
		SetSpriteScale(baseID+i,scale#,scale#)
		SetSpriteAngle(baseID+i,90)
		CreateSprite(baseID+i+30,IDREDCIRCLE)														// Create red dots (S+30..S+39)		
		scale# = width * 6 / 10 / cd.strings / GetSpriteHeight(baseID+30+i)
		SetSpriteScale(baseID+30+i,scale#,scale#)
	next i
	
	for i = 0 to cd.frets 																			// Create frets (S+10..S+29)
		CreateSprite(baseID+10+i,IDFRET)
		scale# = width * 6 / 10 / GetSpriteHeight(baseID+i+10)										
		SetSpriteScale(baseID+10+i,scale#,scale#)
		SetSpriteAngle(baseID+10+i,90)
	next i
	
	for i = 1 to len(name$)																			// Create name T+1 to T+..
		l$ = lower(mid(name$,i,1))
		if i = 1 then l$ = upper(l$)
		CreateText(baseID+i,l$)
		SetTextSize(baseID+i,width/4)
	next i
	
	ChordDisplay_Move(cd,100,100)																	// Move to arbitrary initial position
endfunction

// ****************************************************************************************************************************************************************
//														Dispose of Chord Display Object
// ****************************************************************************************************************************************************************

function ChordDisplay_Delete(cd ref as ChordDisplay)
	ASSERT(GetSpriteExists(cd.baseID) <> 0,"CD2")
	DeleteSprite(cd.baseID)																			// Delete background rectangle/frame
	DeleteSprite(cd.baseID+9)
	for i = 1 to cd.strings																			// Delete strings and circles
		DeleteSprite(cd.baseID+i)
		DeleteSprite(cd.baseID+i+30)
	next i
	for i = 0 to cd.frets																			// Delete frets
		DeleteSprite(cd.baseID+i+10)
	next i
	for i = 1 to len(cd.name$)																		// Delete text
		Deletetext(cd.baseID+i)
	next i
endfunction

// ****************************************************************************************************************************************************************
//											Reposition, set Depth and Alpha of Chord Display Object
// ****************************************************************************************************************************************************************

function ChordDisplay_Move(cd ref as ChordDisplay,x as integer,y as integer)
	ASSERT(GetSpriteExists(cd.baseID) <> 0,"CD3")
	cd.x = x 																						// Save new position
	cd.y = y 
	alpha = cd.alpha# * 255 																		// Alpha in range 0-255
	SetSpritePosition(cd.baseID,x,y)																// Frame (S+0)													
	SetSpriteColorAlpha(cd.baseID,alpha)
	SetSpriteDepth(cd.baseID,cd.depth)
	SetSpritePosition(cd.baseID+9,x+2,y+2)																// Background rectangle (S+9)													
	SetSpriteColorAlpha(cd.baseID+9,alpha)
	SetSpriteDepth(cd.baseID+9,cd.depth-1)
	
	xSpace = cd.width * 6 / 10
	ySpace = cd.height * 9 / 10 																	// Allocate space.	
	
	for i = 1 to cd.strings 																		// Position strings and frets.
		xPos = xSpace * (i - 1) / (cd.strings-1) + x + cd.width * 30 / 100
		SetSpritePositionByOffset(cd.baseID+i,xPos,y+cd.height/2)
		SetSpriteColorAlpha(cd.baseID+i,alpha)
		SetSpriteDepth(cd.baseID+i,cd.depth-3)
		
		fret = val(mid(cd.fretting$,i,1))															// Position red fingermarkers
		SetSpritePositionByOffset(cd.baseID+30+i,xPos,_ChordDisplay_yFret(cd,fret-0.5))
		if fret = 0 or fret > cd.frets then SetSpriteColorAlpha(cd.baseID+30+i,0) else SetSpriteColorAlpha(cd.baseID+30+i,alpha)
		SetSpriteDepth(cd.baseID+30+j,cd.depth-4)
		
	next i

	for j = 0 to cd.frets																			// Position frets
		SetSpritePositionByOffset(cd.baseID+10+j,x+cd.width*60/100,_ChordDisplay_yFret(cd,j))
		SetSpriteColorAlpha(cd.baseID+10+j,alpha)
		SetSpriteDepth(cd.baseID+10+j,cd.depth-2)				
	next j
	
	y1 = y + cd.height * 5 / 100																	// Position letter text
	for i = 1 to len(cd.name$)
		SetTextPosition(cd.baseID+i,x+cd.width * 15 / 100-GetTextTotalWidth(cd.baseID+i)/2,y1)
		SetTextColorAlpha(cd.baseID+i,alpha)
		SetTextDepth(cd.baseID+i,cd.depth-2)
		y1 = y1 + GetTextTotalHeight(cd.baseID+1)*0.75
	next i

endfunction

// ****************************************************************************************************************************************************************
//														Calculate Fret Position
// ****************************************************************************************************************************************************************

function _ChordDisplay_yFret(cd ref as ChordDisplay,pos# as float)
	y = cd.y + cd.height * 95 / 100
	y = y - (cd.frets-pos#) * cd.height * 90 / 100 / cd.frets
endfunction y

	
