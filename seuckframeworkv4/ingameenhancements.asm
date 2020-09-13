//===========================================
//
//Richard's SEUCK Game Enhancement Frame Work 
//
//          IN GAME ENHANCEMENTS 
//
//              *** important ***
//
// If there are any in game enhancments you 
// do not wish to have installed into your 
// game. Simply disable them by commenting 
// out the the subroutines
//
//============================================


//-----------------------------------------------------------------------------------------

//In game enhancements loop

				
			
enhancements:	
			
//Main sound player for title or in game music				
//If enabled - paint custom background colour according to 
//chosen levels.
				lda #GameBorderColour //Sets colour of the game's border colour
				sta $d020
				
				jsr SprBITS2
				
.if (custom_level_colour ==1) {
				jsr paintlevelscheme
}			
			
//If enabled - scroll chosen background characters vertically
				
.if (background_scroller_vertical ==1) {
				jsr CharAnimVertical
}

//If enabled - scroll chosen background characters horizontally
.if (background_scroller_horizontal ==1) {
				jsr CharAnimHorizontal
}

//If enabled - player shield and flashing checks on each player 
//this will allow the player to temporarily avoid being killed 
//by enemies if enabled and the shield counter is above 0

.if (allow_shield ==1) {
				jsr TestShield 
}

				//This routine fixes player' starty
				jsr FixPlayer1
				
//If enabled - this feature will trigger the smart bomb effect
//and background flash explosion colour effect 
				
.if (allow_smartbomb_effect ==1) {
				jsr smartbombeffect
				jsr smartbombflasheffect
}				
				
				
soundplayer:				
				jsr soundsystem			//Play either music or sound effects
				
				rts
				
//--------------------------------------------------------------------------------------------
					
//Fix player 1 - If in 1 player mode, and player 2 presses fire
//to start a new game. Enable the player					

FixPlayer1:		lda $dc00					
				lsr					
				lsr					
				lsr					
				lsr					
				lsr					
				bcs noplayer1					
				lda #1			//Enable player 1						
				sta $40af												
				rts					
noplayer1:				
				rts									
													
					
//----------------------------------------------------------------------------------------					
//	In game sound player:					
//
//  Checks system type and then plays in game music or sound effects, depending	
//  on the option selected on the title screen.	
//	
//----------------------------------------------------------------------------------------	

soundsystem:		lda system	
					cmp #1 	
					jmp soundtype	
					inc ntsctimer
					lda	ntsctimer
					cmp #6
					beq resetntsctimer2
soundtype:			jsr sfxplay
					rts
resetntsctimer2:	lda #0
					sta ntsctimer
					rts
					
//----------------------------------------------------------------------------------------					
//  Player safe re-spawn: 					
//					
//  There are situations where after a life has been lost, the player respawns on a 
//  background with a deadly / stopping character. This causes a lot of trouble on 
//  many s.e.u.c.k games, where the player just cannot continue playing. 
//  Respawn the player's backup position  
// 
//---------------------------------------------------------------------------------------- 

//This part is where the players lose a life. We trigger the position
//of the player sprites and store those to the STARTING POSITION vectors.

	

lifelostplayer1:
.if (allow_player_safe_respawn ==1) {

					sta deathtriggerbackupplayer1
					lda $bc01 //Player 1's visual X Position
					sta $40a3 //Store to player 1's respawn area 
					lda $bc02 //Player 1's visual X MSB Position 
					sta $40a4 //Store to player 1's respawn area 
					lda $bc03 //Player 1's visual Y Position 
					sta $40a5 //Store to player 1's respawn area
					lda deathtriggerbackupplayer1
}					
					sta $5dbf
					
.if (PowerUpDefaultOnLifeLost == 1) {
					ldx #0
defaultp1gameloop:	lda P1_powerUpBulletTable1,x
					sta Player1BulletFrame,x
					lda P1_PlayerFrameTable1,x
					sta Player1Type,x
					inx 
					cpx #18
					bne defaultp1gameloop
					lda #PowerUp1BulletAmount
					sta Player1AmountOfBullets
					lda #0
					sta P1PowerUpValue
}					
					
					rts
			
					
