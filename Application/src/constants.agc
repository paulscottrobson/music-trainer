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

#constant 	ISMETRONOME 	1 																		// ID of metronome SFX

// ****************************************************************************************************************************************************************
//																   Blocks of IDs
// ****************************************************************************************************************************************************************

#constant 	IDB_METRONOME	890																		// 890+ Metronome
#constant 	IDB_FRETBOARD 	900																		// 900+ Fretboards
#constant 	IDB_RENDERS 	1000																	// 1000+ ID renders
#constant 	IDB_CHORDBUCKET	28000 																	// 28000-31000 spaces for 60 chords 
#constant 	IDB_PERRENDER 	500 																	// each renderer needs 500 space of IDs

#constant 	ISB_PLAYERBASE 	10 																		// IDs from 10+ allocated to the player

// ****************************************************************************************************************************************************************
//																  Other constants
// ****************************************************************************************************************************************************************

#constant DEPTHBACKGROUND	99																		// Background position
#constant PCSTRINGS 		75 																		// Percentage height of render box occupied by strum/pick
#constant COLOUR_SET		"#00F#0F0#F00#0FF#FF0#F80#888#F0F#800#880#088#A33#8F0#FCD"				// Colours buttons/arrows can use
#constant INVERTFRETBOARD 	1 																		// If non-zero then the A string is at the top of the fretboard

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
