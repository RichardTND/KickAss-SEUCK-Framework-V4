//===========================================
//
//Richard's SEUCK Game Enhancement Frame Work 
//
//          TITLESCREEN 2, GET READY,
//		  			GAME OVER 
//
//============================================

//--------------------------------------------------------------------------------										
//					
//Front end code		
//
//Pretty standard code, which will display your front end screen, but this time 
//with a multi-colour bitmap logo. This also disables the hi-score table and  
//in game music. Other parts of the game code remain as they are.
//
//This version of the front end does not support in game music. Since the bitmap 
//uses the in game music area. If you want to have in game music, you will need 
//to use sub tunes in Goat Tracker and code a sound options routine, and setup.
//titlescreen.asm has the routines. This one doesn't. It supports SFX only.
//
//---------------------------------------------------------------------------------

titlescreencode:
				sei
				//Kill off interrupts														
				lda #$35								
				sta $01								
										
				lda #$00								
				sta $d011								
				sta $d015								
				sta $d01a								
				sta $d019								
				lda #0
				sta ntsctimer
				sta firebutton1 //init fire depress port 2					
				sta firebutton2 //init fire depress port 1
				sta pagedelay //init title page delay
				sta pagedelay+1 //init second page delay
				sta pageno	  //init title page no.
				lda #$81								
				sta $dc0d								
				sta $dd0d								
						

//This initializes the player power up s feature before running 
//the front end.

.if (allow_power_ups ==1) {
				
				//Default player 1 and player 2 bullet amount 
				//and restore to the default bullet type 
				
				lda #1
				sta Player1AmountOfBullets
				sta Player2AmountOfBullets
				
				lda #200
				sta ShieldTimerP1
				sta ShieldTimerP2
}

//This initializes the smart bomb timers, and explosion colour 
//features 

.if (allow_smartbomb_effect ==1) {

				lda #0
				sta bombflashdelay
				lda #9
				sta bombflashpointer
}

.if (allow_power_ups ==1) { 
					lda #0
					sta P1PowerUpValue
					
					ldx #0 
restorbull1a:		lda P1_powerUpBulletTable1,x
					sta Player1BulletFrame,x
					inx 
					cpx #18
					bne restorbull1a
					lda #0
					sta P2PowerUpValue
					
					ldx #0 
restorbull2a:		lda P2_powerUpBulletTable1,x
					sta Player2BulletFrame,x
					inx 
					cpx #18
					bne restorbull2a
					
					lda #DefaultBulletAmount
					sta Player1AmountOfBullets
					sta Player2AmountOfBullets
					

.if (allow_change_player==1) {
				
//Restore player's frame 

					ldx #0
restorp1:			lda P1_PlayerFrameTable1,x 
					sta Player1Type,x 
					inx 
					cpx #18
					bne restorp1
					
					ldx #0
restorp2:			lda P2_PlayerFrameTable1,x 
					sta Player2Type,x 
					inx 
					cpx #18
					bne restorp2 
}
					
// */					
					
}

//-------------------------------------------------------

				//Clear the SID Chip
										
				ldx #$00								
silenceSID:		lda #$00								
				sta $d400,x								
				inx								
				cpx #$18								
				bne silenceSID								
				jsr shortdelay			
							
				//Automatically backup player starting 			
				//position set by SEUCKs default start		
				//position. 	if enabled
					
.if (allow_player_safe_respawn ==1) {
				lda player1backupx
				sta $40a3
				lda player1backupxmsb
				sta $40a4
				lda player1backupy
				sta $40a5
				
				lda player2backupx
				sta $40b6
				lda player2backupxmsb
				sta $40b7
				lda player2backupy
				sta $40b8
}							
				//Also reset explosion pointer 							
											
				lda #$00							
				sta explodepointer							
							
				//Remove sprites, to prevent sprite screen
				//mess 

				ldx #$00			
