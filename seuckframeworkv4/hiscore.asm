//===========================================
//
//Richard's SEUCK Game Enhancement Frame Work 
//
//          HI SCORE DETECTION
//
//============================================
			
hiscoretable:			
							
			
			//PLEASE EDIT THE LINES AND NAMES CAREFULLY 
			//TO MATCH YOUR HIGH SCORE TABLE NEEDS

			.text "              hall of fame              "
HiScoreTableStart:			
hiline1:	.text " 01. "
name1: 		.text "tnd games ................. "
hiscore1: 	.text "003800 "			
hiline2:	.text " 02. "			
name2: 		.text "tnd games ................. "			
hiscore2: 	.text "003600 "		
hiline3:	.text " 03. "		
name3: 		.text "tnd games ................. "		
hiscore3: 	.text "003400 "		
hiline4:	.text " 04. "		
name4:		.text "tnd games ................. "	
hiscore4: 	.text "003200 "	
hiline5:	.text " 05. "	
name5:  	.text "tnd games ................. "	
hiscore5: 	.text "003000 " 
hiline6:	.text " 06. "
name6:		.text "tnd games ................. "
hiscore6:	.text "002900 " 
hiline7:	.text " 07. "
name7:		.text "tnd games ................. " 
hiscore7:	.text "002600 " 
hiline8:	.text " 08. "
name8:		.text "tnd games ................. " 
hiscore8:	.text "002400 "
hiline9:	.text " 09. "
name9:		.text "tnd games ................. "
hiscore9:   	.text "002200 "
hiline10:	.text " 10. "
name10:		.text "tnd games ................. "
hiscore10:  	.text "002000 "
hiline11:	.text " 11. "
name11:		.text "tnd games ................. "
hiscore11:	.text "001800 "
hiline12:	.text " 12. "
name12:		.text "tnd games ................. "
hiscore12:	.text "001600 "
hiline13:	.text " 13. "
name13:		.text "tnd games ................. "
hiscore13:  	.text "001400 "
hiline14:	.text " 14. "
name14:		.text "tnd games ................. "
hiscore14:  .text "001300 "
hiline15:	.text " 15. "			
name15:		.text "tnd games ................. "
hiscore15:	.text "001000 "			
HiScoreTableEnd:
fireprompt:  //.text "----------------------------------------"
			.text "          - press fire to play -           "
hiscoremessage1:			
			.text "well done, you have achieved a hi score!"
hiscoremessage2:
			.text    "    please enter your name player "
playerno:	.text    "1!    "

			
//-----------------------------------------------------------------------------------
//Hi score check routine, which reads the current scores, and then 		
//checks if the values of the score are lower or higher than the high scores		
//-----------------------------------------------------------------------------------		
scoretohiscorecheck:		lda #0
				sta namefinished		
				lda #titlemusic
				jsr musicinit //Do title music init again
				
				//Corresponds to game complete and game over	
				//sequences. High score setup	
					
				//First converts player score pointers to 	
				//score digits	
hiscoresetup:				
				ldx #$00
convertscores:	lda $5ea3,x //Player 1's score data
 				clc
 				adc #$30	//Convert to digits
				sta scorep1,x
				lda $5ea9,x //Player 2's score data
				clc
				adc #$30
				sta scorep2,x
				inx
				cpx #6
				bne convertscores
				
				//Copy player 1's score to score pointer
				//then call hi score check subroutine to
				//examine the position of where the player
				//has its final score.
				
				ldx #$00
copyp1score:	lda scorep1,x
				sta score,x
				inx
				cpx #6
				bne copyp1score
				lda #$31 //Assign number character '1'
				sta playerno //Store it to player value
				lda #$00 //Assign self-mod byte joystick port 2 for player 1
				sta joyport+1 //and override joystick port check
				sta hi_fire+1
				jsr hiscorecheckroutine //Main hiscore check routine
				
				//Do the same as above for player 2 (if your game	
				//is a 2 player game as well as 1 player game. 	
				//Then call hi score check subroutine to examine	
				//the position where the player has its final score.	
				
				lda #0				//Reset the name finished routine.
				sta namefinished		
						
				ldx #$00
copyp2score:	lda scorep2,x
				sta score,x
				inx
				cpx #6
				bne copyp2score
				lda #$32 //Assign number character '2'
				sta playerno //Store it to player value
				lda #$01 //Assign self-mod byte joystick port 1 for player 2
				sta joyport+1 //and override joystick port check
				sta hi_fire+1
				jsr hiscorecheckroutine //Main hi score check routine again
				jmp titlescreencode			//Then restart front end
				
hiscorecheckroutine:				
				
			        ldx #$00
