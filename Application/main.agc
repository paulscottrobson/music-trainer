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

#include "src/constants.agc"																		// Constant items
#include "src/resources.agc"																		// Resource loader									
#include "src/io.agc" 																				// I/O Stuff
#include "src/chorddisplay.agc"																		// Chord Display Object
#include "src/song.agc" 																			// Song manager
#include "src/chordbucket.agc"																		// Chord bucket object
#include "src/barrender.agc" 																		// Bar Renderer
#include "src/renderManager.agc"																	// Render Manager
#include "src/fretboard.agc" 																		// Fretboard
#include "src/metronome.agc" 																		// Metronome
#include "src/player.agc" 																			// Sound player object
#include "src/chordhelper.agc" 																		// Chord Helper
#include "src/positioner.agc" 																		// Positioner
#include "src/tempometer.agc" 																		// Tempo meter/controller
#include "src/game.agc" 																			// "Game" object

InitialiseConstants()																				// Set up constants etc.
LoadResources()																						// Load in resources

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only
CreateSprite(IDBACKGROUND,IDBACKGROUND)																// Create the background
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)
SetPrintSize(16)

a$ = "when im cleaning windows.music"
rem a$ = "dont worry be happy.music"
rem a$ = "ukulele buddy:21 hokey pokey.music"
rem a$ = "uncle rod chord practice:key of d:2 - chords d d0 em7 a7.music"

game as Game
Game_New(game,a$)
//_Game_SetDisplayMode(game,0)
Game_Run(game)
Game_Delete(game)
while GetRawKeyState(27) <> 0
	Sync()
endwhile

//	X exit
//	M metronome
//	Q quiet
//	FSRP Fast/Slow/Reset tempo Pause

//	Think about directory loader.
