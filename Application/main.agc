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

InitialiseConstants()																				// Set up constants etc.
LoadResources()																						// Load in resources

SetWindowTitle("MusicTrainer")																		// Set up the display
SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
SetOrientationAllowed(0,0,1,1)																		// Landscape only
CreateSprite(1,IDTGF)
SetSpriteSize(1,64,64)
SetSpritePosition(1,ctrl.scWidth-64-4,ctrl.scHeight-64-4)
CreateSprite(IDBACKGROUND,IDBACKGROUND)																// Create the background
SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)

sng as Song
rMgr as RenderManager
frBrd as FretBoard
mtNm as Metronome
plyr as Player
cHelp as ChordHelper
posn as Positioner

a$ = "music/When I'm Cleaning Windows.music"

//a$ = "music/Dont Worry Be Happy.music"
//a$ = "music/Ukulele Buddy/20 Hokey Pokey WarMgr Up.music"

Song_New(sng)
Song_Load(sng,a$)
SBarRender_ProcessSongLyrics(sng)
Player_New(plyr,"20,13,17,22",10,0)

for i = 1 to sng.barCount
		for j = 1 to sng.bars[i].strumCount
			sng.bars[i].strums[j].displayChord = 1
		next j
next i

type ClickInfo
	x,y as integer
endtype

ChordHelper_New(cHelp,sng,110,220,95,IDB_CHORDHELPER)
ChordHelper_Move(cHelp,32,16)

Positioner_New(posn,sng,888,50,50,IDB_POSITIONER)
Positioner_Move(posn,32,730)

RenderManager_New(rMgr, 824,350, 60,32, 70, 400,8,IDB_RMANAGER)
RenderManager_Move(rMgr,sng,190,350)

Fretboard_New(frBrd,350,80,sng.strings,IDB_FRETBRD)
Fretboard_Move(frBrd,350)

Metronome_New(mtNm,190,60,IDB_METRONOME)
Metronome_Move(mtNm,900,180)

SetPrintSize(16)
pos# = 0.0
while GetRawKeyState(27) = 0   
    Print(ScreenFPS())
    
    if GetPointerPressed() 
		ci as ClickInfo
		ci.x = GetPointerX()
		ci.y = GetPointerY()
		Metronome_ClickHandler(mtNm,ci)
    endif
    
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
		
	RenderManager_MoveScroll(rMgr,sng,pos#)
	Player_Update(plyr,sng,pos#)
	Metronome_Update(mtNm,pos#,sng.beats)
	ChordHelper_Update(cHelp,sng,pos#)
	pos# = pos# + 0.01
	if GetRawKeyPressed(32) <> 0 then pos# = pos# - 4
	pos# = Positioner_Update(posn,pos#)
    Sync()
endwhile

RenderManager_Delete(rMgr)
Fretboard_Delete(frBrd)
Metronome_Delete(mtNm)
ChordHelper_Delete(cHelp)
Positioner_Delete(posn)

while GetRawKeyState(27) <> 0
	Sync()
endwhile

//  TODO: Position Panel drag handler
// 	TODO: Speedo tempo controller.

