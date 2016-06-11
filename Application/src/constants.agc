// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		constants.agc
//		Purpose:	Constants and effective constants.
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Directories
// ****************************************************************************************************************************************************************

#constant 	GFXDIR 		"gfx/"
#constant	SFXDIR 		"sfx/"

// ****************************************************************************************************************************************************************
//																   Allocated IDs
// ****************************************************************************************************************************************************************

#constant	IDBACKGROUND	100																		// ID of background image
#constant 	IDRECTANGLE 	101 																	// ID of rectangle image
#constant 	IDSTRING 		102 																	// ID of string
#constant 	IDFRET 			103 																	// ID of frets
#constant 	IDREDCIRCLE 	104 																	// ID of red sphere
#constant 	IDFONT 			105 																	// ID of font
#constant 	IDTEMP 			106 																	// ID for font measuring
#constant	IDARROW			107 																	// ID for chord arrow
#constant 	IDFRAMEFONT 	108 																	// ID for framed font
#constant 	IDNOTEBUTTON 	109 																	// ID for button for single string pluck
#constant 	IDSINECURVE 	110 																	// ID for sine curve.
#constant 	IDFRETBOARD 	111 																	// ID for fretboard
#constant 	IDYELLOWCIRCLE 	112 																	// ID of yellow sphere
#constant 	IDORANGECIRCLE	113 																	// ID of orange sphere
#constant 	IDMETRONOMEBODY	114 																	// ID of metronome body
#constant 	IDMETRONOMEARM	115 																	// ID of metronome arm
#constant 	IDBLUECIRCLE 	116 																	// ID of Blue circle
#constant 	IDGREENCIRCLE 	117 																	// ID of Green circle
#constant	IDTGF 			118 																	// ID of TGF Logo
#constant 	IDSPEAKER 		119 																	// ID of Speaker
#constant	IDEXIT 			120																		// ID of exit icon
#constant	IDMETER 		121 																	// ID of meter body
#constant 	IDMETERNEEDLE 	122 																	// ID of meter needle
#constant 	IDSINECURVEWIDE 123 																	// ID for sine curve (wide version)
#constant	IDFRAME 		124 																	// ID for selector frame

#constant 	ISMETRONOME 	1 																		// ID of metronome SFX
#constant	ISPING 			2 																		// ID of action SFX

// ****************************************************************************************************************************************************************
//																   Blocks of IDs
// ****************************************************************************************************************************************************************

#constant 	IDB_SELECTOR 	800 																	// 800+ Selector IDs
#constant	IDB_METER		840 																	// 840+ Tempo Meter
#constant	IDB_EXIT 		850 																	// 850+ Exit Button
#constant 	IDB_AGK 		860 																	// 860+ AGK Icon
#constant	IDB_PLAYER 		870																		// 870+ Player
#constant 	IDB_POSITIONER 	880 																	// 880+ Positioner
#constant 	IDB_METRONOME	890																		// 890+ Metronome
#constant 	IDB_FRETBRD 	900																		// 900+ Fretboards
#constant 	IDB_RMANAGER 	1000																	// 1000+ Render Manager IDs
#constant 	IDB_CHORDHELPER	28000 																	// 28000-31000 spaces for 60 chords 
#constant 	IDB_PERRENDER 	500 																	// each renderer needs 500 space of IDs

#constant 	ISB_PLAYERBASE 	10 																		// IDs from 10+ allocated to the player

// ****************************************************************************************************************************************************************
//																	Scan Codes
// ****************************************************************************************************************************************************************

#constant KEY_ENTER		   13
#constant KEY_PAGEUP       33
#constant KEY_PAGEDOWN     34
#constant KEY_END          35
#constant KEY_HOME         36
#constant KEY_UP           38
#constant KEY_DOWN         40
#constant KEY_SPACE 	   32

// ****************************************************************************************************************************************************************
//																  Other constants
// ****************************************************************************************************************************************************************

#constant DEPTHBACKGROUND	99																		// Background position
#constant PCSTRINGS 		75 																		// Percentage height of render box occupied by strum/pick
#constant COLOUR_SET		"#00F#0F0#F00#0FF#FF0#F80#888#F0F#800#880#088#A33#8F0#FCD"				// Colours buttons/arrows can use
#constant INVERTFRETBOARD 	1 																		// If non-zero then the A string is at the top of the fretboard
#constant CMDKEYS 			"XMQSFRP"																// Command Keys eXit Metronome Quiet Slower Faster Resettempo Pause

// ****************************************************************************************************************************************************************
//																  Setup constants
// ****************************************************************************************************************************************************************

type _Constants
	scWidth as integer 																				// Screen width
	scHeight as integer 																			// Screen height
	strings as integer 																				// Number of strings
	showHelpers as integer 																			// Show debug helper boxes
endtype

global ctrl as _Constants 																			// This is the actual holder of semi-constants

function InitialiseConstants()
	ctrl.scWidth = 1024																				// Physical and Logical Screen Size
	ctrl.scHeight = 768
	ctrl.strings = 4 																				// Number of instrument strings.
	ctrl.showHelpers = 0																			// When non zero displays debug boxes
endfunction

// ****************************************************************************************************************************************************************
//													Error handlers and assert are kept here
// ****************************************************************************************************************************************************************

global debug as String

function ERROR(errMsg$ as string)
	while GetRawKeyState(27) = 0 																	// Wait for ESC
		print("Error:")
		for i = 1 to CountStringTokens(errMsg$,";")
			print("    "+GetStringToken(errMsg$,";",i))
		next i
		Sync()
	endwhile
	End																								// And exit
endfunction

function ASSERT(test as integer,loc$ as String)
	if test = 0 then ERROR("Assert failed "+loc$)
endfunction

// ****************************************************************************************************************************************************************
//																		Set up display etc
// ****************************************************************************************************************************************************************

function Setup()
	InitialiseConstants()																			// Set up constants etc.
	LoadResources()																					// Load in resources

	SetWindowTitle("MusicTrainer")																	// Set up the display
	SetWindowSize(ctrl.scWidth,ctrl.scHeight,0)
	SetVirtualResolution(ctrl.scWidth,ctrl.scHeight)
	SetOrientationAllowed(0,0,1,1)																	// Landscape only
	CreateSprite(IDBACKGROUND,IDBACKGROUND)															// Create the background
	SetSpriteSize(IDBACKGROUND,ctrl.scWidth,ctrl.scHeight)												
	SetSpriteDepth(IDBACKGROUND,DEPTHBACKGROUND)
	SetPrintSize(16)
endfunction

