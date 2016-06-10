// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		io.agc
//		Purpose:	I/O virtualisation
//		Date:		9th July 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//											Download file, if required, and provide a file for it in local store
// ****************************************************************************************************************************************************************

function IOAccessFile(filename as string)
	filename = ReplaceString(filename,":","/",9999)													// We use . as seperators
	filename = "music/"+filename																	// Put in music directory	
endfunction filename

// ****************************************************************************************************************************************************************
//								Load directory contents (using index.txt) semicolon seperated, directories in brackets
// ****************************************************************************************************************************************************************

function IOLoadDirectory(directoryRoot as string)
	if directoryRoot <> "" then directoryRoot = directoryRoot + ":" 								// index.txt or <tree>:index.txt
	indexFile$ = IOAccessFile(directoryRoot+"index.txt")											// This is the index file.
	ASSERT(GetFileExists(indexFile$) <> 0,"Index file missing "+indexFile$)
	itemList$ = ""																					// List of ; seperated items.
	if directoryRoot <> "" then itemList$ = ";(..)"													// Add parent option if not root
	OpenToRead(1,indexFile$)																		// Open file to read
	while FileEOF(1) = 0																			// Read in ; seperate them
		itemList$ = itemList$ + ";"+ReadLine(1)
	endwhile
	CloseFile(1)
	itemList$ = mid(itemList$,2,99999)																// Drop first semicolon.	
endfunction itemList$
