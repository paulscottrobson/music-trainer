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

#include "src/includes.agc"

#constant BUILD_NUMBER 		1
#constant BUILD_DATE 		"12 June 2016"

Setup()

while 1 = 1
	game as Game
	if 1 = 1
		a$ = IOSelectFromDirectory("")
		Game_New(game,a$)
		Game_Run(game)
		Game_Delete(game)
	else
		a$ = "when im cleaning windows.ukulele"
		rem a$ = "dont worry be happy.music"
		rem a$ = "ukulele buddy:21 hokey pokey.music"
		rem a$ = "uncle rod chord practice:key of d:rod - 5 - chords 4 x f#7,bm,e7,a7,d.music"
		Game_New(game,a$)
		Game_Run(game)
		Game_Delete(game)
		while GetRawKeyState(27) <> 0
			Sync()
		endwhile
	endif
endwhile

//	X exit (!) button
//	M metronome (click on metronome)
//	Q quiet (click on speaker)
//	FSRP Fast/Slow/Reset tempo Pause (click on +/- or dial)
//	Drag bar about

