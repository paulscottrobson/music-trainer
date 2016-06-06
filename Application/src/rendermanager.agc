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
	SetSpritePosition(IDB_RENDERS,rm.x,rm.y)																// shows the area.
	SetSpriteSize(IDB_RENDERS,width,height)
	SetSpriteColorAlpha(IDB_RENDERS,128)
	SetSpriteDepth(IDB_RENDERS,depth+1)
	
	RenderManager_MoveScroll(rm,0.0)																// To the start.
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

function RenderManager_Move(rm ref as RenderManager,x as integer,y as integer)
	SetSpritePosition(IDB_RENDERS,x,y)																// Move the debugging square
	pos# = rm.currentPos# 																			// Save where we are
	rm.currentPos# = 9999999.0 																		// Make sure the moveScroll routine decides on a repaint.
	RenderManager_MoveScroll(rm,pos#)																// Move it back to its current position
endfunction
// ****************************************************************************************************************************************************************
//															Move the bar render to a specific position
// ****************************************************************************************************************************************************************
	
function RenderManager_MoveScroll(rm ref as RenderManager,barOffset# as float)
	// TODO: Check if it can be done by moving the objects
	// TODO: If so move them, replacing any new ones as required.
	// TODO: If not, then reset them all.
endfunction
