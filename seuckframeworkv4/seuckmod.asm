//================================================
// S.E.U.C.K with custom char and raster splits
// framework by Richard Bayliss
// ----------------------------------------------- 
// Format: KickAssembler 
//
// Assembling: java -jar "c:\path\kickass.jar" seuckmod.asm
//
// Crunching: exomizer sfx $0800 seuckmod.prg -o nameofgame.prg -x1
//=================================================

.var title_music_init = $9000 //Title music initialise
.var title_music_play = $9003 //Title music play address
.var game_music_init = $a000  //In game music initialise 
.var game_music_play = $a003  //In game music play
.var scrollspeed = $02		  //Speed of scrolling message 
.var rasterspeed = $03        //Speed of scrolling rasters 
.var endcolour = 1			  //Set value of colour for ending
.var option_music_char = 60		//Char value for displaying music 
.var option_sfx_char = 62		//Char value for displaying sfx

//==================================================
//
// One time initialization code, after Exomizer has
// been called after decrunching.
//
// This will set up the new code to be called for
// the title screen.
//==================================================

	* = $0400 "One Time"
	
	sei 
	lda #$35
	sta $01 //There may be a case where the charset
			//status panel may need to be inverted
			//this code fixes this.
			
	ldx #$00
fillsc:
	lda #$00
	sta $5ea3,x 
	sta $5ea9,x
	inx 
	cpx #$06
	bne fillsc
			
	ldx #$00
invert:
	lda $f400,x 
	eor #$ff
	sta $f400,x 
	lda $f500,x 
	eor #$ff 
	sta $f500,x 
	lda $7800,x 
	eor #$ff
	sta $7800,x 
	lda $7900,x 
	eor #$ff 
	sta $7900,x 
	lda $7a00,x 
	eor #$ff 
	sta $7a00,x 
	lda $7b00,x 
	eor #$ff
	sta $7b00,x
	inx 
	bne invert
	
	//Overwrite the characters < and > (60 and 62) with the music/sfx charset 
	
	ldx #$00
makenew:
	lda musicchar,x 
	eor #$ff
	sta 60*8+$7800,x 
	lda sfxchar,x 
	eor #$ff
	sta 62*8+$7800,x
	inx
	cpx #8 	//Each char row consists of 8 bits
	bne makenew
	
	//Repair random firing enemies code
	
	lda #$50
	sta $54f1 
	
	//Trigger new front end code 
	
	lda #$4c
	ldx #<FrontEnd 
	ldy #>FrontEnd 
	sta $40dd
	stx $40de 
	sty $40df 
	
	//Trigger end screen code 
	
	lda #$4c
	ldx #<EndScreen
	ldy #>EndScreen 
	sta $47a1
	stx $47a2
	sty $47a3 
	
	//Restore C64 KERNAL then jump 
	//to SEUCK game run address
	
	lda #$2c	//Disables all interrupting sound		
	sta $5c0d	//effects, by planting BIT instead
	sta $5c10	//of LDA. So that while in game music
	sta $5c13	//is playing in the background. There
	sta $5c18	//are no major interuptions.
	sta $5c24		
	sta $5c27		
	sta $5c2a		
	sta $5c2f		
	sta $5c52		
	sta $5c55
	sta $5c58		
	ldx #<game_music_play
	ldy #>game_music_play
	stx $4504
	sty $4505
	
	lda #$37
	sta $01
	cli 
	jmp $4245
	
//--------------------------------------------

//Import the first segment of the SEUCK game 
//data $0900-$6580 

			* = $0900 "SEUCK Game Data 1"
			
			.import c64 "c64\seuckdata1.prg"
			
//---------------------------------------------
// Title Screen Code
//---------------------------------------------			

FrontEnd:		
			lda #$35
			sta $01
			sei 
			jsr ClearAllInterrupts
			
			ldx #$00
