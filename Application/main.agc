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

InitialiseConstants()
LoadResources()

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only
CreateSprite(IDBACKGROUND,IDBACKGROUND)
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)

s as Song
cb as ChordBucket
Song_New(s)
Song_Load(s,"music/When I'm Cleaning Windows.music")
ChordBucket_New(cb)
ChordBucket_Load(cb,s,128,256)
SBarRender_ProcessSongLyrics(s)
br as BarRender 
for i = 1 to s.barCount
	BarRender_New(br,s.bars[i],200,100,40,1000+i*100)
	BarRender_Move(br,mod(i-1,5)*200+10,(i-1)/5*100+10)
	//BarRender_Delete(br)
next i

//BarRender_New(br,s.bars[11],400,200,30,900)

SetPrintSize(16)
while GetRawKeyState(27) = 0   
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
    Print( ScreenFPS() )
    Sync()
endwhile
