; SystemConfig.asm - defines the system configurations for an ARC controller
; Use 'null.asm' for boards which are not installed

	DEFINE	TIMBRD	'tim3.asm'			; timing board (not used yet)  'ARC22.asm'

	DEFINE	VIDDEFS	'GEN2VIDEO_defs.asm'		; video board defs
	DEFINE	VIDBRD0	'GEN2VIDEO_dacs_brd0.asm'	; video board 0
	DEFINE	VIDBRD1	'null.asm'			; video board 1
	DEFINE	VIDBRD2	'null.asm'			; video board 2
	DEFINE	VIDBRD3	'null.asm'			; video board 3

	DEFINE	CLKBRD0	'Mont4kClock_dacs.asm'		; clock board 0
	DEFINE	CLKBRD1	'null.asm'			; clock board 1

	DEFINE	SBNCODE	'GEN2VIDEO_GEN2CLK_sbn.asm'		; video&clock SBN command

	DEFINE	CLKPINOUT  'Mont4kClockPins.asm'	; clock board pinout

	DEFINE	POWERCODE 'GEN2VIDEO_power.asm'			; power related code

	DEFINE	UTILBRD	'null.asm'			; utility board