copyscore:
			lda $5ea3,x 
			clc
			adc #$30
			sta player1score,x 			
			
			//-----------------------------
			//Only enable if for 2 players 
			
			lda $5ea9,x 
			clc
			adc #$30
			sta player2score,x 
			
			inx 
			cpx #6
			bne copyscore 
			
			//-----------------------------
			
calchiscore:
			lda player1score 
			sec 
			lda hiscore+5
			sbc player1score+5
			lda hiscore+4
			sbc player1score+4
			lda hiscore+3
			sbc player1score+3
			lda hiscore+2
			sbc player1score+2
			lda hiscore+1
			sbc player1score+1
			lda hiscore 
			sbc player1score
			
			//Only enable and replace bpl nohi if for 2 players 
			
			bpl checkhiplayer2 
			//bpl nohi
			ldx #$00
p1hi:		lda player1score,x 
			sta hiscore,x 
			inx 
			cpx #6
			bne p1hi 

//Only enable if the game is for 2 players
			
checkhiplayer2:			
			lda player2score 
			sec 
			lda hiscore+5
			sbc player2score+5
			lda hiscore+4
			sbc player2score+4
			lda hiscore+3
			sbc player2score+3
			lda hiscore+2
			sbc player2score+2
			lda hiscore+1
			sbc player2score+1
			lda hiscore 
			sbc player2score 
			bpl nohi
			
			ldx #$00
p2hi:		lda player2score,x 
			sta hiscore,x 
			inx 
			cpx #6
			bne p2hi
			
nohi:			
			
			
			//Copy raster colours to store value 
			
			ldx #$00
copyrasters:
			lda rascol1,x 
			sta rasstore1,x 
			
			inx 
			cpx #80
			bne copyrasters
			
			//Draw title screen text 
			
			ldx #$00
drawtext:	lda titlescreen,x 
			sta $7c00,x 
			lda titlescreen+$100,x 
			sta $7d00,x 
			lda titlescreen+$200,x 
			sta $7e00,x 
			lda titlescreen+$2e8,x
			sta $7ee8,x
			lda #0
			sta $d800,x 
			sta $d900,x 
			sta $da00,x 
			sta $dae8,x 
			inx 
			bne drawtext
			
			//Copy score text to screen 
			
			ldx #$00
putscor:	lda scoretext,x 
			sta $7c00,x 
			inx 
			cpx #$28
			bne putscor
			
			//Initialisde interrupt IRQs
			
			lda #1
			sta $d021
			lda #0
			sta $d020
			
			ldx #<irq
			ldy #>irq
			
			stx $fffe 
			sty $ffff
			lda #$7f
			sta $dc0d 
			sta $dd0d 
			lda #$00
			sta $d012
			lda #$1b
			sta $d011 
			lda #$01
			sta $d01a
			lda #$00
			jsr title_music_init
			lda #<message
			sta messread+1 
			lda #>message 
			sta messread+2
			cli 
			jmp *
			

//--------------------------------------------------------------------------------------
						
//Setup up IRQ interrupts for the title screen

irq:		pha 
			txa 
			pha 
			tya 
			pha 
			inc $d019 
			lda $dc0d
			sta $dd0d
			lda #$00
			sta $d012
			jsr title_music_play
			jsr raster_bars 
			jsr scroll_message
			jsr raster_bar_scroll
			jsr checkjoystick
			jsr checksoundoption
			pla 
			tay 
			pla 
			tax 
			pla 
			rti

//--------------------------------------------------------------------------------------
						
//Raster bar code

raster_bars:
			lda #$3a
			cmp $d012 
			bne *-3 
			lda #$08
			sta $d016
		
			ldy $d012 
			ldx #54
loop:		lda rasstore1,x 
			cpy $d012 
			beq *-3 
			sta $d021 
			iny 
			dex 
			bpl loop 
			ldx #$08
			dex
			bne *-1
			
			ldy $d012 
			ldx #55
loop2:		lda rasstore1,x 
			cpy $d012 
			beq *-3
			sta $d021
			iny 
			dex 
			bpl loop2
			ldx #$08
			dex 
			bne *-1
			
			
			
			
			ldy $d012 
			ldx #58
