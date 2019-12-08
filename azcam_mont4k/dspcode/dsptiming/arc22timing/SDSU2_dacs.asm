; SDSU2 clock board DACS table
; 24MAr11 last change MPL
; This table is sent by the SETBIAS command to update clock board values.
; The format is BBBB DDDD DDMM VVVV VVVV VVVV (board, DAC, Mode, Value)

	DC    (CLK2<<8)+(0<<14)+@CVI((RG_HI+10.0)/20.0*4095)	; RG High 
	DC    (CLK2<<8)+(1<<14)+@CVI((RG_LO+10.0)/20.0*4095)	; RG Low  
	DC    (CLK2<<8)+(2<<14)+@CVI((P1_HI+10.0)/20.0*4095)	; P1 High -- storage
	DC    (CLK2<<8)+(3<<14)+@CVI((P1_LO+10.0)/20.0*4095)	; P1 Low
	DC    (CLK2<<8)+(4<<14)+@CVI((P2_HI+10.0)/20.0*4095)	; P2 High
	DC    (CLK2<<8)+(5<<14)+@CVI((P2_LO+10.0)/20.0*4095)	; P2 Low

	IF @SCP("MODE","MPP")
	DC    (CLK2<<8)+(6<<14)+@CVI((MPPP_HI+10.0)/20.0*4095)	; P3 High
	DC    (CLK2<<8)+(7<<14)+@CVI((MPPP_LO+10.0)/20.0*4095)	; P3 Low
	ENDIF

	IF @SCP("MODE","NORMAL")
	DC    (CLK2<<8)+(6<<14)+@CVI((P3_HI+10.0)/20.0*4095)	; P3 High
	DC    (CLK2<<8)+(7<<14)+@CVI((P3_LO+10.0)/20.0*4095)	; P3 Low
	ENDIF

	DC    (CLK2<<8)+(8<<14)+@CVI((S1_HI+10.0)/20.0*4095)	; S1 High -- serials
	DC    (CLK2<<8)+(9<<14)+@CVI((S1_LO+10.0)/20.0*4095)	; S1 Low         
	DC    (CLK2<<8)+(10<<14)+@CVI((S3_HI+10.0)/20.0*4095)	; S3 High       
	DC    (CLK2<<8)+(11<<14)+@CVI((S3_LO+10.0)/20.0*4095)	; S3 Low        
	DC    (CLK2<<8)+(12<<14)+@CVI((S2_HI+10.0)/20.0*4095)	; S2 High      
	DC    (CLK2<<8)+(13<<14)+@CVI((S2_LO+10.0)/20.0*4095)	; S2 Low
    
	IF @SCP("MODE","MPP")
	DC    (CLK2<<8)+(14<<14)+@CVI((MPPQ_HI+10.0)/20.0*4095)	; Q3 High -- image
	DC    (CLK2<<8)+(15<<14)+@CVI((MPPQ_LO+10.0)/20.0*4095)	; Q3 Low
	ENDIF

	IF @SCP("MODE","NORMAL")
	DC    (CLK2<<8)+(14<<14)+@CVI((Q3_HI+10.0)/20.0*4095)	; Q3 High -- image
	DC    (CLK2<<8)+(15<<14)+@CVI((Q3_LO+10.0)/20.0*4095)	; Q3 Low
	ENDIF

	DC    (CLK2<<8)+(16<<14)+@CVI((Q2_HI+10.0)/20.0*4095)	; Q2 High
	DC    (CLK2<<8)+(17<<14)+@CVI((Q2_LO+10.0)/20.0*4095)	; Q2 Low
	DC    (CLK2<<8)+(18<<14)+@CVI((Q1_HI+10.0)/20.0*4095)	; Q1 High
	DC    (CLK2<<8)+(19<<14)+@CVI((Q1_LO+10.0)/20.0*4095)	; Q1 Low
	DC    (CLK2<<8)+(20<<14)+@CVI((SW_HI+10.0)/20.0*4095)	; SW High
	DC    (CLK2<<8)+(21<<14)+@CVI((SW_LO+10.0)/20.0*4095)	; SW Low
	DC    (CLK2<<8)+(22<<14)+@CVI((TG_HI+10.0)/20.0*4095)	; TG High
	DC    (CLK2<<8)+(23<<14)+@CVI((TG_LO+10.0)/20.0*4095)	; TG Low


