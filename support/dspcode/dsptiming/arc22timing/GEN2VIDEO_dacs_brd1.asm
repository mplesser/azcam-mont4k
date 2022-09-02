; GEN2VIDEO_dacs_brd1.asm
; Second Gen2 dual channel video board DACS table for video board addressed as board 1
; 22Jul11 last change MPL

; Set gain and integrator speed [$board-c3-speed-gain]
;  speed: f => fast, c => slow
;  gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
	DC	$1c3cdd			; x10 Gain, slow integrate, board #0

; Output offset voltages
	DC	$1c4000+OFFSET2+OFFSET	; Output video offset, Output #A
	DC	$1cc000+OFFSET3+OFFSET	; Output video offset, Output #B

; DC bias voltages

	DC	$1d0000+@CVI((VP1B1-7.5)/22.5*4095)	; pin #1 (7.5-30)
	DC	$1d4000+@CVI((VP2B1-7.5)/22.5*4095)	; pin #2 (7.5-30)
	DC	$1d8000+@CVI((VP3B1-5.0)/15.0*4095)	; pin #3 (5-20)
	DC	$1e0000+@CVI((VP5B1-5.0)/15.0*4095)	; pin #5 (5-20)
	DC	$1f0000+@CVI((VP9B1+5.0)/10.0*4095)	; pin #9 (-5-+5)	
	DC	$1f8000+@CVI((VP11B1+10.0)/20.0*4095)	; pin #11 (-10-+10)
	DC	$1fc000+@CVI((VP12B1+10.0)/20.0*4095)	; pin #12 (-10-+10)

; end of GEN2VIDEO_dacs_brd1.asm
