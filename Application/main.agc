
// Project: MusicTrainer 
// Created: 2016-06-05

// set window properties
SetWindowTitle( "MusicTrainer" )
SetWindowSize( 1024, 768, 0 )

// set display properties
SetVirtualResolution( 1024, 768 )
SetOrientationAllowed( 1, 1, 1, 1 )



while GetRawKeyState(27) = 0
    

    Print( ScreenFPS() )
    Sync()
endwhile