lifelostplayer2:	
	.if (allow_player_safe_respawn ==1) {
					sta deathtriggerbackupplayer2
					lda $bc31 //Player 2's visual X Position					
					sta $40b6 //Store to Player 2's respawn area
					lda $bc32 //Player 2's visual X MSB Position 
					sta $40b7 //Store to Player 2's respawn area
					lda $bc33 //Player 2's visual Y Position 
					sta $40b8 //Store to Player 2's respawn area
					lda deathtriggerbackupplayer2
}					
					sta $5dc0
.if (PowerUpDefaultOnLifeLost ==1){			
					ldx #0
defaultp2gameloop:	lda P2_powerUpBulletTable1,x
					sta Player2BulletFrame,x
					lda P2_PlayerFrameTable1,x
					sta Player2Type,x
					inx 
					cpx #18
					bne defaultp2gameloop
					lda #PowerUp1BulletAmount
					sta Player2AmountOfBullets
					lda #0
					sta P2PowerUpValue
					
}
					rts		
					
//----------------------------------------------------------------------										
//Enemy object killed detection ... Detect which enemy										
//has been killed, which player killed it and also										
//what effect should take place if that particular 										
//enemy has been killed.										
//							
//Please refer to the SEUCK editor and note down the OBJECT number that							
//represents the enemies that should be killed to trigger something 							
//special.							
//----------------------------------------------------------------------


killcheck:																	
			sta $5dbb //Detect object hit														
																	
			.if (allow_detect_enemy_object_type_killed==1) {														
															
			lda $bc00,y //Grab object and store														
			sta objectkilled //to object killed pointer 														
			lda $09		//Grab SEUCK zeropage that detects player properties														
			sta playerthatkilledit														
																	
			//Now check if any object items are boss objects 														
			//if they are, reset the smart bomb feature so that														
			//all enemies explode in one go.														
																	
			lda objectkilled			

			
			
			//Check for boss objects 
			
notCollectible:
			cmp #bossID1		//Check object ID for boss
			bne notBoss1
			jmp explodeAll
notBoss1:
			cmp #bossID2
			bne notBoss2
			jmp explodeAll
			
notBoss2:	
			cmp #bossID3
			bne notBoss3 
			jmp explodeAll
			
notBoss3:
			cmp #bossID4
			bne notBoss4
			jmp explodeAll
			
notBoss4:
			
			cmp #bossID5
			bne notBoss5
			jmp explodeAll
			
notBoss5:

			cmp #bossID6
			bne notBoss6
			jmp explodeAll 
			
notBoss6:
			
			cmp #bossID7
			bne notBoss7 
			jmp explodeAll
			
notBoss7:	
			cmp #bossID8 
			bne notBoss8 
			jmp explodeAll 
			
notBoss8:
			cmp #bossID9
			bne notBoss9
			jmp explodeAll


//Check for power up objects (If enabled option)
	
	
notBoss9:
.if (allow_power_ups ==1) {
	
			cmp #powerUpID1
			bne notPowerUp1
			jmp UpdatePlayerBullet	//Update player bullet 

notPowerUp1:
			cmp #powerUpID2 
			bne notPowerUp2 
			jmp UpdatePlayerLives	//Give the player extra lives
			
notPowerUp2:
			cmp #powerUpID3
			bne notPowerUp3
			jmp explodeAll			//Smart bomb
			
notPowerUp3:			
}			
			lda $bd06,y																																																																
			rts 	
			
//Destroy all objects in one go (if enabled). This will
//trigger an explosion timer for exploding all enemies 
//on screen.
			 																																																																			
explodeAll:
																																																													
			lda #$0a																																																																			
			sta explodepointer			
			lda #0
			sta bombflashdelay
			sta bombflashpointer

			
//Optional - Allow level switch straight after killing the boss			
//just comment it out if you don't want it enabled.

			lda #1 //1 seconds before exit level (Can be edited)
			sta $408d
			
}															
																																																
			lda $bd06,y																																																																		
			rts																																																																		
																																																																					
