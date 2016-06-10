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
#include "src/selectoritem.agc" 																	// Selector item
#include "src/musicselector.agc" 																	// Music Selector

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

d$ = "uncle rod chord practice:key of c"
//d$ = "uncle rod chord practice"
item$ = IOLoadDirectory(d$)
ms as MusicSelector
MusicSelector_New(ms,item$,900,70,10,8,20,300)

debug = MusicSelector_Select(ms)
MusicSelector_Delete(ms)

a$ = "when im cleaning windows.music"
rem a$ = "dont worry be happy.music"
rem a$ = "ukulele buddy:21 hokey pokey.music"
rem a$ = "uncle rod chord practice:key of d:rod - 5 - chords 4 x f#7,bm,e7,a7,d.music"

/* 
game as Game
Game_New(game,a$)
//_Game_SetDisplayMode(game,0)
Game_Run(game)
Game_Delete(game)
*/

while GetRawKeyState(27) = 0
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
	Sync()
endwhile

//"C:\music-trainer\Application\media\music\uncle rod chord practice\key of d\rod - 5 - chords 4 x f#7,bm,e7,a7,d.music"
//	X exit
//	M metronome
//	Q quiet
//	FSRP Fast/Slow/Reset tempo Pause


// TODO: Mouse click to select
// TODO: Mouse click to scroll
