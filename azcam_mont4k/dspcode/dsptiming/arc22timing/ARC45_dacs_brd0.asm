; ARC45_dacs_brd0.asm
; ARC45 dual channel video board DACS table
; 03Jan08 last change MPL

; Set gain and integrator speed [$board-c3-speed-gain]
;  speed: f => fast, c => slow
;  gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
	DC	$0c3cdd					; x5 Gain, slow integrate, board #0

; Output offset voltages
	DC	$0c8000+OFFSET+OFFSET0			; Output video offset, Output A
	DC	$0cc000+OFFSET+OFFSET1			; Output video offset, Output B

; DC bias voltages
	DC	$0d0000+@CVI((VODA-7.5)/22.5*4095)	; pin #1 (7.5 => +30)
	DC	$0d4000+@CVI((VODB-7.5)/22.5*4095)	; pin #2 (7.5 => +30)
	DC	$0c0000+@CVI((VRD-5.0)/15.0*4095)	; pin #3 (5.0 => +20)
	DC	$0c4000+@CVI((5.0-5.0)/15.0*4095)	; pin #4 (5.0 => +20)
	DC	$0d8000+@CVI((VB5-7.5)/22.5*4095)	; pin #5 (7.5 => +30)
	DC	$0dc000+@CVI((VB6-7.5)/22.5*4095)	; pin #6 (7.5 => +30)
							; pins #7, 8 (0 volts)
	DC	$0e0000+@CVI((VOGA+10.0)/20.0*4095)	; pin #9 (-10 => +10)
	DC	$0e4000+@CVI((VOGB+10.0)/20.0*4095)	; pin #10 (-10 => +10)
	DC	$0e8000+@CVI((VB7+10.0)/20.0*4095)	; pin #11 (-10 => +10)
	DC	$0ec000+@CVI((0.0+10.0)/20.0*4095)	; pin #12 (-10 => +10)

; end of ARC41_dacs_brd0.asm
