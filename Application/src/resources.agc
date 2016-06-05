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
	LoadImage(IDFONT,GFXDIR+"font.png")
	SetTextDefaultFontImage(IDFONT)
	LoadImage(IDBACKGROUND,GFXDIR+"background.jpg")											
	LoadImage(IDRECTANGLE,GFXDIR+"rectangle.png")
	LoadImage(IDSTRING,GFXDIR+"string.png")
	LoadImage(IDFRET,GFXDIR+"fret.png")
	LoadImage(IDREDCIRCLE,GFXDIR+"red.png")
endfunction

