// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		rendermanager.agc
//		Purpose:	Render Manager class, represents a collection of bars.
//		Date:		6th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																RenderManager Objects
// ****************************************************************************************************************************************************************

type _Render
	isUsed as integer 																				// Non zero if used
	barNumber as integer 																			// The number of the bar in this render
	baseID as integer 																				// The ID group associated with this render.
	renderer as BarRender 																			// The physical render of the object
endtype

type RenderManager
	isInitialised as integer																		// Non zero if initialised.
	currentPos# as float 																			// Current bar position
	renderCount as integer 																			// Number of rendering objects
	renders as _Render[1]																			// The renders themselves.
	x,y as integer 																					// The renderer position (top,left)
	width,height as integer 																		// The renderer group size
	depth as integer 																				// Renderer depth.
	rWidth as integer																				// Size of a single renderer.
endtype

// ****************************************************************************************************************************************************************
//																Create the object
// ****************************************************************************************************************************************************************

function RenderManager_New(rm ref as RenderManager,width as integer,height as integer,depth as integer,rWidth as integer,renderCount as integer)
	rm.x = 0																						// Initialise
	rm.y = 0
	rm.width = width
	rm.height = height
	rm.depth = depth
	rm.rWidth = rWidth
	rm.renderCount = renderCount
	rm.renders.length = renderCount 																// Size the rendered object array
	rm.currentPos# = 999999.0 																		// When moving, this value forces a repaint rather than a move
	for i = 1 to renderCount 
		rm.renders[i].isUsed = 0																	// Mark as not in use
		rm.renders[i].barNumber = -1																// Security - used as index will cause error
		rm.renders[i].baseID = IDB_RENDERS + (i - 1) * IDB_PERRENDER + 1 							// Allocate an ID space for them.
	next i
	rm.isInitialised = 1																			// Is initialised.
	
	CreateSprite(IDB_RENDERS,IDRECTANGLE)															// Create a sprite which is for debug purposes	
	SetSpriteSize(IDB_RENDERS,width,height+64)
	SetSpriteColorAlpha(IDB_RENDERS,128)
	SetSpriteDepth(IDB_RENDERS,depth+1)
	if ctrl.showHelpers = 0 then SetSpriteColorAlpha(IDB_RENDERS,0)
	
endfunction

// ****************************************************************************************************************************************************************
//																Delete the object
// ****************************************************************************************************************************************************************

function RenderManager_Delete(rm ref as RenderManager)
	if rm.isInitialised <> 0 then RenderManager_Clear(rm)											// Erase any current renders
	if GetSpriteExists(IDB_RENDERS) <> 0 then DeleteSprite(IDB_RENDERS)								// Remove the debug sprite if it exists
	rm.isInitialised = 0		
endfunction

// ****************************************************************************************************************************************************************
//																	Clear all renders
// ****************************************************************************************************************************************************************

function RenderManager_Clear(rm ref as RenderManager)
	if rm.isInitialised <> 0
		for i = 1 to rm.renderCount																	// Erase all current objects
			RenderManager_Erase(rm,i)
		next i
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Erase a specific render
// ****************************************************************************************************************************************************************

function RenderManager_Erase(rm ref as RenderManager,n as integer)
	if rm.isInitialised <> 0 and rm.renders[n].isUsed <> 0 											// If created and that render is in use.
		BarRender_Delete(rm.renders[n].renderer)													// Delete the rendered thing.
		rm.renders[n].isUsed = 0
		rm.renders[n].barNumber = -1
	endif
endfunction

// ****************************************************************************************************************************************************************
//																Move the renderer physically
// ****************************************************************************************************************************************************************

function RenderManager_Move(rm ref as RenderManager,song ref as Song,x as integer,y as integer)
	rm.x = x
	rm.y = y
	SetSpritePosition(IDB_RENDERS,x,y-32)																// Move the debugging square
	pos# = rm.currentPos# 																			// Save where we are
	rm.currentPos# = 9999999.0 																		// Make sure the moveScroll routine decides on a repaint.
	RenderManager_MoveScroll(rm,song,pos#)															// Move it back to its current position
endfunction

// ****************************************************************************************************************************************************************
//															Move the bar render to a specific position
// ****************************************************************************************************************************************************************
	
function RenderManager_MoveScroll(rm ref as RenderManager,song ref as Song,barOffset# as float)
	isMoveable = 0 
	if isMoveable <> 0 
		// TODO: If so move them, replacing any on the end as requred.
	else
		RenderManager_Clear(rm) 																	// Erase all, we are doing a complete repaint.
		offset = -1 																				// Start one before the beginning, so we can have scroll out.
		complete = 0 																				// Finished rendering flag.
		while complete = 0 
			id = _RenderManager_addRendering(rm,song,barOffset# + offset,barOffset#)				// Add a rendering at this position.
			inc offset 																				// Advance one.
			if barOffset# + offset >= song.barCount+1 then complete = 1								// Run out of music
			if id > 0 																				// If a renderer was grabbed
				if rm.renders[id].renderer.x >= ctrl.scWidth then complete = 1 						// If it is off the RHS then we are done.
			endif
		endwhile
	endif
	rm.currentPos# = barOffset#																		// Save the current position.
endfunction

// ****************************************************************************************************************************************************************
//															Add a renderer for the given bar and offset in song
// ****************************************************************************************************************************************************************

function _RenderManager_addRendering(rm ref as RenderManager,song ref as Song,bar# as float,offsetInSong# as float)
	rID = -1
	barID = floor(bar#) 																			// Integer bar number.
	if bar# >= 1.0 and bar# < song.barCount+1 														// Is the bar in a legitimate range.
		x = _RenderManager_getBarPosition(rm,barID,offsetInSong#)									// Get the horizontal position of the bar number.
		for i = 1 to rm.renderCount 																// Find an unused render count.
			if rm.renders[i].isUsed = 0 then rID = i
		next i
		ASSERT(rID > 0,"Out of renderers")															// This should not happen !
		rm.renders[rID].isUsed = 1																	// Mark it used
		rm.renders[rID].barNumber = barID 															// Save the bar number.
		BarRender_New(rm.renders[rID].renderer,song.bars[barID],rm.rWidth,rm.height,rm.depth-5,rm.renders[rID].baseID)	
		BarRender_Move(rm.renders[rID].renderer,x,rm.y)												// Put it in the correct place
	endif
endfunction rID

// ****************************************************************************************************************************************************************
//						Get the offset for the given bar position on the display, given the current offset in the song
// ****************************************************************************************************************************************************************

function _RenderManager_getBarPosition(rm ref as RenderManager,barPosition# as float,offsetInSong# as float)
	pos# = barPosition# - offsetInSong#																// This is the horizontal offset in bars
	pos# = rm.x + rm.rWidth * pos#  																// Convert into a pixel position
	//debug = debug + str(barPosition#)+" "+str(offsetInSong#)+" "+str(pos#)+" "+str(rm.x)+" "+str(rm.rWidth)+";"
endfunction pos#
