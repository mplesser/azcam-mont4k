; Mont4k clocking routines for Mont4k dewar
; ARC22 clock board, SDSU clock and video boards
; 08Aug13 last change MPL

; ***********************************************
;                  Definitions
; ***********************************************

; dump pars into S2
; integrate normal mode under pars 1+2

; ser_OSA.asm for mont4k at Mt. Bigelow - single output OSA
; dump pars into S2
; right is 231w, left is 132w
; OSA is right side, OSB is left side

; ser_OSB.asm for mont4k at Mt. Bigelow - single output OSB
; dump pars into s1

; ser_split.asm for mont4k at Mt. Bigelow - split readout
; dump pars into S1L and S2R

	DEFINE	SDEF	'S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL'

	IF @SCP("MODE","MPP")
	DEFINE	PDEF	'P1L+P2L+P3L+TGL'
	ENDIF

	IF @SCP("MODE","NORMAL")
	DEFINE	PDEF	'P1H+P2H+P3L+TGL'
	ENDIF

; ***********************************************
;                  Parallel
; ***********************************************

; P shift, par_12_321t, reverse direction to amps
PFOR    DC	EPFOR-PFOR-1
	DC	VIDEO+%00110000

	IF @SCP("MODE","MPP")
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3L+TGL
	ENDIF

	IF @SCP("MODE","NORMAL")
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2H+P3L+TGL
	ENDIF
EPFOR

; P shift, par_12_123t, forward direction away from amps
PREV    DC	EREV-PREV-1
	DC	VIDEO+%00110000

	IF @SCP("MODE","MPP")
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3L+TGL
	ENDIF

	IF @SCP("MODE","NORMAL")
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1L+P2H+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1L+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3H+TGH
	DC	CLK2+P_DELAY+SDEF+P1H+P2L+P3L+TGL
	DC	CLK2+P_DELAY+SDEF+P1H+P2H+P3L+TGL
	ENDIF
EREV

	IF	@SCP("PDIR","FORWARD")
PXFER	EQU	PFOR
RXFER	EQU	PREV
	ENDIF

	IF	@SCP("PDIR","REVERSE")
PXFER	EQU	PREV
RXFER	EQU	PFOR
	ENDIF

PQXFER	EQU	PXFER

; ***********************************************
;                 Serial
; ***********************************************
; dump pars into S2
; right is 231w, left is 132w
; OSA is right side, OSB is left side

PARS	EQU	CLK2+PDEF+S_DELAY
PARR	EQU	CLK2+PDEF+R_DELAY

FPXFER0	DC	EFPXFER0-FPXFER0-GENCNT
		DC	PARS+RGH+S1RH+S2RH+S3H+S1LH+S2LH+SWH
		DC	PARS+RGH+S1RH+S2RH+S3H+S1LH+S2LH+SWH
EFPXFER0

; end fast flush
FPXFER2	DC	EFPXFER2-FPXFER2-GENCNT
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
EFPXFER2

; fast serial shift
FSXFER	DC	EFSXFER-FSXFER-GENCNT
		DC	PARR+RGH+S1RL+S2RH+S3L+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
		DC	PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
EFSXFER

SXFER0	DC	ESXFER0-SXFER0-GENCNT
		DC	PARR+RGH+S1RL+S2RH+S3L+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
		DC	VIDS+%1110100
		DC	PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
		DC	PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
ESXFER0

SXFER1	DC	ESXFER1-SXFER1-GENCNT		; (bin-1) times
		DC	PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
		DC	PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
		DC	PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
		DC	PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
ESXFER1

SXFER2	DC	ESXFER2-SXFER2-GENCNT

; CDS integrate on noise
		DC	VIDS+%1110111  		; Stop resetting integrator
		DC	VIDEO+DWELL+%0000111	; Integrate noise
		DC	VIDEO+%0011011  	; Stop Integrate, switch POL

		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL

; CDS integrate on signal
		DC	VIDS+%0011011  		; Delay for Pgnal to settle
		DC	VIDEO+DWELL+%0001011	; Integrate signal
		DC	VIDEO+%0011011  	; Stop integrate, clamp, reset, A/D sampling
ESXFER2

SXFER2D	DC	ESXFER2D-SXFER2D-GENCNT
		DC	SXMIT		; Transmit A/D data to host

; CDS integrate on noise
		DC	VIDS+%1110111  		; Stop resetting integrator
		DC	VIDEO+DWELL+%0000111	; Integrate noise
		DC	VIDEO+%0011011  		; Stop Integrate, switch POL

		DC	PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL

; CDS integrate on signal
		DC	VIDS+%0011011  		; Delay for Pgnal to settle
		DC	VIDEO+DWELL+%0001011	; Integrate signal
		DC	VIDEO+%0011011  	; Stop integrate, clamp, reset, A/D sampling
ESXFER2D

