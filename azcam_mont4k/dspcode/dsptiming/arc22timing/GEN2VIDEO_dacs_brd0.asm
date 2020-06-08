; GEN2VIDEO_dacs_brd0.asm
; First Gen2 dual channel video board DACS table for video board addressed as board 0
; 06Aug13 last change MPL

; Set gain and integrator speed [$board-c3-speed-gain]
;  speed: f => fast, c => slow
;  gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
	DC	$0c3cee			; x10 Gain, slow integrate, board #0

; Output offset voltages
	DC	$0c4000+OFFSETA+OFFSET	; Output video offset, Output #A
	DC	$0cc000+OFFSETB+OFFSET	; Output video offset, Output #B

; DC bias voltages

	DC	$0d0000+@CVI((VODA-7.5)/22.5*4095)	; pin #1 (7.5-30)
	DC	$0d4000+@CVI((VODB-7.5)/22.5*4095)	; pin #2 (7.5-30)
	DC	$0d8000+@CVI((VRD-5.0)/15.0*4095)	; pin #3 (5-20)
	DC	$0e0000+@CVI((5.0-5.0)/15.0*4095)	; pin #5 (5-20)   B5
	DC	$0f0000+@CVI((5.0+5.0)/10.0*4095)	; pin #9 (-5-+5)  B7
	DC	$0f8000+@CVI((VOGA+10.0)/20.0*4095)	; pin #11 (-10-+10)
	DC	$0fc000+@CVI((VOGB+10.0)/20.0*4095)	; pin #12 (-10-+10)

; end of GEN2VIDEO_dacs_brd0.asm
