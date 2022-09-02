; SystemConfig.asm - defines the system configurations for an ARC controller
; Use 'null.asm' for boards which are not installed

	DEFINE	TIMBRD	'ARC22.asm'				; timing board (not used yet)

	DEFINE	VIDDEFS	'GEN2VIDEO_defs.asm'			; video board defs
	DEFINE	VIDBRD0	'GEN2VIDEO_dacs_brd0.asm'		; video board 0
	DEFINE	VIDBRD1	'GEN2VIDEO_dacs_brd1.asm'		; video board 1

	DEFINE	CLKBRD0	'GEN2CLK_dacs_brd2.asm'			; clock board 0
	DEFINE	CLKBRD1	'GEN2CLK_dacs_brd3.asm'			; clock board 1

	DEFINE	SBNCODE	'GEN2VIDEO_GEN2CLK_sbn.asm'		; video&clock SBN command

	DEFINE	CLKSTATES0 'GEN2CLK_clockstates_brd2.asm'	; clock board 0 states
	DEFINE	CLKSTATES1 'GEN2CLK_clockstates_brd3.asm'	; clock board 1 states

	DEFINE	POWERCODE 'GEN2VIDEO_power.asm'			; power related code

