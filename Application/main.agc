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

for i = 1 to sng.barCount
		for j = 1 to sng.bars[i].strumCount
			sng.bars[i].strums[j].displayChord = 1
		next j
next i

type ClickInfo
	x,y as integer
endtype

Player_New(plyr,"20,13,17,22",10,0,64,80,IDB_PLAYER)
Player_Move(plyr,ctrl.scWidth-32-4,ctrl.scHeight-32-4)

ChordHelper_New(cHelp,sng,110,220,95,IDB_CHORDHELPER)
ChordHelper_Move(cHelp,128+32,16)

Positioner_New(posn,sng,888,50,50,IDB_POSITIONER)
Positioner_Move(posn,32,730)

RenderManager_New(rMgr, 824,350, 60,32, 70, 400,8,IDB_RMANAGER)
RenderManager_Move(rMgr,sng,190,350)

Fretboard_New(frBrd,350,80,sng.strings,IDB_FRETBRD)
Fretboard_Move(frBrd,350)

Metronome_New(mtNm,190,60,IDB_METRONOME)
Metronome_Move(mtNm,780,180)

CreateSprite(1,IDTGF)
SetSpritePosition(1,ctrl.scWidth-128-16,105)
SetSpriteDepth(1,98)

SetPrintSize(16)
pos# = 0.0
while GetRawKeyState(27) = 0   
    Print(ScreenFPS())
    Print(pos#)
    
    if GetPointerPressed() 
		ci as ClickInfo
		ci.x = GetPointerX()
		ci.y = GetPointerY()
		Metronome_ClickHandler(mtNm,ci)
		Position_ClickHandler(posn,rMgr,sng,ci)
		Player_ClickHandler(plyr,ci)
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
Player_Delete(plyr)

while GetRawKeyState(27) <> 0
	Sync()
endwhile

// 	TODO: Speedo tempo controller.
//	TODO: Main object
