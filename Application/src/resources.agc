// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		resources.agc
//		Purpose:	Resource loader
//		Date:		5th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

function LoadResources()
	LoadImage(IDFONT,GFXDIR+"font_l.png")
	SetTextDefaultFontImage(IDFONT)
	LoadImage(IDFRAMEFONT,GFXDIR+"font.png")
	LoadImage(IDBACKGROUND,GFXDIR+"background.jpg")											
	LoadImage(IDRECTANGLE,GFXDIR+"rectangle.png")
	LoadImage(IDSTRING,GFXDIR+"string.png")
	LoadImage(IDFRET,GFXDIR+"fret.png")
	LoadImage(IDREDCIRCLE,GFXDIR+"red.png")
	LoadImage(IDARROW,GFXDIR+"arrow.png")
	LoadImage(IDNOTEBUTTON,GFXDIR+"notebutton.png")
	LoadImage(IDSINECURVE,GFXDIR+"sinecurve.png")
	LoadImage(IDFRETBOARD,GFXDIR+"fretboard.png")
	LoadImage(IDYELLOWCIRCLE,GFXDIR+"yellow.png")
	LoadImage(IDORANGECIRCLE,GFXDIR+"orange.png")
	LoadImage(IDMETRONOMEBODY,GFXDIR+"metronome_body.png")
	LoadImage(IDMETRONOMEARM,GFXDIR+"metronome_bar.png")
	LoadImage(IDBLUECIRCLE,GFXDIR+"blue.png")
	LoadImage(IDGREENCIRCLE,GFXDIR+"green.png")
	LoadImage(IDTGF,GFXDIR+"logo.png")
	LoadSound(ISMETRONOME,SFXDIR+"metronome.wav")
endfunction