loop3:		lda rasstore1,x 
			cpy $d012 
			beq *-3
			sta $d021 
			iny 
			dex
			bpl loop3
			ldx #$08
			dex 
			bne *-1
			
			lda xpos 
			sta $d016
			lda #$fa 
			cmp $d012 
			bne *-3 
			lda rasstore1+72 
			sta $d021 
			lda #$08
			sta $d016
			rts 
			

//--------------------------------------------------------------------------------------
						
//Scroll text code
				
scroll_message:
			lda xpos 
			sec 
			sbc #scrollspeed 
			and #7
			sta xpos 
			bcs endscroll
			ldx #$00
shift:		lda $7fc1,x 
			sta $7fc0,x 
			inx 
			cpx #$27
			bne shift 
messread:	lda message
			cmp #$00
			bne mess_store
			lda #<message
			sta messread+1
			lda #>message
			sta messread+2
			jmp messread 
			
mess_store: sta $7fe7 
			inc messread+1
			bne endscroll 
			inc messread+2 
endscroll:	rts 


//--------------------------------------------------------------------------------------
			

//Scroll those raster bars 

raster_bar_scroll:
			lda colourdelay 
			cmp #rasterspeed
			beq scrollcolour
			inc colourdelay
			rts 
scrollcolour:
			lda #0
			sta colourdelay 
			lda rasstore1 
			pha 
			ldx #$00
shiftup:	lda rasstore1+1,x 
			sta rasstore1,x 
			inx 
			cpx #80
			bne shiftup 
			pla 
			sta rasstore1+79
			rts
			

//--------------------------------------------------------------------------------------	
			
//Check joystick before start game 

checkjoystick:
			lda $dc00
			lsr
			lsr
			lsr
			bcs right1
			lda #0
			sta soundoption
			jmp checkjp1
right1:					
			lsr 
			bcs fire01
			lda #1
			sta soundoption
			jmp checkjp1 
fire01:		lsr 
			bit firebutton
			ror firebutton
			bmi checkjp1
			bvc checkjp1 
			jmp setupgame1
			
checkjp1:	lda $dc01 
			lsr 
			lsr 
			lsr 
			bcs right2
			lda #0
			sta soundoption
			jmp nopush 
right2:				
			lsr 
			bcs fire2
			lda #1
			sta soundoption 
			jmp nopush
fire2:			
			lsr 
			bit firebutton 
			ror firebutton 
			bmi nopush
			bvc nopush 
			jmp setupgame2 
			
nopush:		rts 


//----------------------------------------------------------------------------------
//Setup game 1 - Player joystick port 2 starts 
//a 2 player game can be played, IF while player 
//1 is in the game, player 2 can join (if enabled in SEUCK)

//lda #0 = disabled
//lda #1 - enabled

setupgame1:
				lda #1 //Enable or Disable player 1
				sta $40af //Player 1
				lda #0 //Enable or Disable player 2
				sta $40c2 //Player 2 
				jsr ClearAllInterrupts
				lda #0
				jsr game_music_init
				jmp $4260

//Setup game 2 - Player joystick port 1 starts a 
//1 player game. Only 1 player is allowed on screen			

setupgame2:
				lda #0 //Enable or disable player 1
				sta $40af //Player 1
				lda #0 //Enable or disable player 2
				sta $40c2 //Player 2 
				jsr ClearAllInterrupts
				lda #0
				jsr game_music_init
				jmp $4260
			
//--------------------------------------------------------------------------------------
			
//Check game sound option 

checksoundoption:

			
				lda soundoption
				cmp #1
				beq sfxoption
musicoption:
				lda #$2c	//Disables all interrupting sound		
				sta $5c0d	//effects, by planting BIT instead
				sta $5c10	//of LDA. So that while in game music
				sta $5c13	//is playing in the background. There
				sta $5c18	//are no major interuptions.
				sta $5c24		
				sta $5c27		
				sta $5c2a		
				sta $5c2f		
				sta $5c52		
				sta $5c55
				sta $5c58		
				ldx #<game_music_play
				ldy #>game_music_play
				stx $4504
				sty $4505
				
				lda #option_music_char 
				sta $7c4f
				
	
				rts 
			
