// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		game.agc
//		Purpose:	Main "Game" class
//		Date:		9th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																 Game Objects
// ****************************************************************************************************************************************************************

type ClickInfo
	x,y as integer																					// mouse click position (-ve if none)
	key$ as string																					// key pressed if any
endtype

type Game
	isInitialised as integer																		// non zero when initialised
	song as Song																					// song data
	renderManager as RenderManager																	// manages music rendering
	fretBoard as FretBoard																			// fretboard display
	metronome as Metronome																			// metronome
	player as Player																				// playing tunes and the tune mute button
	chordHelper as ChordHelper																		// assistance with chords (e.g. the twin chord display)
	positionBar as Positioner																		// bar at bottom for positioning
	tempoMeter as TempoMeter																		// round meter showing tempo
	position# as float																				// position in song
	gameOver as integer																				// Non zero when game over
endtype

// ****************************************************************************************************************************************************************
//																Create a new game
// ****************************************************************************************************************************************************************

function Game_New(gm ref as Game,song$ as string)
	gm.isInitialised = 1																			// Now initialised
	
	Song_New(gm.song)																				// Create song
	Song_Load(gm.song,song$)																		// Load song data in
	SBarRender_ProcessSongLyrics(gm.song)															// Analyse lyrics to get font size for rendering.

	Player_New(gm.player,"20,13,17,22",10,0,64,80,IDB_PLAYER)										// Create player
	Player_Move(gm.player,ctrl.scWidth-32-4,ctrl.scHeight-32-4)

	ChordHelper_New(gm.chordHelper,gm.song,110,220,95,IDB_CHORDHELPER)								// Create chord helper
	ChordHelper_Move(gm.chordHelper,340,16)

	Positioner_New(gm.positionBar,gm.song,888,50,50,IDB_POSITIONER)									// Create position bar
	Positioner_Move(gm.positionBar,32,730)

	RenderManager_New(gm.renderManager, 824,350, 60,32, 70, 400,8,IDB_RMANAGER)						// Create render manager
	RenderManager_Move(gm.renderManager,gm.song,190,350)

	Fretboard_New(gm.fretBoard,350,80,gm.song.strings,IDB_FRETBRD)									// Create fretboard
	Fretboard_Move(gm.fretBoard,350)

	Metronome_New(gm.metronome,190,60,IDB_METRONOME)												// Create metronome
	Metronome_Move(gm.metronome,780,180)

	TempoMeter_New(gm.tempoMeter,230,80,IDB_METER)													// Create tempo meter
	TempoMeter_Move(gm.tempoMeter,120,105)

	CreateSprite(IDB_AGK,IDTGF)																		// Create AGK icon
	SetSpritePosition(IDB_AGK,ctrl.scWidth-128-16,105)
	SetSpriteDepth(IDB_AGK,98)

	CreateSprite(IDB_EXIT,IDEXIT)																	// Create exit sprite
	SetSpriteSize(IDB_EXIT,64,64)
	SetSpritePosition(IDB_EXIT,ctrl.scWidth-GetSpriteWidth(IDB_EXIT)-4,4)
	SetPrintSize(16)																				// More print space on screen
endfunction

// ****************************************************************************************************************************************************************
//																			Delete the game object
// ****************************************************************************************************************************************************************

function Game_Delete(gm ref as Game)
	if gm.isInitialised <> 0
		gm.isInitialised = 0
		RenderManager_Delete(gm.renderManager)														// Tidy everything up
		Fretboard_Delete(gm.fretboard)
		Metronome_Delete(gm.metronome)
		ChordHelper_Delete(gm.chordHelper)
		Positioner_Delete(gm.positionBar)
		Player_Delete(gm.player)
		TempoMeter_Delete(gm.tempoMeter)
		DeleteSprite(IDB_AGK)
		DeleteSprite(IDB_EXIT)
	endif
endfunction

