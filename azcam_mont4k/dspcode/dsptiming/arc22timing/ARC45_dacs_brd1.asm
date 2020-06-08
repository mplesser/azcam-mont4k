; ARC45_dacs_brd1.asm
; ARC45 dual channel video board DACS table
; 03Jan08 last change MPL

; set gain and integrator speed [$board-c3-speed-gain]
; speed: f => fast, c => slow
; gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
	DC	$1c3cdd					; x5 Gain, slow integrate, board #0

; Output offset voltages
	DC	$1c8000+OFFSET+OFFSET2			; Output video offset, Output A
	DC	$1cc000+OFFSET+OFFSET3			; Output video offset, Output B

; DC bias voltages
	DC	$1d0000+@CVI((VODC-7.5)/22.5*4095)	; pin #1 (7.5 => +30)
	DC	$1d4000+@CVI((VODD-7.5)/22.5*4095)	; pin #2 (7.5 => +30)
	DC	$1c0000+@CVI((5.0-5.0)/15.0*4095)	; pin #3 (5.0 => +20)
	DC	$1c4000+@CVI((5.0-5.0)/15.0*4095)	; pin #4 (5.0 => +20)
	DC	$1d8000+@CVI((7.5-7.5)/22.5*4095)	; pin #5 (7.5 => +30)
	DC	$1dc000+@CVI((7.5-7.5)/22.5*4095)	; pin #6 (7.5 => +30)
							; pins #7, 8 (0 volts)
	DC	$1e0000+@CVI((VOGC+10.0)/20.0*4095)	; pin #9 (-10 => +10)
	DC	$1e4000+@CVI((VOGD+10.0)/20.0*4095)	; pin #10 (-10 => +10)
	DC	$1e8000+@CVI((0.0+10.0)/20.0*4095)	; pin #11 (-10 => +10)
	DC	$1ec000+@CVI((0.0+10.0)/20.0*4095)	; pin #12 (-10 => +10)

; end of ARC41_dacs_brd1.asm
