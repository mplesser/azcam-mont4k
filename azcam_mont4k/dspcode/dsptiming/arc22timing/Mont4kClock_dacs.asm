; SDSU2 clock board DACS table
; 06AUg13 last change MPL
; This table is sent by the SETBIAS command to update clock board values.
; The format is BBBB DDDD DDMM VVVV VVVV VVVV (board, DAC, Mode, Value)

; modified for Mont4k clock names

	DC    (CLK2<<8)+(0<<14)+@CVI((RG_HI+10.0)/20.0*4095)	; RG High Pin 1 
	DC    (CLK2<<8)+(1<<14)+@CVI((RG_LO+10.0)/20.0*4095)	; RG Low  
	DC    (CLK2<<8)+(2<<14)+@CVI((P1_HI+10.0)/20.0*4095)	; P1 High Pin 2
	DC    (CLK2<<8)+(3<<14)+@CVI((P1_LO+10.0)/20.0*4095)	; P1 Low
	DC    (CLK2<<8)+(4<<14)+@CVI((P2_HI+10.0)/20.0*4095)	; P2 High Pin 3
	DC    (CLK2<<8)+(5<<14)+@CVI((P2_LO+10.0)/20.0*4095)	; P2 Low

	DC    (CLK2<<8)+(6<<14)+@CVI((MPP_HI+10.0)/20.0*4095)	; P3 High Pin 4
	DC    (CLK2<<8)+(7<<14)+@CVI((MPP_LO+10.0)/20.0*4095)	; P3 Low

	DC    (CLK2<<8)+(8<<14)+@CVI((S1R_HI+10.0)/20.0*4095)	; S1R High  Pin 5
	DC    (CLK2<<8)+(9<<14)+@CVI((S1R_LO+10.0)/20.0*4095)	; S1R Low         
	DC    (CLK2<<8)+(10<<14)+@CVI((S3_HI+10.0)/20.0*4095)	; S3 High   Pin 6
	DC    (CLK2<<8)+(11<<14)+@CVI((S3_LO+10.0)/20.0*4095)	; S3 Low        
	DC    (CLK2<<8)+(12<<14)+@CVI((S2R_HI+10.0)/20.0*4095)	; S2R High  Pin 7
	DC    (CLK2<<8)+(13<<14)+@CVI((S2R_LO+10.0)/20.0*4095)	; S2R Low
	DC    (CLK2<<8)+(14<<14)+@CVI((S3L_HI+10.0)/20.0*4095)	; S3L High  Pin 8 
	DC    (CLK2<<8)+(15<<14)+@CVI((S3L_LO+10.0)/20.0*4095)	; S3L Low
	DC    (CLK2<<8)+(16<<14)+@CVI((S2L_HI+10.0)/20.0*4095)	; S2L High  Pin 9 
	DC    (CLK2<<8)+(17<<14)+@CVI((S2L_LO+10.0)/20.0*4095)	; S2L Low
	DC    (CLK2<<8)+(18<<14)+@CVI((S1L_HI+10.0)/20.0*4095)	; S1L High  Pin 10
	DC    (CLK2<<8)+(19<<14)+@CVI((S1L_LO+10.0)/20.0*4095)	; S1L Low
	DC    (CLK2<<8)+(20<<14)+@CVI((SW_HI+10.0)/20.0*4095)	; SW High   Pin 11
	DC    (CLK2<<8)+(21<<14)+@CVI((SW_LO+10.0)/20.0*4095)	; SW Low
	DC    (CLK2<<8)+(22<<14)+@CVI((TG_HI+10.0)/20.0*4095)	; TG High   Pin 12
	DC    (CLK2<<8)+(23<<14)+@CVI((TG_LO+10.0)/20.0*4095)	; TG Low