//---------------------------------------------------------------																																																																					
//																																																																					
// Smart bomb effect for boss enemies - let them explode in one																																																																					
// go																																																																					
//																																																																					
//===============================================================																																																																					

smartbombeffect:																																																																					

	.if (allow_smartbomb_effect==1) {																																																																					
			lda explodepointer																																																																					
			bne turnexplosionon																																																																					
			lda #$00																																																																					
			sta explodepointer																																																																					
																																																																								
	   		lda #$4c  //Restore features
         	sta $55e1 //so that any newer
         	lda #$a5  //enemies that come
         	sta $55e2 //on screen wont die
         	lda #$5b  //instantly, after
         	sta $55e3 //the boss stage is
         	lda #$08  //successfully
         	sta $531d //completed.
         	lda #$bd
         	sta $5568
         	lda #$f7
         	sta $5569
         	lda #$b6
         	sta $556a
         	rts
         
         //Explosion switched on - trigger 
         //main explode routine to all visible
         //enemy objects.
         
turnexplosionon:																																																																					
		 	dec explodepointer
         	lda #$00
         	sta $531d
         	lda #$4c
         	sta $5568
         	lda #<explodemain
         	sta $5569
         	lda #>explodemain
         	sta $556a
         	rts																																																																	
         
         //Main explosion routine
explodemain:        
         	lda #$60
         	sta $5ee1
         	jsr $55b6 
         	lda #$4c
         	sta $55e1
}         	
         	rts
			
//--------------------------------------------------------------------
//If required with smart bomb routine - This enables the screen 
//background flash effect for every time the smart bomb has been 
//activated during the game 

smartbombflasheffect:
			lda bombflashdelay
			cmp #1//speed of flash
			beq bombflashdelayok
			inc bombflashdelay
			rts 
			
bombflashdelayok:
			lda #0
			sta bombflashdelay 
			ldx bombflashpointer
			lda bombflashtable,x
			sta $d021 //Can be changed/expanded to your preference
			inx 
			cpx #10
			beq flashstop
			inc bombflashpointer 
			rts 
flashstop:	ldx #$09
			stx bombflashpointer 
			rts
					
//--------------------------------------------------------------------

//This feature will allow the player to boost fire power 
//First we generate a macro code (since the code would be used
//more than once for both players)
UpdatePlayerBullet:

