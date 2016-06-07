// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		main.agc
//		Purpose:	Main Program
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

#include "src/types.agc"																			// Type structures
#include "src/constants.agc"																		// Constant items
#include "src/resources.agc"																		// Resource loader									
#include "src/chorddisplay.agc"																		// Chord Display Object
#include "src/song.agc" 																			// Song manager
#include "src/chordbucket.agc"																		// Chord bucket object
#include "src/barrender.agc" 																		// Bar Renderer
#include "src/rendermanager.agc"																	// Render Manager

InitialiseConstants()																				// Set up constants etc.
LoadResources()																						// Load in resources

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only

CreateSprite(IDBACKGROUND,IDBACKGROUND)																// Create the background
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)

s as Song
cb as ChordBucket
rm as RenderManager

a$ = "music/When I'm Cleaning Windows.music"
//a$ = "music/Dont Worry Be Happy.music"
Song_New(s)
Song_Load(s,a$)
SBarRender_ProcessSongLyrics(s)

ChordBucket_New(cb)
ChordBucket_Load(cb,s,128,256)

for i = 1 to s.barCount
		for j = 1 to s.bars[i].strumCount
			s.bars[i].strums[j].displayChord = 1
		next j
next i

//BarTest(s)
RenderManager_New(rm, 824,350,60, 70, 400,8)
//rm.alpha# = 0.5
RenderManager_Move(rm,s,190,400)

SetPrintSize(16)
pos# = 1.0
while GetRawKeyState(27) = 0   
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
	print(pos#)
	RenderManager_MoveScroll(rm,s,pos#)
	pos# = pos# + 0.01
	if GetRawKeyPressed(32) <> 0 then pos# = pos# - 4
	if pos# < 1.0 then pos# = 1.0
	if pos# > s.barCount+1 then pos# = s.barCount+1
    Print(ScreenFPS())
    Sync()
endwhile
RenderManager_Delete(rm)
while GetRawKeyState(27) <> 0
	Sync()
endwhile
function BarTest(s ref as Song)
	br as BarRender 
	for i = 1 to s.barCount
		BarRender_New(br,s.bars[i],160,120,60,40,1000+i*200)
		//br.alpha# = 0.3
		BarRender_Move(br,mod(i-1,6)*160+10,(i-1)/6*210+210)
		//BarRender_Delete(br)
		//debug = debug + Song_BarToText(s,i)+";"
	next i
endfunction

//  TODO: Backdrop
//  TODO: Metronome
// 	TODO: Player
//  TODO: Position Panel
// 	TODO: Control Panel

