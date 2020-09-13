//******************************
//*                            *
//* seuck enhancment framework *  
//*     by richard bayliss     *
//*                            *
//* (C)2020 The New Dimension  *
//*                            *
//*   http://tnd64.unikat.sk   *
//*                            *
//******************************

//-VERSION 4 ... 

//This build features:
//GENERAL:
//- Example SEUCK game (Split into 2 segments) - GUILLOTINE - THE DOOM MACHINE
//  JUMP ADDRESS = $0400 when crunched.
//  If using Exomizer V3 please use command:
//  exomizer sfx $0400 framework.asm -o framework+.prg -Di_ram_during=$34

//
// TITLE SCREEN:
//- Option to use multicolour bitmap logo (must be manually split and shortened) (Use feature title_screen_new = 1 in variables.asm to enable it
//  the bitmap option will only allow use of title music only. Also cannot use hi-score table if using this feature 
//  MAX LOGO SIZE: 40X10 (Width = 40 chars, Height = 10). 
//- Custom front end with 1 or 2 music files 
//- Front end with character set animation (See charpad charset)
//- Get Ready (Optional)
//- Game Over (Optional)
//- End Screen
//- Hi Score table list 
//- Ability to play one or two separate tunes (Title music at $9000, and In game music at $a000)
//- PAL/NTSC music player
//- Display score panel on NTSC as well as PAL
//- Fully upgradable with your own additional code (Although I have added a few features of my 
//  own).
// -Hi score load/saver

//GAME:
//- Optional sprite expansion
//- Optional sprite behind background priority (Sprites can go behind multi-colour #3 and char colour if enabled)
//- Optional In game music (You must use titlescreen.asm instead of titlescreen2.asm for this feature_
//- Optional multi colour score panel sprites 
//- Background animation for chosen character sets and according to SEUCK type
//- Bug fix for Sideways SECUK mega flicker in scroller 
//- Optional power ups - This time based on sprite animation frame tables rather
//  than a single frame. The animation table routine has been documented to help 
//- Optional player transformation upgrade - When power ups are enabled, the player 
//  can transform itself according to the animation frame set

//Before running this code into your own SEUCK productions. Do as follows.

//1. Load and run your SEUCK GAME / SIDEWAYS SEUCK game like normal. 
//2. Using the machine code monitor in the freeze menu 
//   on your Action Replay/Retro Replay/Atomic Power Cartridge, etc:
//
//	 Save the game in 2 separate segments.  
//
//	 S "seuck1.prg",8,0900,6580
//   S "seuck2.prg",8,B6C0,FFFA
//
//3. Use DIRMASTER and export gameseg1 and gameseg2 from the .D64 and
//   place it into your project c64 folder. For example. 
//
//	 Main folder could be named "GUILLOTINE", then inside that folder 
//   the second folder could be named "C64". Export as PRG. 
//  
//4. After assembling call Exomizer to set jump / sfx address of game as $0400
//   or alterntively use a native C64 packer+cruncher of your choice. 
//   (speedy example: EASTLINKER by CULT + FAST CRUEL V2.5) 
//   Exomizer or PuCrunch is usually the best option.
//
//   TO ASSEMBLE + COMPILE:
//   java -jar "c:\kickassembler\kickass.jar" framework.asm
//   
//	 EXAMPLE: TO CRUNCH WITH EXOMIZER V3
//   c:\exomizer\win32\exomizer.exe sfx $0400 framework.prg -o nameofgame.prg -x2 -Di_ram_during=$34
//==================================================================================================

//Creating a new title screen ...

//New title screen setup - the simplest way:
//------------------------------------------
//
//1. use CHARPAD to build your own re-defined characters and logo
//   graphics. 	Please don't keep on using the same text charset,
//	 create some of your own. It's easy to do this in charpad :)
//
//   If using the multicolour bitmap version of the title screen
//	 you will need to use the TND Koala Logo Splitter Machine 
//	 (Supplied on the D64 with this framework). Your logo must be 
//	 10 characters high and 40 characters wide. The example logo 
//   I did for this game uses this aspect ratio. 
//
//	 Use example  "front_end_screen_v2" if you are to make a new  
//	 front end with logo. Do not go below the ------ in the Char
//   Pad example file. Export your finished front end screen and 
//	 colour data, and charset as usual.
//
//   Note that the tile option must be disabled. Screen map size 
//   must be 40 chars across and 25 rows. Also leave the last row blank for the
//   scrolling message.
//
//2. Save your title screen as a project - just in case you wil need 
//	 to come back to it some time.
//
//3. Export the files Charset, Char attributes (The char colour data) and the 
//   map to the C64 folder.  
//
//4. If you want to re-design the score panel sprites, and make them multi-colour
//	 you can design the numbers + lives panel in CharPad to make those stand out 
//   for your SEUCK game. Then export them as a separate character set only.
//   If you don't need custom character set sprites. Then simply disable them.

				
//Setup the correct filename for your project:
//
//	#import "framework_normal.asm" - for the full screen character set title screen with hi score table and hi score saver 
									//also includes in game music, if enabled.
									
//  #import "framework_bitmap.asm" - for the new title screen, which can display a 40x10 bitmap logo (width 40 chars, height 10 chars)
									//PLEASE NOTE THAT it will NOT use Hi Score Hi/Score saver or use in game music. Only use this 
									//feature if you wish your game to use a nice multicoloured bitmap (USE BUZZSAW KOALA LOGO CUTTING
									//MACHINE TOOL FIRST (provided).
	
//	#import "seuckmod.asm"			- Made by special request by Pinov Vox. This option allows you to play SEUCK games and use a full	
								//    RASTER COLOUR BAR SCROLL over the text.
								//	  Very short and limited, and does not use in game power ups.


								#import "framework_normal.asm"
				