//Power up features [if enabled]:
.if (allow_power_ups == 1) {
	
	lda playerthatkilledit 
	cmp #$01 
	beq powerUpPlayer2
	
	jsr PowerUpCheck1
	lda $bd06,y
	rts

	
powerUpPlayer2:
	jsr PowerUpCheck2
	lda $bd06,y	
	rts
	
	//Player 1, power up check process 
	
PowerUpCheck1:
	inc P1PowerUpValue
	lda P1PowerUpValue
	cmp #1
	beq P1PowerUp2
	cmp #2
	beq P1PowerUp3
	cmp #3
	beq P1PowerUp4
	
	lda #0
	sta P1PowerUpValue
	
P1bdefault:

	lda #DefaultBulletAmount	//Default amount of bullets for player 1 
	sta Player1AmountOfBullets
	
	lda #<P1_powerUpBulletTable1
	sta p1btbread+1
	lda #>P1_powerUpBulletTable1
	sta p1btbread+2

.if (allow_change_player==1) {
		lda #<P1_PlayerFrameTable1
		sta P1F+1
		lda #>P1_PlayerFrameTable1
		sta P1F+2
}
	
	
	jmp MakeP1powerUp

P1PowerUp2:
	
	lda #PowerUp1BulletAmount
	sta Player1AmountOfBullets
	
	lda #<P1_powerUpBulletTable2
	sta p1btbread+1
	lda #>P1_powerUpBulletTable2
	sta p1btbread+2
	
	
	.if (allow_change_player==1) {
		lda #<P1_PlayerFrameTable2
		sta P1F+1
		lda #>P1_PlayerFrameTable2
		sta P1F+2
	}
// */	
	jmp MakeP1powerUp
	
P1PowerUp3:
	
	lda #PowerUp2BulletAmount
	sta Player1AmountOfBullets
	
	lda #<P1_powerUpBulletTable3
	sta p1btbread+1
	lda #>P1_powerUpBulletTable3
	sta p1btbread+2
	
	.if (allow_change_player==1){
		lda #<P1_PlayerFrameTable3
		sta P1F+1
		lda #>P1_PlayerFrameTable3
		sta P1F+2
	}	
	jmp MakeP1powerUp
	
P1PowerUp4:
	
	lda #PowerUp3BulletAmount
	sta Player1AmountOfBullets
	
	lda #<P1_powerUpBulletTable4
	sta p1btbread+1
	lda #>P1_powerUpBulletTable4
	sta p1btbread+2
	
	.if (allow_change_player==1) {
		lda #<P1_PlayerFrameTable4
		sta P1F+1
		lda #>P1_PlayerFrameTable4
		sta P1F+2
	}

	jmp MakeP1powerUp	
	
MakeP1powerUp:
	ldx #00
p1btbread:
	lda P1_powerUpBulletTable1,x 
	sta Player1BulletFrame,x
	inx 
	cpx #18
	bne p1btbread

	.if (allow_change_player==1) {
		lda P1F+1
		sta P1FSM+1
		lda P1F+2 
		sta P1FSM+2
		ldx #0
P1FSM:	
		lda P1_PlayerFrameTable1,x
		sta Player1Type,x 
		inx
		cpx #18
		bne P1FSM
	}
	rts 
	
	//Player 1, power up check process 
	
PowerUpCheck2:
	inc P2PowerUpValue
	lda P2PowerUpValue
	cmp #1
	beq P2PowerUp2
	cmp #2
	beq P2PowerUp3
	cmp #3
	beq P2PowerUp4
	lda #0
	sta P2PowerUpValue
	
P2bdefault:
	
	lda #DefaultBulletAmount
	sta Player2AmountOfBullets
	lda #<P2_powerUpBulletTable1
	sta p2btbread+1
	lda #>P2_powerUpBulletTable1
	sta p2btbread+2
	

	.if (allow_change_player==1) {
		lda #<P1_PlayerFrameTable1
		sta P2F+1
		lda #>P1_PlayerFrameTable1
		sta P2F+2
	}
	
	jmp MakeP2powerUp

P2PowerUp2:
	
	lda #PowerUp1BulletAmount
	sta Player2AmountOfBullets
	lda #<P2_powerUpBulletTable2
	sta p2btbread+1
	lda #>P2_powerUpBulletTable2
	sta p2btbread+2

	.if (allow_change_player==1) {
		lda #<P2_PlayerFrameTable2
		sta P2F+1
		lda #>P2_PlayerFrameTable2
		sta P2F+2
	}
	
	jmp MakeP2powerUp
	
P2PowerUp3:
	
	lda #PowerUp2BulletAmount
	sta Player2AmountOfBullets
	lda #<P2_powerUpBulletTable3
	sta p2btbread+1
	lda #>P2_powerUpBulletTable3
	sta p2btbread+2
	
	.if (allow_change_player==1) {
		lda #<P2_PlayerFrameTable3
		sta P2F+1
		lda #>P2_PlayerFrameTable3
		sta P2F+2
	}
	
	jmp MakeP2powerUp
	
	
P2PowerUp4:
	
	lda #PowerUp3BulletAmount
	sta Player2AmountOfBullets
	lda #<P2_powerUpBulletTable4
	sta p2btbread+1
	lda #>P2_powerUpBulletTable4
	sta p2btbread+2
	.if (allow_change_player==1) {
		lda #<P2_PlayerFrameTable4
		sta P2F+1
		lda #>P2_PlayerFrameTable4
		sta P2F+2
	}
	jmp MakeP2powerUp
		
MakeP2powerUp:
	ldx #0
p2btbread:
	lda P2_powerUpBulletTable1,x 
	sta Player2BulletFrame,x
	inx 
	cpx #18
	bne p2btbread
	
	.if (allow_change_player==1) {
		lda P2F+1 
		sta P2FSM+1
		lda P2F+2
		sta P2FSM+2
		ldx #0
P2FSM:	lda P2_PlayerFrameTable1,x
		sta Player2Type,x
		inx
		cpx #18
		bne P2FSM
	}
	rts	
	
}
	
	//EXTRA LIVES

