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
	LoadImage(IDSINECURVEWIDE,GFXDIR+"sinecurve_wide.png")
	LoadImage(IDFRETBOARD,GFXDIR+"fretboard.png")
	LoadImage(IDYELLOWCIRCLE,GFXDIR+"yellow.png")
	LoadImage(IDORANGECIRCLE,GFXDIR+"orange.png")
	LoadImage(IDMETRONOMEBODY,GFXDIR+"metronome_body.png")
	LoadImage(IDMETRONOMEARM,GFXDIR+"metronome_bar.png")
	LoadImage(IDBLUECIRCLE,GFXDIR+"blue.png")
	LoadImage(IDGREENCIRCLE,GFXDIR+"green.png")
	LoadImage(IDTGF,GFXDIR+"logo.png")
	LoadImage(IDSPEAKER,GFXDIR+"speaker.png")
	LoadImage(IDEXIT,GFXDIR+"exit.png")
	LoadImage(IDMETER,GFXDIR+"meter.png")
	LoadImage(IDMETERNEEDLE,GFXDIR+"meter_needle.png")
	LoadSound(ISMETRONOME,SFXDIR+"metronome.wav")
	LoadSound(ISPING,SFXDIR+"ping.wav")
endfunction

