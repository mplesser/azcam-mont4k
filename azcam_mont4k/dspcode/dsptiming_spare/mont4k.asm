; Mont4k - spare controller
; 23Jul14 last change - MPL

; *** timing (40 - 5080 ns) ***
SERDEL	EQU	120	; S clock delay      120
RSTDEL	EQU	120	; RG clock delay
VIDDEL	EQU	120	; Video clock delay
PARDEL	EQU	5000	; P clock delay 5000
PARMULT	EQU	25	; PARDEL multiplier
SAMPLE	EQU	1100	; sample time 2000

; gain  3.0 e/DN, VG=2, VS=2, OD=23

; *** video offsets ***
; value for 5x gain, slow, 2 usec dwell
OFFSET	EQU	1800	; global offset
OFFSETA	EQU	142	; offset 0    ;  ds9 left side
OFFSETB	EQU	5	; offset 1    ;  ds9 right side

; *** bias voltages ***
VOD       EQU	+24.0   ; Output Drain 23
VRD       EQU	+14.5   ; Reset Drain  14.5
VOG       EQU	 -1.0   ; Output Gate  -1

; *** clock voltages ***
RG_HI     EQU   +6.0    ; Reset Gate
RG_LO     EQU   -0.0    ; 
S_HI      EQU   +5.0    ; Serial clocks
S_LO      EQU   -5.0    ; 
SW_HI     EQU   +5.0    ; Summing Well
SW_LO     EQU   -4.0    ; 

P_HI      EQU   +2.0    ; +1
P_LO      EQU   -8.0    ; 

MPP_HI    EQU   +3.5    ; 
MPP_LO    EQU   -6.0    ;

TG_HI     EQU   +3.5    ; transfer gate
TG_LO     EQU   -6.0    ; 

; *** misc ***
VODA		EQU	VOD
VODB		EQU	VOD 
VOGA		EQU	VOG
VOGB		EQU	VOG

S1R_HI		EQU	S_HI
S1R_LO		EQU	S_LO
S2R_HI		EQU	S_HI
S2R_LO		EQU	S_LO
S3_HI		EQU	S_HI
S3_LO		EQU	S_LO
S1L_HI		EQU	S_HI
S1L_LO		EQU	S_LO	
S2L_HI		EQU	S_HI
S2L_LO		EQU	S_LO
P1_HI		EQU	P_HI
P1_LO		EQU	P_LO	
P2_HI		EQU	P_HI
P2_LO		EQU	P_LO
P3_HI		EQU	P_HI
P3_LO		EQU	P_LO

S3L_HI		EQU	0.0	; not used
S3L_LO		EQU	0.0	; not used

VB5       	EQU	5.0	; not used
VB6       	EQU	+7.5    ; Bias 6 (+7.5 - +30)
VB7       	EQU	0.0	; not used


; *** configurations ****

	DEFINE	CHANNELS	'01'

	DEFINE	PDIR		'FORWARD'
	DEFINE	MODE		'MPP'      
	DEFINE	CLOCKING	'clocking.asm'