sfxoption:		lda #$8d
				sta $5c0d
				sta $5c10
				sta $5c13
				sta $5c24
				sta $5c27
				sta $5c2a
				lda #$9d
				sta $5c2f
				sta $5c52
				sta $5c55
				sta $5c58
				ldx #$94
				ldy #$5c
				stx $4504
				sty $4505
	
				lda #option_sfx_char 
				sta $7c4f
				
				
				rts
				
//-----------------------------------------------------				
						
//Game end screen 

EndScreen:
			lda #$35
			sta $01 
			sei 
			lda #$00
			sta $dc02 
			lda #$ff
			sta $dc03
			jsr ClearAllInterrupts
			ldx #$00
putendtexttoscreen:
			lda endscreen,x 
			sta $7c00,x 
			lda endscreen+$100,x 
			sta $7d00,x 
			lda endscreen+$200,x 
			sta $7e00,x 
			lda endscreen+$2e8,x 
			sta $7ee8,x 
			lda #0
			sta $d800,x 
			sta $d900,x 
			sta $da00,x 
			sta $dae8,x 
			inx 
			bne putendtexttoscreen
			
			lda #$02 
			sta $dd00
			lda #$fe  
			sta $d018 
			lda #$08
			sta $d016 
			lda #endcolour
			sta $d021 
			lda #0
			sta $d020
			lda #$1b
			sta $d011 
			lda #0
			sta $d012
			lda #0
			sta firebutton
			ldx #<endirq
			ldy #>endirq 
			stx $fffe 
			sty $ffff 
			lda #$7f 
			sta $dc0d 
			lda #$2e 
			sta $d012 
			lda #$1b
			sta $d011 
			lda #$01
			sta $d01a 
			lda #$00
			jsr title_music_init
			cli 
			jmp *
			
endirq:
			pha 
			txa 
			pha
endloop:	tya 
			pha 
			inc $d019 
			lda $dc0d 
			sta $dd0d
			jsr endrasters 
			jsr raster_bar_scroll
			jsr title_music_play
			jsr joycheck
			pla 
			tay
			pla 
			tax 
			pla 
			rti
endrasters:			
			lda #$3a
			cmp $d012 
			bne *-3 
			lda #$08
			sta $d016
		
			ldy $d012 
			ldx #54
eloop:		lda rasstore1,x 
			cpy $d012 
			beq *-3 
			sta $d021 
			iny 
			dex 
			bpl eloop 
			ldx #$08
			dex
			bne *-1
			
			ldy $d012 
			ldx #55
eloop2:		lda rasstore1,x 
			cpy $d012 
			beq *-3
			sta $d021
			iny 
			dex 
			bpl eloop2
			ldx #$08
			dex 
			bne *-1
			
			ldy $d012 
			ldx #58
eloop3:		lda rasstore1,x 
			cpy $d012 
			beq *-3
			sta $d021 
			iny 
			dex
			bpl eloop3
			ldx #$08
			dex 
			bne *-1
			
			lda #$fa 
			cmp $d012 
			bne *-3 
			lda rasstore1+72 
			sta $d021 
			lda #$08
			sta $d016
			
			rts
			
joycheck:			
			lda $dc00
			lsr
			lsr
			lsr
			lsr
			lsr 
			bit firebutton
			ror firebutton
			bmi endloop2
			bvc endloop2
			jmp FrontEnd
			
endloop2:	lda $dc01 
			lsr 
			lsr 
			lsr 
			lsr 
			lsr 
			bit firebutton 
			ror firebutton 
			bmi endloop3
			bvc endloop3 
			jmp FrontEnd 
endloop3:	rts						
			

//--------------------------------------------------------------------------------------
			
