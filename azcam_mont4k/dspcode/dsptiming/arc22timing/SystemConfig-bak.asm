; SystemConfig.asm - defines the system configurations for an ARC controller
; Use 'null.asm' for boards which are not installed

	DEFINE	TIMBRD	'ARC22.asm'			; timing board (not used yet)

	DEFINE	VIDDEFS	'ARC45_defs.asm'		; video board defs
	DEFINE	VIDBRD0	'ARC45_dacs_brd0.asm'	; video board 0
	DEFINE	VIDBRD1	'ARC45_dacs_brd1.asm'	; video board 1
	DEFINE	VIDBRD2	'null.asm'			; video board 2
	DEFINE	VIDBRD3	'null.asm'			; video board 3

	DEFINE	CLKBRD0	'ARC32_dacs.asm'		; clock board 0
	DEFINE	CLKBRD1	'null.asm'			; clock board 1

	DEFINE	SBNCODE	'ARC45_ARC32_sbn.asm'	; video&clock SBN command

	DEFINE	CLKPINOUT	'Mont4kClockPins.asm'	; clock board pinout

	DEFINE	POWERCODE	'ARC45_power.asm'		; power related code

	DEFINE	UTILBRD	'null.asm'			; utility board