UpdatePlayerLives:
		lda playerthatkilledit
		cmp #$01
		beq player2getsextralife
		inc player1lives
		lda $bd06,y
		rts
		
player2getsextralife:		

		inc player2lives
		lda $bd06,y
		rts
		
	
//===================================================================================

//Shield feature ...   In some C64 games, the player needs to use a shield and 
//be able to pass through the deadly background. If you enable this feature,
//you can not only avoid enemy collision, but pass through deadly background like
//in Armalyte.

//.if (allow_shield ==1) {

TestShield:		jsr TestShieldPlayer1
				jsr TestShieldPlayer2
				rts
				
TestShieldPlayer1:
				lda ShieldTimerP1
				cmp #0
				bne ShieldNotOut 
				
				//Shield runs out, all collision gets  
				//restored.
				
				lda #Player1CollisionWithChar //Set background collision CHAR value 
						//in order to allow sprite/background collision
				sta $40ac
				
				lda #$0e //Paint default colour of player 1 
				sta $2c93 
				
				//restore player to enemy
				
				lda #$ad 
				sta $4b03
				lda #$bd 
				sta $4b04
				lda #$5d 
				sta $4b05 
				
				//Then force die/stop to background collision 
				//that suits your game.
				
				lda #Player1DieOrStop
				sta $40ab
				rts
				
//The player's shield is currently still enabled so 
//keep player invulnarability enabled, and decrement the 
//shield timer during play.

ShieldNotOut:

				dec ShieldTimerP1
				lda #255 //Max sprite/char collision 
				sta $40ac 
				lda P1FlashDelay 
				cmp #2
				beq P1TimedFlash
				inc P1FlashDelay
				rts 
				
P1TimedFlash:
				lda #$00
				sta P1FlashDelay 
				ldx P1FlashPointer 
				lda P1ShieldColour,x //Colour table set for shield 
				sta $2c93 //Player 1's sprite frame colour 
				inx 
				cpx #8
				beq ResetFlashP1 
				inc P1FlashPointer 
				rts 
				
				//Reset the flash pointer 
				
ResetFlashP1:
				ldx #$00
				stx P1FlashPointer 
				rts 
				
//Test player 2 shield status 

TestShieldPlayer2:
				lda ShieldTimerP2 
				cmp #0
				bne ShieldNotOut2
				
				lda #$0d //Default colour for player 2 
				sta $2ccf 
				
				//Restore collision
				
				lda #$ad 
				sta $4e12 
				lda #$be
				sta $4e13
				lda #$5d
				sta $4e14 
				
				lda #Player2CollisionWithChar
				sta $40bf 
				
				lda #Player2DieOrStop
				sta $40be 
				rts
				
ShieldNotOut2:	dec ShieldTimerP2 
				lda #255
				sta $40bf 
				lda P2FlashDelay 
				cmp #$02
				beq FlashOk2
				inc P2FlashDelay
				rts
				
FlashOk2:		lda #$00
				sta P2FlashDelay
				ldx P2FlashPointer
				lda P2ShieldColour,x 
				sta $2ccf 
				inx 
				cpx #8
				beq ResetFlashP2 
				inc P2FlashPointer 
				rts 
				
ResetFlashP2:	ldx #$00
				stx P2FlashPointer 
				rts
				
//Shield which should be initialised on player respawn 

