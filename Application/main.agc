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

InitialiseConstants()
LoadResources()

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only
CreateSprite(IDBACKGROUND,IDBACKGROUND)
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)

c as ChordDisplay
ChordDisplay_New(c,"g","0232",1000,128,256)
x = 0

while GetRawKeyState(27) = 0   
    Print( ScreenFPS() )
    ChordDisplay_Move(c,x,200)
    inc x
    c.alpha# = mod(x,100) / 100.0
    Sync()
endwhile
