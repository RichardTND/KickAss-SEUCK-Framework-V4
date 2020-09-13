//---------------------------------------------------------------------------------
// VARIABLES + PARAMETERS
//=================================================================================

//For specific features use value 0 or 1 to enable / disable features you want
//in your game.

// To enable use = 1, to disable use = 0

//=======================================================================================

//TITLE SCREEN VARIABLES 
//======================

.var allow_getready_screen = 1 //Enable/Disable the GET READY screen 

.var allow_gameover_screen = 1 //Enable/Disable the GAME OVER screen 

.var hiresMcolMode = $18 //Use $08 for hires screen, $18 for multicolour //This will only take effect on the title screen credits or titlescreen v1.

.var animate_front_end_chars = 1 //Front end flash animation 0=disabled, 1 = enabled	

.var play_jingles = 0				//No jingle = just continue title music (or restart title music)
									
//Customizable pointers for title screen
.var scrollspeed = 1 //Speed of scrolling text (Set between 1 and 5)
.var titlebackgroundcolour = $00 //Colour of title screen background colour ($00-$0f)
.var charmulticolour1 = $01 //Colour of char multi colour 1 in your logo/screen ($00-$0f)
.var charmulticolour2 = $0b //Colour of the char multi colour 2 in your logo/screen ($00-$0f)
.var eorcode = $ff		   //Font inverting eor code, use $00 or $ff ($00=Not Inverted $ff=Inverted)

//Char values set to indicate music / SFX chars 
.var musicchar = 35 //Charpad char value that represents music note char
.var sfxchar = 36	//Charpad char value that represents sound effects char

//=======================================================================================

//MAIN GAME FEATURES ...   Use 1 to enable, or 0 to disable

.var sprite_expansion_mode_x = 0	//Use 0 or 255 to trigger sprite expansion (warning, only use this
.var sprite_expansion_mode_y = 0	//for mega sprite games). Games like Operation Firestorm use this 
									//feature.
									
.var sprite_behind_background = 0   //Use 0 or 255 to trigger sprite behind background. Please note that 
									//if this is enabled. All sprites will go behind background objects.
									//If colours are multi-colour 2 and char colour. This feature is very 
									//handy for Commando style games, or fantasy SEUCK, where the player 
									//can hide under trees, behind walls, etc. (In original SEUCK you must 
									//use characters that allow the player to go over those characters)									

.var scorepanel_multicolour = 1		//Enable/disable multicolour score panel sprites 
.var allow_player_safe_respawn = 0  //Player re-spawn at the position it dies (good for push scrolling)
.var allow_smartbomb_effect = 1		//Smart bomb feature set on chosen enemies, suitable for power ups or full on 									
.var allow_detect_enemy_object_type_killed = 1 //Enemy ID detection (requires power ups or boss feature enabled)										   
.var allow_power_ups = 1			//Player power up features 			   										   

.var allow_change_player = 1        //Allow the player shape change every time a power up has been picked up
.var linked_player_mode = 0			//2 players controlled with one joystick 
.var allow_shield = 1				//A shield is enabled/disabled at start of new game, power up or death and re-spawn		
.var fix_horizontal_scroll_routine = 1	//Use with SIDEWAYS SEUCK. It Stabilizes the in game scroll engine a little more
.var custom_level_colour = 1 			//Triggers a different colour scheme according to the level the player is on
.var background_scroller_horizontal = 1 	//Allow char scrolling in sideways SEUCK (See ingameenhancements.asm to set up char to animate)
.var background_scroller_vertical = 0   //Allow char scrolling in standard SEUCK (See ingameenhancements.asm to set up char to animate)
//===========================================

//This is used if feature "player_shield_allowed" is switched on

.var Player1CollisionWithChar = 99 		//Sprite / background collision with char for game
.var Player2CollisionWithChar = 99		//(Refer to SEUCK to set your default collision with char number)
.var Player1DieOrStop = 1				//0 = stop, 1 = die
.var Player2DieOrStop = 1				//for player sprite/bg collision
.var GameBorderColour = 2				//Set sideborder colour in game (Does not work in SEUCK Mod)

//==================================================================================

//General variables 
//==================

.var screenrow = $7400	//Screen RAM area used for new front end
.var colourrow = $d800	//Hardware colour pointers
.var gameloop = $4503	//Address main game loop that can be used
.var sfxplay = $5c94	//Address sfx plays
.var level = $5dc9		//Level parameters

//Music parameters

//Song type (Based on the title music address)

//Title music $9000-$9xxx
.var titlemusic = $00 //Track number for title music address 
.var getreadyjingle = $01 // Track number for get ready jingle for title music address 
.var gameoverjingle = $02 // Track number for game over jingle for title music address 

//In game music $a100-$axxx 
.var ingamemusic = $00 //Track number for in game music address

.var musicinit = $9000	//Title music player init address
.var musicplay = $9003  //Title music player play address
.var music2init = $a000 //In game music player init address
.var music2play = $a003 //In game music player play address

//Score / lives variables

.var player1score = $5ea3	  //Player 1's score
.var player2score = $5ea9	  //Player 2's score

.const gamechar = $f800	//Memory for where the game charset lies. 

//Hi score variables 

.var scorelen = 6 //6 characters length for hi score list
.var namelen = 9  //9 characters length for name entry
.var listlen = 15 //15 hi scores to check through list
.const FLASH = 1

//Please edit these in order to suit your game type 

.var bossID1 = 29 //All of these objects in GUILLOTINE represent
.var bossID2 = 30	//the boss parts in which to trigger a full 
.var bossID3 = 31 //enemy explosion when shot by the player. 
.var bossID4 = 37 
.var bossID5 = 42 
.var bossID6 = 43 
.var bossID7 = 45
.var bossID8 = 46
.var bossID9 = 48

.var powerUpID1 = 53 //Power up object for bonus fire power 
.var powerUpID2 = 54 //Power up object for extra lives
.var powerUpID3 = 25 //Smart bomb 

.var player1lives = $5db7 
.var player2lives = $5db8 


//============================================ PLAYER OBJECTS AND POWER UP FEATURES ================================

//Player object type 
.const Player1Type = $2c80 
.const Player2Type = $2cbc
								 
//Sprite fire type 

.const Player1BulletFrame = $2c94
.const Player2BulletFrame = $2cd0  

//Set amount of bullets player can fire 

.const Player1AmountOfBullets = $40a7 
.const Player2AmountOfBullets = $40ba

.var DefaultBulletAmount = 0 //Amount of bullets (0 which = 1 - 3 which = 4 )
.var PowerUp1BulletAmount = 1 
.var PowerUp2BulletAmount = 2
.var PowerUp3BulletAmount = 3

.var PowerUpDefaultOnLifeLost = 1 //If the player loses a life, default its power up immediately
								  //If you want the player to keep its upgrade set value to 0

//======================================================================================================

//Set lives indication 

.const Player1Lives = $5db7 
.const Player2Lives = $5db8

//Charset animation characters these are the two 
//character sets set to scroll according to direction 
//in the game scroll.

.var ScrollCharID1 = 43
.var ScrollCharID2 = 56		
.var ScrollCharID3 = 255 //

.var temp1 = $ed //Temp bytes (do not change)
.var temp2 = $ee
.var temp3 = $ef

//FOR ADDITIONAL PLAYER PROPERTIES FOR YOUR OWN GAMES, FOR 
//POWER UPS, ETC. PLEASE CHECK OUT "THE SECRET OF SEUCKCESS PART 3" In
//TIPS AT http://www.seuckvault.co.uk
