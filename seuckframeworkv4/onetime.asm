//===========================================
//
//Richard's SEUCK Game Enhancement Frame Work 
//
//          ONE TIME INSTALLATION
//
//============================================


onetime:		
				sei				
				

				//System type PAL or NTSC 
				
				lda $02a6
				sta system	//Store to system type byte 
				
				cmp #$01
				beq palscore
								
				//Game is running on NTSC machines, so
				//shift the score panel position so that
				//when playing a SEUCK game, it can be 
				//displayed on screen.
				
				
				ldx #$00
shiftscorepanel:
				lda #$ff  //Y position of score panel 
				sta $5eaf,x 
				inx
				inx
				cpx #$12
				bne shiftscorepanel
		
palscore:		//If PAL, or score panel shifted, nothing
				//needs to be done.
						
				lda #$35	//Disable kernal
				sta $01
				
				//One time char invert for status panel. Sometimes
				//the SEUCK games may accidentally invert the status
				//panel font. If it does, change EOR code to $ff
				//otherwise leave it as $00
								
				ldx #$00				
invert:			lda $f400,x 				
				eor #eorcode				
				sta $f400,x				
				lda $f500,x				
				eor #eorcode				
				sta $f500,x				
				lda $f600,x			
				eor #eorcode			
				sta $f600,x			
				inx				
				bne invert				
											
				///Install the game loop in game enhancements				
				//This basically replaces the play SFX code,				
				//with a new custom piece of code. The new code				
				//has SFX play at the end of the subr routine.				
								
				lda #<enhancements
				sta gameloop+1
				lda #>enhancements
				sta gameloop+2
				
				//Initialise scores for both players (Zero all)
				//We don't need to do this for lives.
				
				ldx #$00
initscore:		lda #$00
				sta player1score,x
				sta player2score,x
				inx
				cpx #6
				bne initscore
				
				//Memory overwrite at $8000 makes random firing enemies 
				//fire to the right of the screen. This next piece of
				//code fixes this.
				
				lda #$50 //Random shooting enemy update.
				sta $54f1
				
				//Just in case you left the editor into the game.
				//this allows restore to return to the front end
				//instead of crash the game.
				
				lda #$00
				sta 16964
				
				//Setup program to force a jump to the new title screen
				//for the game.

				lda #$4c //Call JUMP command
				sta $40dd
				lda #<titlescreencode
				sta $40de
				lda #>titlescreencode
				sta $40df
				
				//Optional - Instead of the game looping, a subroutine
				//which runs an end screen to the game
				
				lda #$4c 
				ldx #<endscreen
				ldy #>endscreen
				sta $47a1
				stx $47a2
				sty $47a3
										
				//Instead of waiting for the game to end after losing the last life 
				//force code to run the game over screen. 
				
				lda #$4c 
				ldx #<gameoverscreen
				ldy #>gameoverscreen 
				sta $42bf
				stx $42c0
				sty $42c1
				
				//Fix SEUCK scoring bug, where in SEUCK the wrong 
				//player seems to get the points after picking up
				//a collectable object. This patch fixes the problem.
				
				lda #$4c
				ldx #<scorebugfix
				ldy #>scorebugfix
				sta $54a2
				stx $54a3
				sty $54a4							
		
				//Always a good idea to stabilize the horizontal scrolling 
				//SEUCK scroll engine, by enabling this fix up
				
.if (fix_horizontal_scroll_routine == 1) {
				
				lda #$20
				ldx #<fixscroll
				ldy #>fixscroll
				sta $44f4
				stx $44f5
				sty $44f6
}
				
				//Zero scores for both players as default					
									
				ldx #0
zeroscores:
				lda #$00
				sta $5ea3,x
				sta $5ea9,x
				inx
				cpx #6
				bne zeroscores
											
				//Install safe respawn routines - where the player's 
				//life lost has been backed up for same place respawn
				//Comment out with // if your game does not need this

				lda #$20
				ldx #<lifelostplayer1
				ldy #>lifelostplayer1
				sta $4b0f
				stx $4b10
				sty $4b11
				
				lda #$20
				ldx #<lifelostplayer2
				ldy #>lifelostplayer2
				sta $4e1e
				stx $4e1f
				sty $4e20
.if (allow_player_safe_respawn ==1) {								
			    lda $40a3			
				sta player1backupx			
				lda $40a4			
				sta player1backupxmsb			
				lda $40a5			
				sta player1backupy			
						
				lda $40b6		
				sta player2backupx		
				lda $40b7		
				sta player2backupxmsb	
				lda $40b8	
				sta player2backupy						
									
}									
				//Install object detection routine, in order 								
				//for the game to be able to check for enemy 
				//boss objects to trigger full explosion effect 
				
				lda #$20
				ldx #<killcheck
				ldy #>killcheck
				sta $55c3
				stx $55c4
				sty $55c5 								
			
			
				//Shield respawn code for player 1 and player 2 
				//if killed or starting a new game ...  This will 
				//be active IF the shield feature has been enabled 
				
.if (allow_shield ==1) {
					lda #$20 //New respawn code player 1
                    ldx #<ShieldRespawnCodeP1
                    ldy #>ShieldRespawnCodeP1
                    sta $4b6c
                    stx $4b6d
                    sty $4b6e
                    
                    lda #$20 //New respawn code player 2
                    ldx #<ShieldRespawnCodeP2
                    ldy #>ShieldRespawnCodeP2 
                    sta $4e7c
                    stx $4e7d 
                    sty $4e7e 
}
//-----------------------------------------------------------------------			
				//(For 1 player games only) Central player score panel 
				//If not needed. Just add a // next to the whole routine
				//between the marker.
				
.if (linked_player_mode == 1)				
{
					ldx #$00  
CentrePlot:		 lda PlotTable,x
				sta $5eaf,x
				lda #$55
				sta $5eb7,x
				inx
				cpx #$09
				bne CentrePlot 				
}				
//------------------------------------------------------------------------											
												
												
//Finally check if game mode can use multi-colour sprites 

.if (scorepanel_multicolour==1) {
				lda #$ff
				sta $4565
				lda #$35
				sta $01
				//Copy the custom multicolour score panel to the status 
				//panel 
				ldx #$00
copycustomfont:	
				lda statuspanel,x
				sta $f400,x 
				lda statuspanel+$100,x
				sta $f500,x 
				inx 
				bne copycustomfont
}
				
				//Now start SEUCK program with new settings.
				
							lda #$20
                            sta $4566
                            lda #<SprBITS1
                            sta $4567
                            lda #>SprBITS1
                            sta $4568

				// Add a '//' next to jsr LoadHiScores if you are using 
				// the title screen with a multicolour bitmap logo 
				
							jsr LoadHiScores
							
						
							jmp $4245
				
//----------------------------------------------------------------------------				
							//DO NOT CHANGE THIS !!!
SprBITS1:					lda #0
							sta $d017
							sta $d01d
							lda #0
							sta $d01b
							rts
//-----------------------------------------------------------------------------							
							
							//Sprite expansion mode
SprBITS2:					lda #sprite_expansion_mode_y
							sta $d017
							lda #sprite_expansion_mode_x
							sta $d01d
							//Sprite behind background 
							lda #sprite_behind_background
							sta $d01b
							rts							
							
				
				//Add the little SEUCK scoring bug fix patch, where player 1 accidentally
				//score points when player 2 should have the points if collecting a
				//specific object.
scorebugfix:				
				sta $5dbb
				lda #$00
				sta $09
				jmp $54a5 
	
//Centre's the score panel
	
PlotTable:    .byte $03,$89,$07,$a1,$07,$b9,$07,$d1,$07,$d9				