removesprites0:	lda #$00							
				sta $d000,x							
				inx							
				cpx #$10							
				bne removesprites0							
												
				//Initialise scroll text message
				
				lda #<message
				sta messread+1
				lda #>message
				sta messread+2
				
				lda #titlebackgroundcolour //Title screen border+background colour 								
				sta $d020								
				sta $d021
				
				lda #charmulticolour1	//Title char multicolour #1 - Can be changed if you want to
				sta $d022
				
				lda #charmulticolour2	//Title char multicolour #2 - Can also be changed if you want to
				sta $d023
										
				//Create the title screen by first copying the bitmap logo 
				//characters to screen ... Then afterwards copy the 
				//credits to the screen
				
				ldx #$00
copyscreen:		lda $8000,x 
				sta $d800,x 
				lda $8000+$100,x 
				sta $d900,x 
				lda screendata,x
				sta screenrow,x
				lda screendata+$100,x
				sta screenrow+$100,x
				lda screendata+$200,x
				sta screenrow+$200,x
				lda screendata+$2e8,x
				sta screenrow+$2e8,x
				inx
				bne copyscreen
				
				//Colour in the title screen graphics data to the
				//screen colour hardware memory ($d990-$dbf8). 
				//(Because we already copied the colour data from 
				//the bitmap colour RAM 
				
				ldx #$00
paintscreen:	ldy screenrow+$190,x
				lda screenattribs,y
				sta colourrow+$190,x 
				ldy screenrow+$200,x 
				lda screenattribs,y 
				sta colourrow+$200,x
				ldy screenrow+$2e8,x
				lda screenattribs,y
				sta colourrow+$2e8,x
				iny
				inx
				bne paintscreen
				
	
				//Clear bottom row for scroll text, set the scroll colour
				//by reading it from a table.
				
				//Also add the hi-score result on the top area of the screen 
				
				ldx #$00
reservescroller:				
				lda #$20 //Spacebar char (32)				
				sta screenrow+24*40,x				
				lda scrollcolourtable,x
				sta colourrow+24*40,x //Fill scroll colour with colour table
				inx				
				cpx #$28	
				bne reservescroller				
				
				//Setup the interrupts 
				
				sei 
				ldx #<irq1
				ldy #>irq1
				stx $fffe
				sty $ffff
				lda #$00	//Split
				sta $d012
				lda #$7f	//Setup CIA timers
				sta $dc0d
				lda #$1b	//Switch screen on
				sta $d011
				lda #$02	//Switch VIC bank #$02
				sta $dd00
				lda #$dc	//Charset address $7000-Display at $7400-$77e7
				sta $d018
				lda #$01	//Switch on interrupt flag
				sta $d01a
				lda #titlemusic		//Tune number
				jsr musicinit //Initialise music
				
				cli
				
				//Main loop for the title screen
				
mainloop:		lda #0			//Synchronize timer with interrupt
				sta synctimer	//so routines inside main loop do
				cmp synctimer	//work outside the irq code.
				beq *-3
				
				//Subroutines for enhancing your front end ... If you
				//wanted to, you could link your own subroutines to
				//the front end. 
				
				jsr doscrolltext	//1x1 char scrolling message
				
				jsr flashroutine	//Routine to prepare flash
				jsr paintpressfire  //Routine to flash press fire text
	
.if (animate_front_end_chars ==1) {

				jsr frontendanimchars //Animate front end characters
}				

				lda $dc00 
				lsr //fire - check
				lsr
				lsr  
				lsr 
				lsr 
				bit firebutton1
				ror firebutton1
				bmi checkport1
				bvc checkport1
				lda #0
				sta firebutton1
				sta firebutton2 
				
				//Joystick port 2 pressed.... Start a
				//1 player game, where player 1 can only play
				
				lda #1 //Enable player
				sta $40af //Player 1
				lda #0
				sta $40c2 //Player 2 
	
				jmp initandstartgame
				