ShieldRespawnCodeP1:
				sta Player1Lives
				lda #200
				sta ShieldTimerP1 
				lda #0
				sta P1FlashDelay 
				sta P1FlashPointer 
				rts 
				
ShieldRespawnCodeP2:
				sta Player2Lives 
				lda #200
				sta ShieldTimerP2 
				lda #0
				sta P2FlashDelay 
				sta P2FlashPointer
				rts

//}
				
//==================================================================
				
//In game background animation routine Parallax Scroller
//(For Sideways scrolling SEUCK games)

CharAnimHorizontal:
.if (background_scroller_horizontal ==1) {

//Set char values for scroll:

				lda CharScrollDelay 
				cmp #1
				beq DoCharScroll 
				
				inc CharScrollDelay 
				rts 
DoCharScroll:	lda #0
				sta CharScrollDelay
				ldx #7
hloop:		
				lda $f800+(ScrollCharID1*8),x 
				lsr 
				ror $f800+(ScrollCharID1*8),x 
				lsr 
				ror $f800+(ScrollCharID1*8),x
				
				lda $f800+(ScrollCharID2*8),x
				lsr 
				ror $f800+(ScrollCharID2*8),x 
				lsr 
				ror $f800+(ScrollCharID2*8),x 
				dex
				bpl hloop
				rts
				
}

CharAnimVertical:
.if (background_scroller_vertical==1) {


			
CharAnimVertical:					
				lda CharScrollDelay 
				cmp #1
				beq DoCharScrollV
				inc CharScrollDelay
				rts 
DoCharScrollV:	lda #0
				sta CharScrollDelay
				lda $f800+(ScrollCharID1*8)+7
				sta temp1
				lda $f800+(ScrollCharID2*8)+7
				sta temp2
				lda $f800+(ScrollCharID3*8)+7
				sta temp3
				ldx #7
scrollCharsV:			lda $f800+(ScrollCharID1*8)-1,x
				sta $f800+(ScrollCharID1*8),x 
				lda $f800+(ScrollCharID2*8)-1,x
				sta $f800+(ScrollCharID2*8),x 
				lda $f800+(ScrollCharID3*8)-1,x
				sta $f800+(ScrollCharID3*8),x 
				
				dex
				bne scrollCharsV
				lda temp1
				sta $f800+(ScrollCharID1*8)
				lda temp2 
				sta $f800+(ScrollCharID2*8)
				lda temp3
				sta $f800+(ScrollCharID3*8)

				rts
	
}

//---------------------------------------------------------------
//Level painting subroutine. This will paint the colour  
//$D022, $D023 background colours (Since colour $D021 is 
//reserved for the explosion.
//	

//How to check...   
//---------------
//
//Refer to the LEVEL editor in your game, and then pick the levels 
//which you wish to paint the new background scheme. In order to do 
//this, you need to continue the subroutine loop

//Note that $5dc9 is the level position reader, and its values are
//multiplied by 7. So the value for your levels would have to be 
//one value below the level value multiplied by 7.
//
// EG:	LEVEL 1 CPX = #$00
//      LEVEL 2 CPX = #$01*7
//      LEVEL 3 CPX = #$02*7
// ...and so on.


paintlevelscheme:

.if (custom_level_colour == 1) {

	
				
				ldx $5dc9 //Levels are set in multiples of 7 
				cpx #$00  //Default level 
				bne notLevel1
				
				//Set colour scheme for $d022, and $d023 (or
				//how you want)
				
				lda #$09 //Level 1 - Brown 
				sta $d022 
				lda #$01 //Level 1 - white 
				sta $d023
				rts 
				
notLevel1:		//Check for level 4 ...			
				
				cpx #$03*7
				bne notLevel5 
				
				//Set level scheme colour for chosen level
				lda #$0b //Level 4 - Dark Grey 
				sta $d022 
				lda #$01 //Level 4 - white again 
				sta $d023 
				rts 
				
notLevel5:		//Check for level 6

				cpx #$05*7
				bne notLevel7
				
				//Set level scheme colour for chosen level 
				lda #$02 //Level 3 RED 
				sta $d022 
				lda #$0f
				sta $d023 //Level 2 - light green				
				rts
				
notLevel7:		//No more to add
				
				rts
}				
//Stabilize horizontal scrolling SEUCK scrolling engine a little more 
//WARNING: This will display some BLACK vertical lines if used, but it 
//does make the horizontal scroll flicker less 
fixscroll:
.if (fix_horizontal_scroll_routine ==1) {
			
				lda #$19
				sta $d011 //Stabilize VSP 
				
				
				rts
}
				