nextone:            lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
										
									
                    ldy #$00
scoreget:           lda score,y
scorecmp:           cmp ($c1),y
                    bcc posdown
                    beq nextdigit
                    bcs posfound
nextdigit:          iny
                    cpy #scorelen
                    bne scoreget
                    beq posfound
posdown:            inx
                    cpx #listlen
                    bne nextone
                    beq nohiscor
posfound:           stx $02
                    cpx #listlen-1
                    beq lastscor
																			
                    ldx #listlen-1
copynext:           lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
                    lda nmlo,x
                    sta $d1
                    lda nmhi,x
                    sta $d2
                    dex
                    lda hslo,x
                    sta $c3
                    lda hshi,x
                    sta $c4
                    lda nmlo,x
                    sta $d3
                    lda nmhi,x
                    sta $d4
										//Copy the scores from one zero page to 
										//another. (which acts as a temp zp)
                    ldy #scorelen-1
copyscor:           lda ($c3),y
                    sta ($c1),y
                    dey
                    bpl copyscor 
										//Do the same with the name. Since the names should move 
										//if a position is found.
                    ldy #namelen+1
copyname:           lda ($d3),y
                    sta ($d1),y
                    dey
                    bpl copyname
                    cpx $02
                    bne copynext
										
lastscor:           ldx $02
                    lda hslo,x
                    sta $c1
                    lda hshi,x
                    sta $c2
                    lda nmlo,x
                    sta $d1
                    lda nmhi,x
                    sta $d2
                    jmp nameentry
placenewscore:											
                    ldy #scorelen-1
putscore:            lda score,y
                    sta ($c1),y
                    dey
                    bpl putscore		
                    ldy #namelen-1
putname:             lda name,y
                    sta ($d1),y 
                    dey
                    bpl putname
					jsr SaveHiScore
nohiscor:			rts
								
				//Main name entry subroutine - controlled using joystick in								
				//either port.								
nameentry:												
												
				ldx #$00								
clearscreenagain:								
				lda #$20								
				sta screenrow,x								
				sta screenrow+$100,x								
				sta screenrow+$200,x								
				sta screenrow+$2e8,x								
				inx								
				bne clearscreenagain								
												
				//Copy hi score message to screen								
												
				ldx #$00								
putwelldonetext:								
				lda hiscoremessage1,x								
				sta screenrow+9*40,x								
				lda hiscoremessage2,x								
				sta screenrow+11*40,x								
				lda #$03								
				sta colourrow+9*40,x								
				lda #$07								
				sta colourrow+11*40,x								
				inx								
				cpx #40								
				bne putwelldonetext								
				//$7e3f								
				ldx #$00								
clearname:		lda #$20								
				sta name,x 								
				inx								
				cpx #9								
				bne clearname								
 								
												
				//Set character A to selected char for name entry
				lda #1
				sta $04
				
				//Reset the joystick delay
				
				lda #0
				sta joydelay
				
				//Init character position for the name
				
				lda #<name
				sta sm+1
				lda #>name
				sta sm+2
				
				ldx #$00
clearsid:		lda #$00
				sta $d400,x
				inx
				cpx #$18
				bne clearsid
				
				//Raster loop
				
nameentryloop:				
				lda #$f9
				cmp $d012
				bne *-3
				
				jsr flashroutine	//Flashing text routine
				jsr paintpressfire  //Routine to flash press fire text	
				jsr flashname
				jsr pnplayer		//PAL/NTSC music player for player name entry
				
				
				//Display the initials self-modified by joystick				
								
				ldx #$00				
showname:		lda name,x				
				sta $763f,x 				
				inx				
				cpx #9				
				bne showname				
								
				lda namefinished //Check if name entry finished				
				cmp #1				
				beq stopnameentry //Yes, finished				
				jsr joycheck	  //else check joy control				
				jmp nameentryloop //or just loop				
								
stopnameentry:								
				//Back to placing player name and high score rank								
				jmp placenewscore								
												
				//Joystick check routine								
												
joycheck:		lda hi_char 	//Self-mod character												
								//is stored to self-mod name pointer												
sm:				sta name												
				lda joydelay	//delay joystick a little												
				cmp #4			//delay should be okay here												
				beq joyhiok												
				inc joydelay	//Wait												
				rts												
																
joyhiok:												
				lda #0												
				sta joydelay												
																
				//check joy up												
joyport:																		
hi_up:			lda $dc90	//Self-mod joystick port												
				lsr												
				bcs hi_down												
				inc hi_char												
				lda hi_char												
				//Check for special characters (Up arrow / Back Arrow / Space)												
				cmp #27 //Char 27 = illegal char, force RUB/DELETE char 
				beq delete_char
				cmp #$21 //Char after space - illegal char												
				beq a_char												
				rts												
																
				//Check joy down												
																
