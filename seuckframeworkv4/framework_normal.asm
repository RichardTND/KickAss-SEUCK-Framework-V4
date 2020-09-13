.var title_screen_new = 0		//New title screen enabled / Disable hi-score saver <-- DO NOT CHANGE
.var title_music_only = 0		//New title screen enabled / Disable hi-score saver <-- YOU CAN CHANGE

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

				//Import declared variables and pointers (Which you can edit). This is 
				//to save this page from being too big ;)
				
				
				#import "variables.asm"

//--------------------------------------------------------------------------------
// Install the one-time installation code, that will replace the standard 
// S.E.U.C.K front end with a brand new front end/title screen.
//--------------------------------------------------------------------------------

				//IF USING THIS FRAMEWORK VERSION - ENABLE THE HI SCORE LOADER
				//IN onetime.asm
				
				*=$0400 "ONE TIME CODE"
				
				#import "onetime.asm" //Insert one time code ...
				
				//If we are using a sprite multicolour mode. A custom panel 
				//can be imported 
statuspanel:				
				.if (scorepanel_multicolour==1) {
								.import binary "c64/panel_multicolour.bin"
				}
				
//-------------------------------------------------------------------------------------------				
// Insert SEUCK game data segment, (From $0900-$6580). 
// 
// HINT: before inserting your game data into the c64 folder, along with				
// 		 other binaries. Use a M/C monitor to save your SEUCK game  
//		 data $0900-$6580 as GAMEPT1.PRG. An Action Replay / Retro Replay   
//		 freezer cartridge will help.   
//				
//		 Command in M/C monitor:				
//				
//		 S "GAMEPT1",8,0900,6580 
//		 S "GAMEPT2",8,B6C0,FFFA				
//		
//		You may also try using VICE M/C monitor using the command:		
//		
//		 S "GAMEPT1" 0 0900 6580
//		 S "GAMEPT2" 0 B6C0 FFFA		
//				
// 		 If it fails, just use Action Replay / Retro Replay instead 
//
//--------------------------------------------------------------------------

				*=$0900 "SEUCK DATA SEGMENT 1 - $0900-$6580"
				
				//Insert SEUCK finished game data from $0900-$6580		
				
				.import c64 "c64/seuckdata1.prg"	// <--- FILENAME FOR SEUCK GAME DATA $0900-$6580

//--------------------------------------------------------------------------
//	Insert source file for in game enhancements. The in game enhancements			
//  code can be modified to how you prefer your game to turn out. For 			
//  example, making enemies explode in one go, linked player deaths, 			
//  forcing power ups, like faster firing, faster player, etc. Additional			
//  background animation, etc. If you want to add additional features 
//  please refer to the page: 
//			
//  http://tnd64.unikat.sk/seuck_school.html 			
//--------------------------------------------------------------------------				
				
				*=$6580 "IN GAME ENHANCEMENTS CODE"
				
				#import "ingameenhancements.asm"
				
//===========================================================================					
//					
// Insert new front end graphics. The graphics should be created in					
// charpad. First, the charset. The correct characters should be set 
// in order (Alpha-numeric characters... Chars 30 and 31 should be RUB/END 
// characters for hi-score name entry - if required. 
//  					
//============================================================================
									
//Charset from Charpad V2.0. Remember to select the following option in  
//charpad: (Tile mode disabled: )
// 
//FILE / EXPORT / CHARSET - export the charset to the folder C64  
 									
				*=$7000 "FRONT END CHARACTER SET"				
charsetdata:	.import binary "c64\front_end_charset.bin"  // <--- FILENAME FOR TITLE SCREEN CHARACTER SET
				
				//Insert your game complete text screen here. Exported											
				//as map from Charpad. 											

//===========================================================================					
//					
//	Insert title screen, get ready, ending and game over code										
//										
//===========================================================================										
				
				*=$7800 "TITLE SCREEN CODE + HI SCORE, DISK SAVER, LOADER, END SCREEN DATA, TITLE SCREEN DATA AND ATTRIBUTES"

//Standard title screen code
								
				#import "titlescreen.asm" 

				//Hi score + saver routine
			    #import "hiscore.asm"
				