//		
//------------------------------------------------------------------------
         							
//Pointers to indicate backup of the player's position.										
deathtriggerbackupplayer1: .byte 0
player1backupx:		.byte 0										
player1backupxmsb:	.byte 0										
player1backupy:		.byte 0										
deathtriggerbackupplayer2: .byte 0
player2backupx:		.byte 0										
player2backupxmsb:	.byte 0										
player2backupy:		.byte 0										
objectkilled:		.byte 0					
playerthatkilledit: .byte 0					
explodepointer:		.byte 0
ShieldTimerP1:		.byte 0
ShieldTimerP2:		.byte 0
P1FlashDelay:		.byte 0 
P2FlashDelay:		.byte 0
P1FlashPointer:		.byte 0
P2FlashPointer:		.byte 0
bombflashdelay:		.byte 0
bombflashpointer:	.byte 0
CharScrollDelay:	.byte 0 
P1PowerUpValue:		.byte 0
P2PowerUpValue:		.byte 0

P1F:					.byte 0,0,0
P2F:					.byte 0,0,0
//TABLES:

//Player shield flash colours ... Note that when adjusting the 
//colour scheme. You might want to alter the X value as well as 
//Y. Because, each byte is XY where: X = Anim type, Y = Colour.

//	Directional = $Ecolour .... Directional hold = $Fcolour

P1DefaultColour: .byte $0e 
P2DefaultColour: .byte $0a

P1ShieldColour:		.byte $06,$0e,$03,$01,$03,$0e,$06 
P2ShieldColour:		.byte $09,$05,$0d,$01,$0d,$05,$09

//=======================================================================
//
//	POWER UP TABLE
//
//=======================================================================

//.if (allow_power_ups ==1) { 

//Look at SEUCK object table properties for this feature 
//then type in the sprite frame value for each power up
//bullet frame object animation. (18 bytes max per table)

//NOTE: For directional/directional hold, in SEUCK change 
//to ANIM TYPE: 18 first. Type in the 18 sprite frame byte values 
//as inidicated in SEUCK, then put back to Directional/Directional hold 

//NOTE 2: The changing of animation frames can be quite complex, 
//        when it comes to changing of the bullet or player 
//		  animation. The easiest option would be to set anim type
//		  to 18 and duplicate the animation frame table after the last
//		  one. Take for example, a bullet that consists of 3 frames 
//		  as an animation in SEUCK. For example sprites 29,30,and 31
//		  making the player bullet:

//		  Repeat the 3 frames in the table like so:
//
//		  P1_powerUpBulletTable1:	.byte 029,030,031,029,030,031
//									.byte 029,030,031,029,030,031
//									.byte 029,030,031,029,030,031


//Power up version 1 [Guillotine - single bullet] 

P1_powerUpBulletTable1:		.byte 110, 110 ,110, 110, 110, 110
							.byte 110, 110, 110, 110, 110, 110
							.byte 110, 110, 110, 110, 110, 110

//Power up version 2 [Guillotine - double bullet] 

P1_powerUpBulletTable2:		.byte 005, 005, 005, 005, 005, 005							
							.byte 005, 005, 005, 005, 005, 005
							.byte 005, 005, 005, 005, 005, 005 
							

//Power up version 3 [Guillotine - 3x bullet] 