//Clear out all of the interrupts that were 
//originally playing in the game

ClearAllInterrupts:
			
			ldx #$48
			ldy #$ff
			stx $fffe
			sty $ffff
			lda #$00
			sta $d019
			sta $d01a 
			lda #$81
			sta $dc0d 
			sta $dd0d
			lda #$0b	
			sta $d011
			ldx #$00
clearsid:   lda #$00
			sta $d400,x 
			inx 
			cpx #$18
			bne clearsid 
			lda #$08
			sta $d016
			lda #$02
			sta $dd00
			lda #$fe
			sta $d018
			lda #0
			sta $d015
			sta firebutton
			rts
			
//Pointers 

//--------------------------------------------------------------------------------------
			
xpos:		.byte 0 
colourdelay: .byte 0 
firebutton: .byte 0



//scoretext:	.text "last score: "
//player1score: .text "000000      hi score: "
//hiscore:    .text "000000"

//If your game is for 2 players, // the above, and remove //
//for below.

scoretext: .text"1up "
player1score: .text "000000      2up "
player2score: .text "000000     hi "
hiscore: .text "000000"

soundoptiontext:
			.text "in game sound option:                          "
music: .text "music"
sfx:	 .text "  sfx"
soundoption: .byte 0

musicchar:
				.byte %00001100
				.byte %00001110
				.byte %00001101
				.byte %00001100
				.byte %00111100
				.byte %01111100
				.byte %00111000
				.byte %00000000
musiccharend:

sfxchar:		.byte %00100100				
				.byte %01000110
				.byte %10101111
				.byte %10101111
				.byte %10101111				
				.byte %01000110
				.byte %00100100
				.byte %00000000
sfxcharend:				

//--------------------------------------------------------------------
//Raster colour table ... You may edit these . Max no of bytes to 
//edit = 80
//--------------------------------------------------------------------			

rascol1:	.byte $0b,$0b,$0c,$0c,$0f,$0f,$01,$01
			.byte $0f,$0f,$0c,$0c,$0b,$0b,$00,$00
			.byte $06,$06,$0e,$0e,$03,$03,$01,$01
			.byte $03,$03,$0e,$0e,$06,$06,$00,$00
			.byte $09,$09,$05,$05,$0d,$0d,$01,$01
			
			.byte $0d,$0d,$05,$05,$09,$09,$00,$00
			.byte $02,$02,$0a,$0a,$07,$07,$01,$01
			.byte $07,$07,$0a,$0a,$02,$02,$00,$00
			.byte $09,$09,$08,$08,$07,$07,$01,$01
			.byte $07,$07,$08,$08,$09,$09,$00,$00
			
//---------------------------------------------------------------------
//raster storing ... Backup for colour rolling 
//DO NOT EDIT!
rasstore1:
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			.byte $00,$00,$00,$00,$00,$00,$00,$00
			
//---------------------------------------------			
			
//---------------------------------------------

//Import Front End Screen Data


			*=$7000 "Front End Screen Data"
titlescreen:			
			.import binary "c64/front_end_screen_v3.bin"
//---------------------------------------------

//Import End Screen data

			* = $7400 "End Screen Data"
endscreen:			
			.import binary "c64/end_screen_v3.bin"

//---------------------------------------------

//Title screen charset 

			* = $7800 "Front End Char Set"
			.import binary "c64/front_end_charset_v3.bin"
			
//---------------------------------------------

//Import scroll text 
			* = $8000 "Scroll Text"
message:	.import text "scrolltext.txt"	
		.byte 0			
//---------------------------------------------

//Import title Music 
			* = $9000 "Title Music"
			.import c64 "c64/titlemusic.prg"
			
//----------------------------------------------

//Import game Music 
			* = $a000 "Game Music" 
			.import c64 "c64/ingamemusic.prg"

//----------------------------------------------

//Import final segment of SEUCK data 

			*=$b6c0 
			.import c64 "c64/seuckdata2.prg"
			
//----------------------------------------------			


			