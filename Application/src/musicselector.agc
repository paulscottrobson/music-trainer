// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		musicselector.agc
//		Purpose:	Music Selector
//		Date:		10th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Selector members
// ****************************************************************************************************************************************************************

type MusicSelector
	isInitialised as integer																		// Is initialised
	x,y,iWidth,iHeight,depth as integer																// X Y position of top, width and height of individuals,depth
	vCount,vSpacing as integer 																		// Number of items visible and gaps between them.
	itemList$ as string 																			// ; seperated list of items.
	vItems as SelectorItem[1]																		// Visible item units
	totalCount as integer 																			// Total number of items
	scrollPosition as integer 																		// Scrolling position
	selected as integer 																			// Current selected,0 = none
	hasScrollBar as integer 																		// True if scroll bar
	baseID as integer 																				// Base ID
	scrollWidth as integer 																			// Width of scroll bar.
endtype

// ****************************************************************************************************************************************************************
//																	Create new selector
// ****************************************************************************************************************************************************************

function MusicSelector_New(mse ref as MusicSelector,itemList$ as String,iWidth as integer,iHeight as integer,depth as integer,vCount as integer,vSpacing as integer,baseID as integer)
	mse.isInitialised = 1	
	mse.iWidth = iWidth
	mse.iHeight = iHeight
	mse.depth = depth 
	mse.vCount = vCount
	mse.totalCount = CountStringTokens(itemList$,";")												// Calc how many items
	if mse.totalCount < mse.vCount then mse.vCount = mse.totalCount 								// If more selector boxes than needed reduce visible count
	mse.vSpacing = vSpacing
	mse.itemList$ = itemList$
	mse.vItems.length = vCount
	mse.scrollPosition = 0
	mse.hasScrollBar = (mse.totalCount > mse.vCount)												// Does it have scroll bar
	mse.baseID = baseID
	mse.scrollWidth = 0
	if mse.hasScrollBar then mse.scrollWidth = iWidth / 16
	mse.selected = 1
	for i = 1 to mse.vCount
		SelectorItem_New(mse.vItems[i],iWidth,iHeight,depth,baseID+i)
	next i
	_MusicSelector_UpdateText(mse)	
	SelectorItem_SetSelected(mse.vItems[1],1)
	MusicSelector_Move(mse,-1,-1)																	// Move it.
endfunction

// ****************************************************************************************************************************************************************
//																	   Delete Selector
// ****************************************************************************************************************************************************************

function MusicSelector_Delete(mse ref as MusicSelector)
	if mse.isInitialised <> 0
		mse.isInitialised = 0
		for i = 1 to mse.vCount
			SelectorItem_Delete(mse.vItems[i])
		next i
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Move Selctor Item
// ****************************************************************************************************************************************************************

function MusicSelector_Move(mse ref as MusicSelector,x as integer,y as integer)
	if mse.isInitialised <> 0		
		if x < 0 then x = ctrl.scWidth/2 - mse.scrollWidth
		if y < 0 then y = ctrl.scHeight/2 - (mse.iHeight*(mse.vCount-1))/2 - (mse.vSpacing*(mse.vCount-1))/2
		mse.x = x
		mse.y = y
		for i = 1 to mse.vCount
			SelectorItem_Move(mse.vItems[i],x,y)
			y = y + mse.iHeight + mse.vSpacing
		next i
	endif
endfunction


function _MusicSelector_UpdateText(mse ref as MusicSelector)
	for i = 1 to mse.vCount
		item$ = GetStringToken(mse.itemList$,";",i+mse.scrollPosition)
		if left(item$,1) = "(" and right(item$,1) = ")"
			item$ = mid(item$,2,len(item$)-2)
			if item$ = ".." then item$ = "Parent Folder" else item$ = "'"+item$+"' Folder"
		endif
		if right(item$,6) = ".music" then item$ = left(item$,len(item$)-6)
		SelectorItem_SetText(mse.vItems[i],item$)
	next i
endfunction