//Check for joystick port 1 (If you don't need a 2 player game 
//and just have 1 player set player 2 or player 1 enabled to 0. 
checkport1:

				lda $dc01
				lsr //fire - check
				lsr
				lsr
				lsr
				lsr
				bit firebutton2
				ror firebutton2
				bmi looptitlescreen
				bvc looptitlescreen //no fire pressed, skip to looptitlescreen
				lda #$00
				sta firebutton1
				sta firebutton2
		
				//Joystick port 1 fire pressed.... Start a
				//1 player game, where player 2 can only play 
				//player 1 can join in at any time - Change to 0 
				//if you want to disable one of the players
				
				lda #1 //Enable player
				sta $40af //Player 1
				lda #1 //Enable player
				sta $40c2 //Player 2 

				jmp initandstartgame
				
looptitlescreen: 
				jmp mainloop		//loop main title code again, until fire
									//has been pressed.
									
				//Scrolling message subroutine.					
										
									
doscrolltext:	lda xpos									
				sec									
				sbc #scrollspeed									
				and #7								
				sta xpos																		
				bcs endscroll									
													
				ldx #$00									
shiftbottomrowcharsleft:									
				lda screenrow+24*40+1,x									
				sta screenrow+24*40,x									
				inx									
				cpx #$27									
				bne shiftbottomrowcharsleft									
													
messread:		lda message									
				cmp #$00	//byte 0 (@) detected?!?!?									
				bne storechar //no. store last char to screen									
				lda #<message	//lo-byte message init									
				sta messread+1									
				lda #>message	//hi-byte message init									
				sta messread+2									
				jmp messread									
													
storechar:		sta screenrow+24*40+39									
				inc messread+1									
				bne endscroll									
				inc messread+2									
endscroll:		rts												
									
									

//-----------------------------------------------------------------
//FRONT END Character set animation 
//For this routine to take effect, you need 8 chars 
//set. You can manually set the char set value for 
//each char anim:

.var TitleAnimChar1 = 90
.var TitleAnimChar2 = 98

frontendanimchars:
.if (animate_front_end_chars==1){

				lda FrontEndCharDelay
				cmp #3
				beq AnimMain
				inc FrontEndCharDelay
				rts 
AnimMain:		lda #0
				sta FrontEndCharDelay
				ldx #$00
AnimMain1:				
				lda $7000+TitleAnimChar1*8,x 
				sta $7038+TitleAnimChar1*8,x 
				lda $7000+TitleAnimChar2*8,x 
				sta $7038+TitleAnimChar2*8,x 
				inx 
				cpx #$08
				bne AnimMain1
				ldx #$00
AnimMain2:		lda $7000+TitleAnimChar1*8+8,x 
				sta $7000+TitleAnimChar1*8,x 
				lda $7000+TitleAnimChar2*8+8,x 
				sta $7000+TitleAnimChar2*8,x 
				inx 
				cpx #$38
				bne AnimMain2
}
				rts
				
				

//------------------------------------------------------------------
						
				//The fire button has been pressed, so kill all interrupts					
				//and then jump to the main game code, which starts at					
				//$4260 (Simply by calling JMP $4260).	Every time the game				
				//ends. The new front end will start.				
									
initandstartgame:					

				//Switch off interrupts...
				
				sei					
				lda #$35					
				sta $01					
						
				ldx #$00					
clearsound:		lda #$00					
				sta $d400,x					
				inx					
				cpx #$18	
				bne clearsound					
									
				lda #$00					
				sta $d01a					
				sta $d019							
									
				lda #$81					
				sta $dc0d					
				sta $dd0d					
							
				lda #0
				sta ntsctimer
					
							
				
				//Clear the screen
				
				ldx #$00
