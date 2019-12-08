; video definitions

; *** define SXMIT based on selected channels ***
	IF	@SCP("CHANNELS","0")
SXMIT	EQU	$00F000	; Transmit A/D = 0
	ENDIF
	IF	@SCP("CHANNELS","1")
SXMIT	EQU	$00F041	; Transmit A/D = 1
	ENDIF
	IF	@SCP("CHANNELS","2")
SXMIT	EQU	$00F082				; Transmit A/D = 2
	ENDIF
	IF	@SCP("CHANNELS","3")
SXMIT	EQU	$00F0C3				; Transmit A/D = 3
	ENDIF
	IF	@SCP("CHANNELS","01")
SXMIT	EQU	$00F040	; Transmit A/Ds = 0 to 1
	ENDIF
	IF	@SCP("CHANNELS","23")
SXMIT	EQU	$00F0C2				; Transmit A/Ds = 2 to 3
	ENDIF
	IF	@SCP("CHANNELS","0123")
SXMIT	EQU	$00F0C0				; Transmit A/Ds = 0 to 3
	ENDIF

; *** shorthand for waveforms ***
S_DELAY	EQU	@CVI((SERDEL-40)/40)<<16
R_DELAY	EQU	@CVI((RSTDEL-40)/40)<<16
V_DELAY	EQU	@CVI((VIDDEL-40)/40)<<16
P_DELAY	EQU	@CVI((PARDEL-40)/40)<<16
DWELL	EQU	@CVI((SAMPLE-40)/40)<<16

VIDS		EQU	VIDEO+V_DELAY

INTNOISE	MACRO
; CDS integrate on noise
		DC	VIDS+%1110111  		; Stop resetting integrator (video delay)
		DC	VIDEO+DWELL+%0000111	; Integrate noise
		DC	VIDS+%0011011  	; Stop Integrate, switch POL
	ENDM

INTSIGNAL	MACRO
; CDS integrate on signal
		DC	VIDS+%0011011  		; Delay for Pgnal to settle
		DC	VIDEO+DWELL+%0001011	; Integrate signal
		DC	VIDS+%0011011  		; Stop integrate, clamp, reset, A/D is sampling
	ENDM

LATCH	MACRO
		DC	VIDEO+%1110100
	ENDM