P1_powerUpBulletTable3:		.byte 111, 111, 111, 111, 111, 111
						    .byte 111, 111, 111, 111, 111, 111
							.byte 111, 111, 111, 111, 111, 111	

//Power up version 4 [Laser]

P1_powerUpBulletTable4:		.byte 123, 123, 123, 123, 123, 123
						    .byte 123, 123, 123, 123, 123, 123
							.byte 123, 123, 123, 123, 123, 123							
	
//*** and here are the power up bullet frame tables for player 2	
							

//Power up version 1 [Guillotine - single bullet] 

P2_powerUpBulletTable1:		.byte 110, 110, 110, 110, 110, 110
							.byte 110, 110, 110, 110, 110, 110
							.byte 110, 110, 110, 110, 110, 110

//Power up version 2 [Guillotine - double bullet] 

P2_powerUpBulletTable2:		.byte 005, 005, 005, 005, 005, 005							
							.byte 005, 005, 005, 005, 005, 005
							.byte 005, 005, 005, 005, 005, 005 
							
//Power up version 3 [Guillotine - triple bullet] 

P2_powerUpBulletTable3:		.byte 111, 111, 111, 111, 111, 111
						    .byte 111, 111, 111, 111, 111, 111
							.byte 111, 111, 111, 111, 111, 111
							
//Power up version 4 [Laser]

P2_powerUpBulletTable4:		.byte 123, 123, 123, 123, 123, 123
						    .byte 123, 123, 123, 123, 123, 123
							.byte 123, 123, 123, 123, 123, 123										


//.if (allow_change_player==1) {							
//PLAYER ANIMATION TRANSFORMATION. Just like with the power ups 
//bullet animation. Set up the table value of the animation type

//IF player frame is only 1 frame. Copy the first byte and then 
//position it in to the second byte. Place an $82 in the third byte
//table 


P1_PlayerFrameTable1:		.byte 000, 001, 000, 001, 000, 001
							.byte 000, 001, 000, 001, 000, 001
							.byte 000, 001, 000, 001, 000, 001
							
//Player 1 - Power Up 1 transformation
P1_PlayerFrameTable2:		.byte 002, 003, 002, 003, 002, 003
							.byte 002, 003, 002, 003, 002, 003
							.byte 002, 003, 002, 003, 002, 003
							
//Player 1 - Power Up 2 transformation
							
P1_PlayerFrameTable3:		.byte 027, 028, 027, 028, 027, 028							
							.byte 027, 028, 027, 028, 027, 028
							.byte 027, 028, 027, 028, 027, 028
					
//Player 1 - Power Up 3 transformation
					
P1_PlayerFrameTable4:		.byte 029, 030, 029, 030, 029, 030
							.byte 029, 030, 029, 030, 029, 030
							.byte 029, 030, 029, 030, 029, 030
							

//Player 2 - Default
P2_PlayerFrameTable1:		.byte 000, 001, 000, 001, 000, 001
							.byte 000, 001, 000, 001, 000, 001
							.byte 000, 001, 000, 001, 000, 001
							
//Player 2 - Power Up 1 transformation
P2_PlayerFrameTable2:		.byte 002, 003, 002, 003, 002, 003
							.byte 002, 003, 002, 003, 002, 003
							.byte 002, 003, 002, 003, 002, 003
							
//Player 2 - Power Up 2 transformation
							
P2_PlayerFrameTable3:		.byte 027, 028, 027, 028, 027, 028							
							.byte 027, 028, 027, 028, 027, 028
							.byte 027, 028, 027, 028, 027, 028
					
//Player 2 - Power Up 3 transformation
					
P2_PlayerFrameTable4:		.byte 029, 030, 029, 030, 029, 030
							.byte 029, 030, 029, 030, 029, 030
							.byte 029, 030, 029, 030, 029, 030
//}
							
//=======================================================================	
//Colour FLASH table for smart bomb effect
bombflashtable:	.byte $02,$08,$0a,$07,$01,$07,$0a,$08,$02,$00,$00
//=======================================================================
										 					
										
					 

		 
					