cleartext:		lda #$20
				sta screenrow,x
				sta screenrow+$100,x
				sta screenrow+$200,x
				sta screenrow+$2e8,x
				lda #titlebackgroundcolour
				sta $d800,x
				sta $d900,x
				sta $da00,x
				sta $dae8,x
				inx
				bne cleartext
				
				//jsr shortdelay
				
				//The GET READY prompt (if enabled)		

	.if (allow_getready_screen==1) {
				
				ldx #$00
drawgetready:	lda getreadytext,x
				sta screenrow+12*40+16,x
				inx
				cpx #getreadytextend-getreadytext
				bne drawgetready
		.if (play_jingles ==1) {
				lda #getreadyjingle //Init get ready jingle
				jsr musicinit
		}		
				
				lda #$fa								
				sta $d012								
				lda #0								
				sta $02								
				lda #0			
				sta firebutton1			
				sta firebutton2				
raswait1:				
				lda $d012								
				cmp #$fa								
				bne raswait1								
				jsr pnplayer		//PAL/NTSC player for music playing						
				jsr flashroutine	//Flashing text routine
				jsr paintpressfire  //Routine to flash press fire text	
				jsr flashcentr
				
				
				//Check if joystick port 2 fire button is
				//pressed to play the game.
getreadyport2:				
				lda $dc00
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton1
				ror firebutton1
				bmi getreadyport1
				bvc getreadyport1
				jmp readytoplay
				
				//Check if joystick port 1 fire button is 
				//pressed to play the game.
getreadyport1:
				lda $dc01
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton2
				ror firebutton2
				bmi waitdelay
				bvc waitdelay
				jmp readytoplay
				
				//No fire button has been pressed, so perform
				//a short wait process before running the game
				
waitdelay:				
				inc $02	//Wait for the GET READY to finish, or							
				lda $02	
				cmp #$fe						
				beq readytoplay							
				jmp raswait1								
} 												

																
readytoplay:								
						
				//Default player 1 and player 2 starting					
				//position					

.if (allow_player_safe_respawn==1) {									
				lda player1defaultx					
				ldx player1defaultxmsb		
				ldy player1defaulty 		
				sta $40a3		
				stx $40a4		
				sty $40a5		
						
				lda player2defaultx		
				ldx player2defaultxmsb		
				ldy player2defaulty		
				sta $40b6		
				stx $40b7		
				sty $40b8		
}				
				

					
				//Jump to main game						
									
				ldx #$00
clearsidforgame:
				lda #$00
				sta $d400,x
				inx
				cpx #$18
				bne clearsidforgame				
				jmp $4260			
									
				//Flash preparation 
				
flashroutine:	lda flashdelay
				cmp #2
				beq flashready
				inc flashdelay
				rts
flashready:		lda #0
				sta flashdelay
				ldx flashpointer
				lda flashtable,x
				sta flashstore
				inx
				cpx #flashtableend-flashtable
				beq resetflashptr
				inc flashpointer
				rts
resetflashptr:
				ldx #0
				stx flashpointer
				rts
				
				//Paint flash routine to 'press fire to play' message 
				
paintpressfire:
				ldx #0
paintloop1:		lda flashstore
				sta colourrow+22*40,x
				inx
				cpx #$28
				bne paintloop1
				rts
				
				//Main IRQ raster interrupts - This splits up the screen 
				//properties, in order to fit a smooth scroller and 
				//standard static screen.
				
irq1:			//Interrupt 1 - Smooth scroller.				

				pha
				txa
				pha
				tya
				pha
				inc $d019
				lda $dc0d
				sta $dd0d
				
				lda #$2a	//Set split raster ... end position... (Start
				sta $d012	//position is read from irq2.
				
				lda #$02	//VIC 2 Bank #2
				sta $dd00
				
				lda #$1b	//Normal screen mode
				sta $d011
				
				lda #$dc 
				sta $d018
				
				lda xpos	//Set smooth scroll pointer
				sta $d016	//to hardware screen horizontal position
				
				lda #1			//Set synchronized timer
				sta synctimer
				
				ldx #<irq2	//Point lo-byte of interrupt 2
				ldy #>irq2  //Point hi-byte of interrupt 2
				stx $fffe
				sty $ffff
				pla
				tay
				pla
				tax
				pla
				rti
				
				
