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
#include "src/rendermanager.agc"																	// Render Manager
#include "src/fretboard.agc" 																		// Fretboard
#include "src/metronome.agc" 																		// Metronome
#include "src/player.agc" 																			// Sound player object

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
fb as FretBoard
mt as Metronome
pl as Player

a$ = "music/When I'm Cleaning Windows.music"
a$ = "music/Dont Worry Be Happy.music"
//a$ = "music/Ukulele Buddy/19 Intro to 2 chords.music"
Song_New(s)
Song_Load(s,a$)
SBarRender_ProcessSongLyrics(s)
ChordBucket_New(cb)
ChordBucket_Load(cb,s,110,220,95)
Player_New(pl,"20,13,17,22",10,0)

for i = 1 to s.barCount
		for j = 1 to s.bars[i].strumCount
			s.bars[i].strums[j].displayChord = 1
		next j
next i

//BarTest(s)
RenderManager_New(rm, 824,350, 60,32, 70, 400,8)
Fretboard_New(fb,350,80,s.strings)
//rm.alpha# = 0.5
RenderManager_Move(rm,s,190,350)
Fretboard_Move(fb,350)
Metronome_New(mt,160,60,IDB_METRONOME)
Metronome_Move(mt,900,160)

ChordBucket_Move(cb,1,100,10)
ChordBucket_Move(cb,2,230,10)

SetPrintSize(16)
pos# = 1.0
while GetRawKeyState(27) = 0   
	for i = 1 to CountStringTokens(debug,";")
		print(GetStringToken(debug,";",i))
	next i
	print(pos#)
	RenderManager_MoveScroll(rm,s,pos#)
	Player_Update(pl,s,pos#)
	Metronome_Update(mt,pos#,s.beats)
	pos# = pos# + 0.01
	if GetRawKeyPressed(32) <> 0 then pos# = pos# - 4
	if pos# < 1.0 then pos# = 1.0
	if pos# > s.barCount+1 then pos# = s.barCount+1
    Print(ScreenFPS())
    Sync()
endwhile

RenderManager_Delete(rm)
Fretboard_Delete(fb)
Metronome_Delete(mt)
ChordBucket_Delete(cb)

while GetRawKeyState(27) <> 0
	Sync()
endwhile

//  TODO: Chord helper.
//  TODO: Position Panel
// 	TODO: Control Panel