// ****************************************************************************************************************************************************************
//																		Run a game object session
// ****************************************************************************************************************************************************************
	
function Game_Run(gm ref as Game)
	if gm.isInitialised = 0 then exitfunction														// Not initialised
		
	gm.position# = 0.0																				// Reset position and end flag
	gm.gameOver = 0
	ci as ClickInfo
	lastTime = GetMilliseconds()																	// elapsed time in milliseconds.
	while gm.gameOver = 0																			// Main loop
		//Print(ScreenFPS())
		//Print(gm.position#)
		if GetRawKeyPressed(27) <> 0 then End 														// Abandon on ESC

		for i = 1 to len(CMDKEYS)																	// Check if any command keys pressed
			if GetRawKeyPressed(asc(mid(CMDKEYS,i,1))) <> 0
				ci.x = -1000
				ci.y = -1000
				ci.key$ = mid(CMDKEYS,i,1)													
				_Game_ClickHandler(gm,ci)															// If so, do them.
			endif
		next i
	
		if GetPointerPressed() 																		// Mouse click ?
			ci.x = GetPointerX()																	// Set up info structure
			ci.y = GetPointerY()
			ci.key$ = ""
			_Game_ClickHandler(gm,ci)																// Handle them
			if GetSpriteHitTest(IDB_EXIT,ci.x,ci.y) <> 0 											// Handle exit
				gm.gameOver = 1
				PlaySound(ISPING)
			endif
		endif
    
		if GetRawKeyPressed(asc("X")) <> 0															// Exit from keyboard
			gm.gameOver = 1
			PlaySound(ISPING)
		endif
	
		for i = 1 to CountStringTokens(debug,";")													// Debug dump
			print(GetStringToken(debug,";",i))
		next i
		
		RenderManager_MoveScroll(gm.renderManager,gm.song,gm.position#)								// Update music display
		Player_Update(gm.player,gm.song,gm.position#)												// Check for playing notes
		Metronome_Update(gm.metronome,gm.position#,gm.song.beats)									// Update metronome
		ChordHelper_Update(gm.chordHelper,gm.song,gm.position#)										// Update chord helper

		step# = gm.song.tempo / 60.0 																// Convert from beats per minute to beats per second.
		step# = step# / gm.song.beats 																// Convert from beats per second to bars per second
		time = GetMilliseconds()																	// Read time.
		if time-lastTime > 100 then lastTime = time													// If more than 0.1s assuming sync is out
		step# = step# * (time-lastTime) / 1000.0													// Scale for elapsed time since last frame
		lastTime = time																				// update last time

		
		gm.position# = gm.position# + TempoMeter_ScalePositionAdjustment(gm.tempoMeter,step#)		// Update position, scaling for tempo set on meter
		gm.position# = Positioner_Update(gm.positionBar,gm.position#)								// Update the positioner, which might overrule this position
		Sync()																						// And ... sync.
	endwhile
endfunction

// ****************************************************************************************************************************************************************
//														Dispatch click/keys to the objects that use them
// ****************************************************************************************************************************************************************

function _Game_ClickHandler(gm ref as Game,ci ref as ClickInfo)
	Metronome_ClickHandler(gm.metronome,ci)															// M Metronome on/off
	Position_ClickHandler(gm.positionBar,gm.renderManager,gm.song,ci)								// Mouse only
	Player_ClickHandler(gm.player,ci)																// Q tune on/off
	TempoMeter_ClickHandler(gm.tempoMeter,ci)														// PSFR pause,slower,faster,reset
endfunction	

// ****************************************************************************************************************************************************************
//									Testing function that makes the displayed strums either all chords or all picks
// ****************************************************************************************************************************************************************

function _Game_SetDisplayMode(gm ref as Game,showChords as integer)
	for i = 1 to gm.song.barCount
		for j = 1 to gm.song.bars[i].strumCount
			gm.song.bars[i].strums[j].displayChord = showChords
		next j
	next i
endfunction