irq2:			//Interrupt 2 - Multicoloured bitmap logo

				pha
				txa
				pha
				tya
				pha
				inc $d019
				
				lda #$82	//Set split raster ... end position ... (Start position
				sta $d012   //is read from IRQ1.
				
				lda #$01	//Use VIC bank $01
				sta $dd00
				
				lda #$18	//Bitmap screen mode chars $8400-$87e8
				sta $d018 
				
				lda #$3b	//VIC2 multicolour bitmap mode
				sta $d011
							
							
				lda #$18	//Screen multicolour on - No smooth scroller set
				sta $d016	//in top raster.
				
				ldx #<irq3	//Set lo-byte back to irq1
				ldy #>irq3	//Set hi-byte back to irq1
				stx $fffe
				sty $ffff
				pla
				tay
				pla
				tax
				pla
				rti
				
irq3:			//Interrupt 3 - static screen

				pha
				txa 
				pha 
				tya 
				pha 
				inc $d019 
				
				lda #$f1
				sta $d012
				
				lda #$02
				sta $dd00 
				
				lda #$1b
				sta $d011 
				
				lda #$dc
				sta $d018
				
				lda #hiresMcolMode
				sta $d016
				
				
				jsr pnplayer //Pal/Ntsc music player
				
				ldx #<irq1
				ldy #>irq1
				stx $fffe
				sty $ffff
				pla 
				tay
				pla
				tax
				pla
				rti
				
				
				
				//PAL / NTSC music player 
pnplayer:		
				
PALMusic:		jsr musicplay
				rts
//-----------------------------------------------------------------------------------
//
//Game over routine - only complies to last life lost 
//(Simply kill off all of the interrupts), sprites and screen				
//
//====================================================================================



gameoverscreen:				
				sei	
				lda #0
				sta $d019
				sta $d01a
				sta $d011
				lda #$81
				sta $dc0d 
				sta $dd0d
				
				lda #0
				sta $d015
				
				//Remove sprites out of position to avoid displaying sprite 
				//garbage on screen
				
				ldx #$00
spriteremove:	lda #$00				
				sta $d000,x  //Sprite position				
				inx 				
				cpx #$10
				bne spriteremove
				
					
				
				lda #$08				
				sta $d016				
				
				//Clear the SID 
				ldx #$00
gameoversidclear:
				lda #$00
				sta $d400,x
				inx
				cpx #$18
				bne gameoversidclear
				
				//jsr shortdelay	
				
				//Clear the screen		
				ldx #$00				
