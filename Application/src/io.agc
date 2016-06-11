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
		line$ = ReadLine(1)
		if right(line$,9) = "_private)" and GetDeviceBaseName() = "html5" then line$ = "" 			// Private in executable only																// Private (Exe only)
		if line$ <> "" then itemList$ = itemList$ + ";" + line$
	endwhile
	CloseFile(1)
	itemList$ = mid(itemList$,2,99999)																// Drop first semicolon.	
endfunction itemList$

// ****************************************************************************************************************************************************************
//														Select from current directory
// ****************************************************************************************************************************************************************

function IOSelectFromDirectory(root$ as String)
	completed = 0
	result$ = ""
	while completed = 0																				// Loop until selected something or parent
		mse as MusicSelector
		MusicSelector_New(mse,IOLoadDirectory(root$),900,70,10,8,20,300)							// Create selector
		item$ = MusicSelector_Select(mse)															// Do selection
		MusicSelector_Delete(mse)																	// Deleete it
		if left(item$,1) = "("																		// Directory ?
			if item$ = "(..)"																		// Parent dictionary
				result$ = ""
				completed = 1
			else
				if root$ = "" then dir$ = "" else dir$ = root$+":"									// Build path to directory
				dir$ = dir$ + mid(item$,2,len(item$)-2)
				result$ = IOSelectFromDirectory(dir$)												// Select from it
				if result$ <> ""																	// If something returned other than parent
					result$ = mid(item$,2,len(item$)-2)+":"+result$								// Construct full path from here and return
					completed = 1
				endif
			endif
		else																						// Selected something
			result$ = item$																			// return it.
			completed = 1
		endif
	endwhile
endfunction result$