hi_down:		lsr 												
				bcs hi_fire												
																
				//Move character down one byte												
				dec hi_char												
																
				//Check for special characters										
				lda hi_char										
				cmp #$00 //Char before letter A (@) = Illegal char										
				beq space_char //Make into space char																	
				cmp #29 //Another illegal char (before delete) 
				beq z_char		//Make into z 										
		
				rts										
														
				//Make char delete					
delete_char:	lda #30					
				sta hi_char					
				rts 					
									
				//Make char spacebar										
space_char:											
				lda #$20										
				sta hi_char										
				rts										
														
				//Make char letter A										
														
a_char:			lda #1										
				sta hi_char										
				rts										
														
				//Make char letter Z										
														
z_char:			lda #26								
				sta hi_char										
				rts										
														
				//Check fire button on joystick port 2										
														
hi_fire:		lda $dc00														
				lsr
				lsr
				lsr
				lsr
				lsr
				bit firebutton1
				ror firebutton1
				bmi hi_nofire
				bvc hi_nofire
				
				
				//Fire has been pressed. Check whether or not
				//the DELETE char is displayed. If it is, then
				//automatically SPACE the character, and subtract
				//the name position by one character.
				
				lda hi_char
				cmp #30 //Char (Up arrow representing DELETE char (Cross)
				bne checkendchar
				
				//Char delete spotted, so go back one character
				//then delete the delete chars
				lda sm+1
				cmp #<name
				beq donotgoback
				dec sm+1
				jsr cleanupname
donotgoback:				
				rts
checkendchar:			
				cmp #31 //Char (Back arrow indicating end char) (Tick)			
				bne charisok			
							
				//Char end spotted, so force end 
				lda #$20
				sta hi_char
				jmp finished_now
	 
				
charisok:				
				
				//Move to next
				//character in the player's initials 
				
				inc sm+1
				//Check if name length has expired 
				lda sm+1
				cmp #<name+9
				//Yes name is finished
				beq finished_now
				//Reset fire button 
				lda #0
				sta firebutton1
hi_nofire:
				rts
				
				//Trigger name entry finished
finished_now:	jsr cleanupname				
				lda #1
				sta namefinished
				rts
				
				//Clear name with illegal chars (Tick+Cross)				
cleanupname:								
				ldx #$00				
clearchars:		lda name,x 				
				cmp #30				
				beq cleanup				
				cmp #31				
				beq cleanup		
				jmp skipcleanup		
cleanup:		lda #$20		
				sta name,x		
skipcleanup:	inx		
				cpx #namelen		
				bne clearchars		
				rts		
			
			
			
flashname:		ldx #$00
flashnameloop:	lda flashstore
				sta $da3f,x 
				inx 
				cpx #9
				bne flashnameloop
				rts
//------------------------------------------------------------------------------																				 			

//Hi score table properties ...
			
joydelay: .byte $00				
namefinished: .byte 0
hi_char:		.byte $01				
score:			.byte $30,$30,$30,$30,$30,$30 //Final score copied from either player
scorep1:		.byte $30,$30,$30,$30,$30,$30 //Final score Player 1
scorep2:		.byte $30,$30,$30,$30,$30,$30 //Final score Player 2
				.align $100
name:			.text "         "				
nameend:				
				
				
//Hi score table pointers				

hslo:			.byte <hiscore1,<hiscore2,<hiscore3,<hiscore4,<hiscore5				
				.byte <hiscore6,<hiscore7,<hiscore8,<hiscore9,<hiscore10				
				.byte <hiscore11,<hiscore12,<hiscore13,<hiscore14,<hiscore15				
								
hshi:			.byte >hiscore1,>hiscore2,>hiscore3,>hiscore4,>hiscore5				
				.byte >hiscore6,>hiscore7,>hiscore8,>hiscore9,>hiscore10				
				.byte >hiscore11,>hiscore12,>hiscore13,>hiscore14,>hiscore15				
								
//Name pointers								

nmlo:			.byte <name1,<name2,<name3,<name4,<name5								
				.byte <name6,<name7,<name8,<name9,<name10								
				.byte <name11,<name12,<name13,<name14,<name15						
												
nmhi:			.byte >name1,>name2,>name3,>name4,>name5								
				.byte >name6,>name7,>name8,>name9,>name10								
				.byte >name11,>name12,>name13,>name14,>name15								

				#import "disksave.asm"
 
			 
 
		 	
						
 