clearscreen2:	lda #$20				
				sta screenrow,x				
				sta screenrow+$100,x				
				sta screenrow+$200,x				
				sta screenrow+$2e8,x				
				lda #0			
				sta $d800,x				
				sta $d900,x				
				sta $da00,x				
				sta $dae8,x				
				inx				
				bne clearscreen2				
								
				//Replace in game music/sounds with title music				
				//data for GAME OVER prompt 					
									
				ldx #<musicplay						
				ldy #>musicplay 						
				stx soundtype+1
				sty soundtype+2
				
				lda #0			//Title music default
				jsr musicinit
				
		.if (play_jingles ==1) {
 				lda #gameoverjingle
 				jsr musicinit
		}	
				
						

		
				//Display GAME OVER SCREEN if allowed 
				//otherwise jump straight to the hi-score
				//checker subroutine
				
	.if (allow_gameover_screen ==1) {
				
				
				//Display the GAME OVER text
								
				ldx #$00				
showgameover:			lda gameovertext,x							
				sta screenrow+12*40+15,x							
				inx							
				cpx #gameovertextend-gameovertext 							
				bne showgameover							
								
		
				//Switch the screen back on				
								
				lda #$0b 				
				sta $d011
				lda #0
				sta $d015
				lda #$02	
				sta $dd00	
				lda #$dc				
				sta $d018			
				lda #titlebackgroundcolour		
				sta $d020		
				sta $d021		
				
							
				//Reset delay control and joystick fire button			
				//depress control			
							
				lda #0							
				sta $02
				sta firebutton1
				sta firebutton2
				
				
				
				//Do GAME OVER prompt
							
				lda #$fa
				sta $d012
				lda #$1b
				sta $d011
raswait2:
				lda $d012
				cmp #$fa
				bne raswait2
				jsr soundsystem								
				jsr flashroutine	//Flashing text routine
				jsr paintpressfire  //Routine to flash press fire text	
				jsr flashcentr
				
				
				lda $dc00			//Wait for fire press on joystick port 2
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton1
				ror firebutton1
				bmi gameoverport1
				bvc gameoverport1
				jmp titlescreencode
gameoverport1:				
				lda $dc01			//Wait for fire press on joystick port 2
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton2
				ror firebutton2
				bmi gameoverwait
				bvc gameoverwait
				jmp titlescreencode
gameoverwait:
				
				inc $02
				lda $02
				cmp #$fa
				bne raswait2
}				
				jmp titlescreencode
				
//Since the game was completed, an end screen is put 				
//in place. Instead of SEUCK forcing to loop, a loop				
//detect forces the game to jump to the end screen				

endscreen:		sei
				lda #$35
				sta $01
				lda #$00 //Clear all interrupts. Switch				
				sta $d015 //off all sprites, interrupts
				sta $d019
				sta $d01a
				sta $d011 //Screen off
				
				
				//Remove sprites to prevent screen sprite
				//mess
				 
				ldx #$00
spriteremove2:	lda #$00				
				sta $d000,x  //Sprite position				
				inx 				
				cpx #$10
				bne spriteremove2
				
				ldx #0 
quiet:			lda #0
				sta $d400,x 
				inx 
				cpx #$18 
				bne quiet 
				jsr shortdelay
				
				//Call screen data and pointers to
				//write to the correct SCREEN RAM.
				
				ldx #$00
displayend:		lda endscreendata,x
				sta screenrow,x 
				lda endscreendata+$100,x
				sta screenrow+$100,x
				lda endscreendata+$200,x
				sta screenrow+$200,x
				lda endscreendata+$2e8,x
				sta screenrow+$2e8,x
				inx
				bne displayend
				
				//Call screen colour data and place 
				//to the colour RAM
				
				ldx #$00
displayendcolour:
				ldy screenrow,x
				lda screenattribs,y
				sta colourrow,x
				ldy screenrow+$100,x
				lda screenattribs,y
				sta colourrow+$100,x
				ldy screenrow+$200,x
				lda screenattribs,y 
				sta colourrow+$200,x
				ldy screenrow+$2e8,x
				lda screenattribs,y 
				sta colourrow+$2e8,x
				inx
				bne displayendcolour
				
				//Now set the correct screen BANK 
				//charset, and multicolour mode. 
				
				lda #$02 //VIC BANK how it should be set for the game	
				sta $dd00	
				lda #$dc //Charset read $7000, and screen RAM $7c00	
				sta $d018 	
				lda #$18 //Screen multicolour ON
				sta $d016
				lda #titlebackgroundcolour
				sta $d020
				sta $d021
				lda #charmulticolour1
				sta $d022
				lda #charmulticolour2
				sta $d023
				lda #$1b
				sta $d011 		//Screen back on again
				
				lda #titlemusic
				jsr musicinit //Init title music
				
				
				//A simple raster to play music on the end
				//screen until fire has been pressed
				
