//Hi-score saver/loader routine
//for Let's invade

dname:	.text "S:"
fname:	.text "HIGH SCORES"
.const fnamelen = *-fname
.const dnamelen = *-dname


SaveHiScore:
			jsr DisableInts 
			jsr savefile
			lda #$35 
			sta $01
SkipHiScoreSaver:
			jmp titlescreencode
			
LoadHiScores:
			jsr DisableInts 
			jsr loadfile
SkipHiScoreLoader:
			jmp titlescreencode
			
DisableInts:
			sei 
			lda #0
			sta $02a1
			sta $9d
			lda #$48 
			sta $fffe 
			lda #$ff 
			sta $ffff 
			lda #$31
			sta $0314
			lda #$ea
			sta $0315
			lda #0
			sta $d019 
			sta $d01a 
			sta $d015 
			lda #$81 
			sta $dc0d
			sta $dd0d 
			ldx #$00 
clrsid:		lda #0 
			sta $d400,x
			inx
			cpx #$18 
			bne clrsid 
			lda #$0b 
			sta $d011 
			lda #$36 
			sta $01 
			cli 
			rts 
			
savefile:
			ldx $ba
			cpx #$08 
			bcc skipsave 
			lda #$0f 
			tay
			jsr $ffba
			jsr resetdevice
			lda #dnamelen 
			ldx #<dname 
			ldy #>dname 
			jsr $ffbd 
			jsr $ffc0
			lda #$0f 
			jsr $ffc3 
			jsr $ffcc
			
			lda #$0f 
			ldx $ba 
			tay
			jsr $ffba 
			jsr resetdevice
			lda #fnamelen 
			ldx #<fname 
			ldy #>fname 
			jsr $ffbd 
			lda #$fb 
			ldx #<HiScoreTableStart
			ldy #>HiScoreTableStart
			stx $fb 
			sty $fc 
			ldx #<HiScoreTableEnd 
			ldy #>HiScoreTableEnd
			jsr $ffd8
skipsave:
			rts
			
loadfile:
			ldx $ba 
			cpx #$08 
			bcc skipload 
			
			lda #$0f 
			tay 
			jsr $ffba 
			jsr resetdevice 
			lda #fnamelen 
			ldx #<fname 
			ldy #>fname
			jsr $ffbd
			lda #$00 
			jsr $ffd5 
			bcc loaded
			jsr savefile
loaded:
skipload:	rts

resetdevice:
			lda #$01 
			ldx #<initdrive
			ldy #>initdrive
			jsr $ffbd 
			jsr $ffc0 
			lda #$0f 
			jsr $ffc3 
			jsr $ffcc
			rts
			
initdrive:
			.text "I:"

			rts