//================================================================
								
//FILE / EXPORT / MAP - export the map to the folder C64
				
endscreendata:	.import binary "c64\end_screen.bin" //Rename .bin file

				//Insert your front end screen data 
											
screendata:		.import binary "c64\front_end_screen.bin"					// <--- FILENAME FOR FRONT END SCREEN DATA
//----------------------------------------------------------------------
//In charpad:

//There has been a case where there has been overlapping memory errors 
//due to frontend and hi score table code overlapping the music area 
//to fix this problem. Only the front end char colours can be used for 
//the end screen. 

//FILE / EXPORT / CHAR ATTRIBUTES
//For the ending... The colour attributes MUST be the same as 
//the front end char colours.
												
screenattribs:	.import binary "c64\front_end_attribs.bin" // <--- FILENAME FOR FRONT END CHARSET COLOURS
 
//========================================================================
//ADDING MUSIC ....
//======================================================================== 

//SOME MUSIC EDITORS HAVE THEIR OWN RELOCATORS 
//
//If composing in Goat Tracker / CheeseCutter, both tools have their own
//function which allows you to relocate your music composition to a 
//chosen area. 
//
//Cheesecutter's relocator is CT2UTIL, which is command line based.
//
//RICHARD'S DMC COLLECTION:
//You can find these available from 
//http://tnd64.unikat.sk/download_music.html
//
//Music can be relocated using Syndrom's All Round Relocator, which 
//comes with the DMC collection.  
			
//------------------------------------------------------------------------											
//Title music ... This can be any music format where possible, but music 
//data should BE AT a specific address. $9000-$9fff is good for title music
//or $a000-$afff is good for in game music, although there is room for a 
//little more growth before $b6c0. If your game doesn't require in game 
//music and is LARGER than the title music range. You may need to consider
//editing the sound options code in titlescreen.asm

//Music must be in PRG format.
//
//To do this you can use SIDPLAY to save a PSID version of the tune which 
//is playing, and relocate it with SIDRELOC to $9000 (or $a000 if using 
//in game music). The command used is:
//
// sidrelec -p $90 titlemusic.sid relocmusic.sid
										
			*=$9000	"TITLE MUSIC DATA $9000-$9FFF"
			.import c64 "c64\titlemusic.prg" // <--- FILENAME FOR TITLE MUSIC
			
//------------------------------------------------------------------------			
//In game music ... This can be any music format possible, but music must 
//be relocated to $a000. Music must be in PRG format. 

//IF HOWEVER THE NEW TITLE SCREEN HAS BEEN ENABLED IN VARIABLES.ASM 
//THE IN GAME MUSIC WILL NOT BE INCLUDED.

//NOTE: The example game, Guillotine's title music was pretty big in size
//		the in game music at $a100. It is very simple to set the init and 
//      play addresses to the tunes. based on relocation addresses.

//------------------------------------------------------------------------ 
		
			*=$A000 "INGAME MUSIC DATA $A000 - $AFFF + SCROLLTEXT"
			
			//Insert in game music - if this feature is enabled 

			
.if (title_music_only == 1) {		
} else {	
			
			.import c64 "c64\ingamemusic.prg" // <--- FILENAME FOR IN GAME MUSIC
}			

		
//------------------------------------------------------------------------				
//Title screen scroll text ... This can be written in notepad. Use 				
//LOWER case characters only. Try not to make it too big!
//This is most suitable under bitmap data or in game music :)
//So leave it here :)
//------------------------------------------------------------------------ 
 							
message:				
				.import text "scrolltext.txt"
				.byte 0 //Aways end text with .byte 0								
								
								
//------------------------------------------------------------------------				
//Finally, insert the last part of your SEUCK game data file. (The one				
//in which you saved from $B6C0 - $FFFA from your Action Replay M/C 				
//Monitor.				
//-------------------------------------------------------------------------				
				
 			*=$b6c0 "SEUCK GAME DATA SEGMENT 2 - $B6C0-$FFFA"
			.import c64 "c64/seuckdata2.prg"  //<--- FILENAME FOR SEUCK GAME DATA $B6C0-FFFA
			
//-------------------------------------------------------------------------			