; SDSU2 clock board DACS table
; 21Jul11 last change MPL

; second clock board addressed as board 3

; I am not sure this is correct!!!!

; bank 0
	DC    (CLK4<<8)+(0<<14)+@CVI((VP1B2_HI+10.0)/(2*10.0)*4095)	; Pin 1
	DC    (CLK4<<8)+(1<<14)+@CVI((VP1B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(2<<14)+@CVI((VP2B2_HI+10.0)/(2*10.0)*4095)	; Pin 2
	DC    (CLK4<<8)+(3<<14)+@CVI((VP2B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(4<<14)+@CVI((VP3B2_HI+10.0)/(2*10.0)*4095)	; Pin 3
	DC    (CLK4<<8)+(5<<14)+@CVI((VP3B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(6<<14)+@CVI((VP4B2_HI+10.0)/(2*10.0)*4095)	; Pin 4 
	DC    (CLK4<<8)+(7<<14)+@CVI((VP4B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(8<<14)+@CVI((VP5B2_HI+10.0)/(2*10.0)*4095)	; Pin 5
	DC    (CLK4<<8)+(9<<14)+@CVI((VP5B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(10<<14)+@CVI((VP6B2_HI+10.0)/(2*10.0)*4095)	; Pin 6
	DC    (CLK4<<8)+(11<<14)+@CVI((VP6B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(12<<14)+@CVI((VP7B2_HI+10.0)/(2*10.0)*4095)	; Pin 7
	DC    (CLK4<<8)+(13<<14)+@CVI((VP7B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(14<<14)+@CVI((VP8B2_HI+10.0)/(2*10.0)*4095)	; Pin 8
	DC    (CLK4<<8)+(15<<14)+@CVI((VP8B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(16<<14)+@CVI((VP9B2_HI+10.0)/(2*10.0)*4095)	; Pin 9
	DC    (CLK4<<8)+(17<<14)+@CVI((VP9B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(18<<14)+@CVI((VP10B2_HI+10.0)/(2*10.0)*4095)	; Pin 10
	DC    (CLK4<<8)+(19<<14)+@CVI((VP10B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(20<<14)+@CVI((VP11B2_HI+10.0)/(2*10.0)*4095)	; Pin 11
	DC    (CLK4<<8)+(21<<14)+@CVI((VP11B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK4<<8)+(22<<14)+@CVI((VP12B2_HI+10.0)/(2*10.0)*4095)	; Pin 12
	DC    (CLK4<<8)+(23<<14)+@CVI((VP12B2_LO+10.0)/(2*10.0)*4095)	; 

; bank 1

; I am not sure this is correct!!!!

	DC    (CLK5<<8)+(0<<14)+@CVI((VP13B2_HI+10.0)/(2*10.0)*4095)	; Pin 13
	DC    (CLK5<<8)+(1<<14)+@CVI((VP13B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(2<<14)+@CVI((VP14B2_HI+10.0)/(2*10.0)*4095)	; Pin 14
	DC    (CLK5<<8)+(3<<14)+@CVI((VP14B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(4<<14)+@CVI((VP15B2_HI+10.0)/(2*10.0)*4095)	; Pin 15
	DC    (CLK5<<8)+(5<<14)+@CVI((VP15B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(6<<14)+@CVI((VP16B2_HI+10.0)/(2*10.0)*4095)	; Pin 16
	DC    (CLK5<<8)+(7<<14)+@CVI((VP16B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(8<<14)+@CVI((VP17B2_HI+10.0)/(2*10.0)*4095)	; Pin 17
	DC    (CLK5<<8)+(9<<14)+@CVI((VP17B2_LO+10.0)/(2*10.0)*4095)	;   
	DC    (CLK5<<8)+(10<<14)+@CVI((VP18B2_HI+10.0)/(2*10.0)*4095)	; Pin 18
	DC    (CLK5<<8)+(11<<14)+@CVI((VP18B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(12<<14)+@CVI((VP19B2_HI+10.0)/(2*10.0)*4095)	; Pin 19
	DC    (CLK5<<8)+(13<<14)+@CVI((VP19B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(14<<14)+@CVI((VP33B2_HI+10.0)/(2*10.0)*4095)	; Pin 33
	DC    (CLK5<<8)+(15<<14)+@CVI((VP33B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(16<<14)+@CVI((VP34B2_HI+10.0)/(2*10.0)*4095)	; Pin 34
	DC    (CLK5<<8)+(17<<14)+@CVI((VP34B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(18<<14)+@CVI((VP35B2_HI+10.0)/(2*10.0)*4095)	; Pin 35
	DC    (CLK5<<8)+(19<<14)+@CVI((VP35B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(20<<14)+@CVI((VP36B2_HI+10.0)/(2*10.0)*4095)	; Pin 36
	DC    (CLK5<<8)+(21<<14)+@CVI((VP36B2_LO+10.0)/(2*10.0)*4095)	; 
	DC    (CLK5<<8)+(22<<14)+@CVI((VP37B2_HI+10.0)/(2*10.0)*4095)	; Pin 37
	DC    (CLK5<<8)+(23<<14)+@CVI((VP37B2_LO+10.0)/(2*10.0)*4095)	; 