endloop1:		lda #$f9
				cmp $d012
				bne *-3
				jsr pnplayer
				lda $dc00 //Check joystick port 2
				lsr		  //fire button
				lsr
				lsr
				lsr
				lsr
				bit firebutton1
				ror firebutton1
				bmi endloop2
				bvc endloop2
				jmp titlescreencode
				
endloop2:		lda $dc01
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton2
				ror firebutton2
				bmi endloop1
				bvc endloop1
				jmp titlescreencode
				
//Produce short delay for front end / game over / hi score				
				
shortdelay:		lda #0
				sta delay1 
				sta delay2
				sta $d020
				sta $d021
				lda #$7b
				sta $d011
				lda #$00
				sta $d015
delayloop:				
				inc delay1
				lda delay1
				cmp #$e0
				bne delayloop 
				lda #0
				sta delay1
				inc delay2 
				lda delay2 
				cmp #$e0 
				bne delayloop
				rts
				
flashcentr:		ldx #$00
copycolour:		lda flashstore
				sta $d800+12*40,x 
				inx 
				cpx #$28
				bne copycolour
				rts
				
				
				 
											
//Game pointers ...			

delay1: .byte 0
delay2: .byte 0

	//Firebutton depress control

firebutton1: .byte 0
firebutton2: .byte 0

	//Player 1 game starting position (Automatically stored  
	//by the one time code.  
  
player1defaultx: .byte 0				
player1defaultxmsb: .byte 0				
player1defaulty: .byte 0				

	//Player 2 game starting position	
	
player2defaultx:	.byte 0				
player2defaultxmsb: .byte 0				
player2defaulty:	.byte 0				
				
flashdelay:		.byte 0	//Delay of colour fading subroutine
flashpointer:	.byte 0 //Actual pointer of the colour fading subroutine
flashstore:		.byte 0 //Store value of flashing system
system:			.byte 0	//PAL/NTSC system storage pointer			
soundoption:	.byte 0	//Pointer for in game sounds: 0 = music, 1 = sound effects
ntsctimer:		.byte 0 //Delay to allow music to play on NTSC machines
synctimer:		.byte 0 //Sync timer loop control (Synchronise code to correct speed)				
xpos:			.byte 0 //Scroll smoothness control				
pagedelay:		.byte 0,0 //Page flipping delay, which cycles between credits and hi score				
pageno:			.byte 0 //Page value, which cycles between credits and hi-score table
FrontEndCharDelay: .byte 0
				//Scroll text colour table:
				//40 bytes, which you can edit for the scroll colour chars
				//to any colour scheme you like. 
				//
				//KEY: $00 = BLACK, $01 = WHITE, $02 = RED, $03 = CYAN
				//	   $04 = PURPLE,$05 = GREEN, $06 = BLUE,$07 = YELLOW
				
				// IF NOT USING SCREEN MULTICOLOUR:
				//     $08 = ORANGE,$09 = BROWN, $0A = PINK,$0B = DARK GREY
				//	   $0C = GREY,  $0D = LT GREEN, $0E = LT BLUE, $0F = LT GREY
				
scrollcolourtable: 		
				.byte $09,$02,$08,$0a,$07
				.byte $01,$01,$01,$01,$01
				.byte $01,$01,$01,$01,$01
				.byte $01,$01,$01,$01,$01
				.byte $01,$01,$01,$01,$01
				.byte $01,$01,$01,$01,$01
				.byte $01,$01,$01,$01,$01
				.byte $07,$0a,$08,$02,$09
				
				//Title screen flashing text (Also handy for get ready and game over texts) 
				//(MIN $00, MAX $07)
flashtable:
				.byte $00,$06,$04,$03,$01,$03,$04,$06
flashtableend:
								
								
				//Get Ready Text 
getreadytext:	
	.if (allow_getready_screen==1) {	
.text "get ready"				
}	
getreadytextend:			

	
				//Game Over Text 				
gameovertext:					
	.if (allow_gameover_screen==1) {
	.text "game over"				
	}				
gameovertextend:	

					
