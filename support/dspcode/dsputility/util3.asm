       COMMENT *

This file is used to generate DSP code for the utility board. It will time
     the exposure, operate the shutter, control the CCD temperature and 
     turn the analog power on. This is Rev. 3.00 software. 
Modified 1-12-97 for 10 MHz input clock frequency by adding 2 to elapsed
     exposure time rather than one. 
Power ON sequence written for Gen II power control board, Rev. 4A

-d DOWNLOAD 'HOST'	To generate code for downloading to DSP memory.
-d DOWNLOAD 'ROM'	To generate code for writing to the ROM.

	*
        PAGE    132	; Printronix page width - 132 columns

; Name it a section so it doesn't conflict with other application programs
	SECTION	UTILAPPL

;  These are also defined in "utilboot.asm", so be sure they agree
APL_ADR	EQU	$90	; Starting address of application program
BUF_STR	EQU	$80	; Starting address of buffers in X:
BUF_LEN	EQU	$20	; Length of buffers
SSI_BUF	EQU	BUF_STR		; Starting address of SCI buffer in X:
COM_BUF EQU     SSI_BUF+BUF_LEN	; Starting address of command buffer in X:
COM_TBL EQU     COM_BUF+BUF_LEN	; Starting address of command table in X:

;  Define some useful constants
APL_XY	EQU	$1EE0	; Starting address in EEPROM of X: and Y: values
DLY_MUX EQU     150      ; Number of DSP cycles to delay for MUX settling
DLY_AD  EQU     200     ; Number of DSP cycles to delay for A/D settling

; Assign addresses to port B data register
PBD     EQU     $FFE4   ; Port B Data Register
IPR     EQU     $FFFF   ; Interrupt Priority Register

;  Addresses of memory mapped components in Y: data memory space
;  Write addresses first
WR_DIG  EQU     $FFF0   ; was $FFFF  Write Digital output values D00-D15
WR_MUX  EQU     $FFF1   ; Select MUX connected to A/D input - one of 16
EN_DIG	EQU	$FFF2	; Enable digital outputs
WR_DAC3 EQU     $FFF7   ; Write to DAC#3 D00-D11
WR_DAC2 EQU     $FFF6   ; Write to DAC#2 D00-D11
WR_DAC1 EQU     $FFF5   ; Write to DAC#1 D00-D11
WR_DAC0 EQU     $FFF4   ; Write to DAC#0 D00-D11

;  Read addresses next
RD_DIG  EQU     $FFF0   ; Read Digital input values D00-D15
STR_ADC EQU     $FFF1   ; Start ADC conversion, ignore data
RD_ADC  EQU     $FFF2   ; Read A/D converter value D00-D11
WATCH   EQU     $FFF7   ; Watch dog timer - tell it that DSP is alive

;  Bit definitions of STATUS word
ST_SRVC	EQU     0       ; Set if ADC routine needs executing
ST_EX   EQU     1       ; Set if timed exposure is in progress
ST_SH   EQU     2       ; Set if shutter is open
ST_READ EQU     3	; Set if a readout needs to be initiated
STRT_EX	EQU	4	; Set to indicate start of exposure

; Bit definitions of software OPTIONS word
OPT_SH  EQU     0       ; Set to open and close shutter

;  Bit definitions of Port B = Host Processor Interface
PWR_EN1	EQU     0       ; Power enable bit ONE - Output
PWR_EN0	EQU     1       ; Power enable bit ZERO  - Output
PWRST	EQU     2       ; Reset power conditioner counter - Output
SHUTTER EQU     3       ; Control shutter - Output
IRQ_T   EQU     4       ; Request interrupt service from timing board - Output
SYS_RST EQU     5       ; Reset entire system - Output
WATCH_T EQU     8       ; Processed watchdog signal from timing board - Input

;**************************************************************************
;                                                                         *
;    Register assignments  						  *
;	 R1 - Address of SCI receiver contents				  *
;	 R2 - Address of processed SCI receiver contents		  *
;        R3 - Pointer to current top of command buffer                    *
;        R4 - Pointer to processed contents of command buffer		  *
;	 N4 - Address for internal jumps after receiving 'DON' replies	  *
;        R0, R5, R6, A, X0, X1 - For use by program only                  *
;	 R7 - For use by SCI ISR only					  *
;        Y0, Y1, and B - For use by timer ISR only. If any of these	  *
;		registers are needed elsewhere they must be saved and	  *
;	        restored in the TIMER ISR.                        	  *
;**************************************************************************

; Specify execution and load addresses.
	ORG	P:APL_ADR,P:APL_ADR

; The TIMER addresses must be defined here and SERVICE must follow to match
;   up with the utilboot code
;	JMP	<SERVICE		; Millisecond timer interrupt
	RTS

TIMER	RTI				; RTI for now so downloading works
	JCLR    #ST_EX,X:STATUS,NO_TIM	; Continue on if we're not exposing
	JCLR	#STRT_EX,X:<STATUS,EX_STRT ; Skip if exposure has been started
	BCLR	#STRT_EX,X:<STATUS	; Clear status = "not start of exposure"
	CLR     B
	MOVE    B,Y:<EL_TIM_MSECONDS	; Initialize elapsed time
	MOVE	B,Y:<EL_TIM_FRACTION
	JCLR	#OPT_SH,X:<OPTIONS,NO_TIM ; Don't open shutter if a dark frame
	JSR	<OSHUT 			; Open shutter if start of exposure
	JMP	<NO_TIM			; Don't increment EL_TIM at first
EX_STRT	CLR	B   Y:<INCR,Y0		; INCR = 0.8 seconds
	MOVE	X:<ZERO,Y1
	MOVE	Y:<EL_TIM_MSECONDS,B1 	; Get elapsed time
	MOVE	Y:<EL_TIM_FRACTION,B0
	ADD	Y,B   Y:<TGT_TIM,Y1	; EL_TIM = EL_TIM + 0.8 milliseconds	
	MOVE	B0,Y:<EL_TIM_FRACTION
	SUB     Y1,B  B1,Y:<EL_TIM_MSECONDS
	JLT     <NO_TIM			; If (EL .GE. TGT) we've timed out

; Close the shutter at once if needed
	JCLR    #OPT_SH,X:OPTIONS,NO_SHUT ; Close the shutter only if needed
	BSET    #SHUTTER,X:PBD		; Set Port B bit #3 to close shutter
	BSET	#ST_SH,X:<STATUS	; Set status to mean shutter closed

; Wait SH_DLY milliseconds for the shutter to fully close before reading out
NO_SHUT	MOVE	Y:<SH_DEL,Y1		; Get shutter closing time
	SUB	Y1,B			; B = EL_TIM - (TGT_TIM + SH_DEL)
	JLT	<NO_TIM			; If (EL .GE. TGT+DEL) we've timed out
	BSET    #ST_READ,X:<STATUS	; Set so a readout will be initiated

; Return from interrupt
NO_TIM	BSET    #ST_SRVC,X:<STATUS	; SERVICE needs executing
	MOVEC	Y:<SV_SR,SR		; Restore Status Register
	NOP
	RTI				; Return from TIMER interrupt

; This long subroutine is executed every millisecond, but isn't an ISR so
;   that care need not be taken to preserve registers and stacks.
SERVICE	BCLR	#ST_SRVC,X:<STATUS	; Clear request to execute SERVICE
	JCLR	#ST_READ,X:<STATUS,UPD_DIG ; Initiate readout?

; Extra call if using the VME interface board
	IF	@SCP("INTERFACE","VME")
        MOVE    X:<VME,B
        MOVE    B,X:(R3)+       	; Header ID from Utility to VME
        MOVE    Y:<RDC,B
        MOVE    B,X:(R3)+       	; Put VMEINF board in readout mode
	ENDIF

	MOVE	X:<TIMING,A
	MOVE	A,X:(R3)+               ; Header from Utility to timing
	MOVE	Y:<RDC,A
	MOVE	A,X:(R3)+               ; Start reading out the CCD
	BCLR	#ST_EX,X:<STATUS	; Exposure is no longer in progress
	BCLR	#ST_READ,X:<STATUS	; Readout will be initiated
	RTS				; Return now to save time

; Update all the digital input/outputs; reset watchdog timer
UPD_DIG	MOVEP   Y:RD_DIG,Y:DIG_IN  ; Read 16 digital inputs
	MOVEP	#1,Y:EN_DIG	   ; Enable digital outputs
	MOVEP   Y:DIG_OUT,Y:WR_DIG ; Write 16 digital outputs

; Update the 4 DACs
	MOVEP   Y:DAC0,Y:WR_DAC0 ; Write to DAC0
	MOVEP   Y:DAC1,Y:WR_DAC1 ; Write to DAC1
	MOVEP   Y:DAC2,Y:WR_DAC2 ; Write to DAC2
	MOVEP   Y:DAC3,Y:WR_DAC3 ; Write to DAC3

; Analog Input processor - read the 16 A/D inputs
        MOVE    X:<ONE,X0	; For incrementing accumulator to select MUX
        CLR     A  #<AD_IN,R5	; Will contain MUX number
        DO      Y:NUM_AD,LOOP_AD ; Loop over each A/D converter input
        MOVEP   A,Y:WR_MUX      ; Select MUX input
        DO	#DLY_MUX,L_AD1	; Wait for the MUX to settle
	MOVE	A1,Y:<SV_A1	; DO needed so SSI input can come in
L_AD1
        MOVEP   Y:STR_ADC,X1    ; Start A/D conversion - dummy read
        DO	#DLY_AD,L_AD2	; Wait for the A/D to settle
        MOVE    X:<CFFF,X1
L_AD2	
        MOVEP   Y:RD_ADC,A1     ; Get the A/D value
        AND     X1,A            ; A/D is only valid to 12 bits
        BCHG    #11,A1		; Change 12-bit 2's complement to unipolar
        MOVE    A1,Y:(R5)+      ; Put the A/D value in the table
	MOVE	Y:<SV_A1,A1	; Restore A1 = MUX number
        ADD     X0,A		; Increment A = MUX number by one
LOOP_AD
	MOVEP	X:ONE,Y:WR_MUX ; Sample +5V when idle

; Control the CCD Temperature
; The algorithmn assumes a reverse biased diode whose A/D count A_CCDT 
;   is proportional to temperature. Don't start controlling temperature 
;   until it falls below target temperature. 
	MOVE    Y:<T_CCDT,X0	; Get actual CCD temperature
	MOVE    Y:<A_CCDT,A	; Get lower CCD temperature limit
	SUB	X0,A
	MOVE	A,X0
	MOVE	Y:<T_COEFF,X1	
	MPY	X0,X1,A		; A = (actual - target) * T_COEFF
	MOVE	Y:<DAC0,X1	; A positive -> actual > target ->
	MOVE	Y:<DAC0_LS,X0	;   too cold -> add more heat
	ADD	X,A		; Add both least and most significant
				;   words (X0 and X1) to accumulator A
	MOVE	Y:<CC00,X0	; Heats greater than this are not allowed
	CMP	X0,A
	JLT	<TST_LOW
	MOVE	X0,A		; Make it the maximum heat
	JMP	<WR_DAC
TST_LOW	TST	A		; Heats of less than zero are not allowed
	JGT	<WR_DAC
	MOVE	X:<ZERO,A	; No heat
WR_DAC	MOVEP	A,Y:WR_DAC0	; Update DAC and record of it
	MOVE	A,Y:<DAC0
	MOVE	A0,Y:<DAC0_LS
	RTS			; Return from subroutine SERVICE call

; Shutter support subroutines for the TIMER executive
;   Also support shutter connection to timing board for now.
OSHUT	BCLR    #SHUTTER,X:PBD  ; Clear Port B bit #3 to open shutter
        BCLR    #ST_SH,X:<STATUS ; Clear status bit to mean shutter open
        RTS

CSHUT	BSET    #SHUTTER,X:PBD  ; Set Port B bit #3 to close shutter
        BSET    #ST_SH,X:<STATUS ; Set status to mean shutter closed
        RTS

; These are called directly by command, so need to call subroutines in turn
OPEN	JSR	OSHUT		; Call open shutter subroutine
	JMP	<FINISH		; Send 'DON' reply
CLOSE	JSR	CSHUT		; Call close shutter subroutine
	JMP	<FINISH		; Send 'DON' reply


;  **************  BEGIN  COMMAND  PROCESSING  ***************
; Subroutine to turn analog power OFF
PWR_OFF_SUBROUTINE
	MOVE	X:<HDR_ID,X0
	MOVE	X0,Y:<COM_HDR
	BCLR	#9,X:PBDDR	; Make sure PWREN is an input
	MOVE	X:<TIMING,A
	MOVE	A,X:(R3)+       ; Header from Utility to timing board
	MOVE	#'POF',A
	MOVE	A,X:(R3)+       ; Let the timing board power off
	MOVE	#*+3,N4		; Set internal jump address after 'DON'
	JMP	<XMT_CHK	; Send the command to the timing board
	RTS

; Power OFF command execution
PWR_OFF	JSR	<PWR_OFF_SUBROUTINE
	JMP	<PWR_END		; Reply 'DON'

; Start power-on cycle
PWR_ON	JSR	<PWR_OFF_SUBROUTINE ; Turn everything OFF

	MOVE	X:<TIMING,A
	MOVE	A,X:(R3)+       ; Header from Utility to timing board
	MOVE	#'PON',A
	MOVE	A,X:(R3)+       ; Let the timing board power on
	MOVE	#*+3,N4		; Set internal jump address after 'DON'
	JMP	<XMT_CHK	; Send the command to the timing board

; Now check that the low voltages +/- 15 volts are in range
	MOVEP   #2,Y:WR_MUX     ; Select +15V MUX input
	MOVE	#65000,X0
	DO      X0,WT_PON2	; Wait 20 millisec or so for settling
	REP	#5
	MOVEP	Y:WATCH,X0	; Reset watchdog timer
WT_PON2
        MOVEP   Y:STR_ADC,X0    ; Start A/D conversion - dummy read
        DO	#DLY_AD,L_PON2	; Wait for the A/D to settle
        CLR     A  X:<CFFF,X0	; This saves some space
L_PON2
        MOVEP   Y:RD_ADC,A1     ; Get the A/D value
        AND     X0,A  Y:<T_P15,X0 ; A/D is only valid to 12 bits

; Test that the voltage is in the range abs(initial - target) < margin
        SUB     X0,A  A1,Y:<I_P15
        ABS     A  Y:<K_P15,X0
        SUB     X0,A
        JGT     <PERR           ; Take corrective action

TST_M15 MOVEP   #3,Y:WR_MUX     ; Select -15v MUX input
        DO	#DLY_MUX,L_PON3	; Wait for the MUX to settle
        NOP
L_PON3
        MOVEP   Y:STR_ADC,X0    ; Start A/D conversion - dummy read
        DO	#DLY_AD,L_PON4	; Wait for the A/D to settle
        CLR     A  X:<CFFF,X0	; Clear A, so put it in DO loop
L_PON4
        MOVEP   Y:RD_ADC,A1     ; Get the A/D value
        AND     X0,A  Y:<T_M15,X0 ; A/D is only valid to 12 bits

; Test that the voltage is in the range abs(initial - target) < margin
        SUB     X0,A  A1,Y:<I_M15
        ABS     A  Y:<K_M15,X0
        SUB     X0,A
        JGT     <PERR

; Test that the high voltage +36 is in range
	MOVEP   #1,Y:WR_MUX     ; Select high voltage MUX input
	MOVE	#65000,X0
	DO      X0,WT_HV	; Wait a few millisec for settling
	NOP
WT_HV
	MOVEP   Y:STR_ADC,X0    ; Start A/D conversion - dummy read
	DO	#DLY_AD,L_PON6	; Wait for the A/D to settle
	CLR     A  X:<CFFF,X0	; Clear A, so put it in DO loop
L_PON6
	MOVEP   Y:RD_ADC,A1     ; Get the A/D value
	AND     X0,A  Y:<T_HV,X0 ; A/D is only valid to 12 bits

; Test that the voltage is in the range abs(initial - target) < margin
	SUB     X0,A  A1,Y:<I_HV
	ABS     A  Y:<K_HV,X0
	SUB     X0,A
	JGT     <PERR           ; Take corrective action

; Reply with a DONE message to the host computer
PWR_END	MOVE	Y:<COM_HDR,X0
	MOVE    X0,X:<HDR_ID       	; Header to host
	JMP     <FINISH			; Go transmit reply

; Or, return with an error message
PERR	MOVE	Y:<COM_HDR,X0
	MOVE    X0,X:<HDR_ID       	; Header to host
	JSR	<PWR_OFF_SUBROUTINE 	; Turn power OFF if there's an error
	MOVE	Y:<COM_HDR,X0
	MOVE    X0,X:<HDR_ID       	; Header to host
	JMP     <ERROR			; Go transmit reply

; Delay between power control board instructions
PWR_DLY	DO	#4000,L_DLY
	NOP			
L_DLY
	RTS

; Start an exposure by first issuing a 'CLR' to the timing board
START_EX
	MOVE	X:<HDR_ID,X0	; Save header of device issuing command
	MOVE	X0,Y:<COM_HDR
	MOVE	X:<TIMING,A
	MOVE	A,X:(R3)+       ; Header from Utility to timing
	MOVE	Y:<CLR,A
	MOVE	A,X:(R3)+       ; Clear the CCD
	MOVE	#*+3,N4		; Set internal jump address after 'DON'
	JMP	<XMT_CHK	; Send the command to the timing board

; Come to here after timing board has signaled that clearing is done
	BSET	#STRT_EX,X:<STATUS
	BSET    #ST_EX,X:<STATUS ; Exposure is in progress
	MOVE	#$010302,X0
	MOVE    X0,X:<HDR_ID	; Header to device issuing 'SEX' command
	MOVE	#'IIA',X0	; Rev. 1.7 voodoo command
	JMP     <FINISH1	; Issue 'DON' and get next command

PAUSE   BCLR    #ST_EX,X:<STATUS ; Take out of exposing mode
        JSSET   #OPT_SH,X:<OPTIONS,CSHUT ; Close shutter if needed
        JMP     <FINISH		; Issue 'DON' and get next command

RESUME	BSET    #ST_EX,X:<STATUS ; Put in exposing mode
	JSSET   #OPT_SH,X:<OPTIONS,OSHUT ; Open shutter if needed
        JMP     <FINISH		; Issue 'DON' and get next command

ABORT	BCLR    #ST_EX,X:<STATUS ; Take out of exposing mode
	MOVE	X:<HDR_ID,X0	; Save header of device issuing command
	MOVE	X0,Y:<COM_HDR
	JSR     <CSHUT          ; Close the shutter
	MOVE    X:<TIMING,A
	MOVE    A,X:(R3)+       ; Header from Utility to timing
	MOVE    Y:<IDL,A
	MOVE    A,X:(R3)+       ; Put timing board in IDLE mode
	MOVE	#*+3,N4		; Set internal jump address after 'DON'
	JMP	<XMT_CHK	; Send the command to the timing board
	MOVE	Y:<COM_HDR,X0
	MOVE    X0,X:<HDR_ID	; Header to device issuing 'AEX' command
	JMP     <FINISH		; Issue 'DON' and get next command

; A 'DON' reply has been received in response to a command issued by
;    the Utility board. Read the X:STATUS bits in responding to it.

; Test if an internal program jump is needed after receiving a 'DON' reply
PR_DONE	MOVE	N4,R0		; Get internal jump address
	MOVE	#<START,N4	; Set internal jump address to default
	JMP	(R0)		; Jump to the internal jump address

; Check for program overflow - its hard to overflow since this application
;   can be very large indeed
	IF	@CVS(N,*)>APL_XY
        WARN    'Application P: overflow!'	; Make sure next application
	ENDIF					;  will not be overwritten

; Command table resident in X: data memory
;  The last part of the command table is not defined for "bootrom"
;     because it contains application-specific commands

	IF	@SCP("DOWNLOAD","HOST")
	ORG	X:COM_TBL,X:COM_TBL
	ELSE			; Memory offsets for generating EEPROMs
        ORG     P:COM_TBL,P:APL_XY
	ENDIF
	DC	'PON',PWR_ON	; Power ON
	DC      'POF',PWR_OFF	; Power OFF
	DC	'SEX',START_EX	; Start exposure
	DC	'PEX',PAUSE	; Pause exposure
	DC	'REX',RESUME	; Resume exposure
	DC	'AEX',ABORT	; Abort exposure
	DC	'OSH',OPEN	; Open shutter
	DC	'CSH',CLOSE	; Close shutter
	DC      'DON',PR_DONE	; Process DON reply
	DC	0,START,0,START,0,START,0,START
	DC	0,START,0,START,0,START

; Y: parameter table definitions, containing no "bootrom" definitions
	IF	@SCP("DOWNLOAD","HOST")
	ORG	Y:0,Y:0		; Download address
	ELSE
        ORG     Y:0,P:		; EEPROM address continues from P: above
	ENDIF
DIG_IN  DC      0       ; Values of 16 digital input lines
DIG_OUT DC      0       ; Values of 16 digital output lines
DAC0    DC      0       ; Table of four DAC values to be output
DAC1    DC      1000               
DAC2    DC      2000            
DAC3    DC      3000            
NUM_AD  DC      16      ; Number of inputs to A/D converter
AD_IN   DC      0,0,0,0,0,0,0,0
        DC      0,0,0,0,0,0,0,0 ; Table of 16 A/D values
EL_TIM_MSECONDS  DC      0       ; Number of milliseconds elapsed
TGT_TIM DC      6000    ; Number of milliseconds desired in exposure
U_CCDT  DC      $C20    ; Upper range of CCD temperature control loop
L_CCDT  DC      $C50    ; Lower range of CCD temperature control loop
K_CCDT  DC      85      ; Constant of proportionality for CCDT control
A_CCDT  EQU     AD_IN+5 ; Address of CCD temperature in A/D table
T_CCDT	DC	$0FFF	; Target CCD T for small increment algorithmn
T_COEFF	DC	$010000	; Coefficient for difference in temperatures
DAC0_LS	DC	0	; Least significant part of heater voltage

; Define power supply turn-on variables
	IF	@SCP("POWER","R6")
T_HV	DC      $240    ; Target HV supply voltage for Rev 6 pwr contl board
	ELSE
T_HV	DC      $4D0    ; Target HV supply voltage for Rev 2 or 3 boards
	ENDIF
K_HV	DC      $080    ; Tolerance of HV supply voltage
T_P15   DC      $5C0    ; Target +15 volts supply voltage
K_P15   DC      $080     ; Tolerance of +15 volts supply voltage
T_M15   DC      $A40    ; Target -15 volts supply voltage
K_M15   DC      $080     ; Tolerance of -15 volts supply voltage
I_HV	DC      0       ; Initial value of HV
I_P15   DC      0       ; Initial value of +15 volts
I_M15   DC      0       ; Initial value of -15 volts

; Define some command names
CLR     DC      'CLR'   ; Clear CCD
RDC     DC      'RDC'   ; Readout CCD
ABR     DC      'ABR'   ; Abort readout
OSH     DC      'OSH'   ; Open shutter connected to timing board
CSH     DC      'CSH'   ; Close shutter connected to timing board
POK     DC      'POK'   ; Message to host - power in OK
PER     DC      'PER'   ; Message to host - ERROR in power up sequence
SBV	DC	'SBV'	; Message to timing - set bias voltages
IDL	DC	'IDL'	; Message to timing - put camera in idle mode
STP	DC	'STP'	; Message to timing - Stop idling
CSW	DC	'CSW'	; Message to timing - clear switches

; Miscellaneous
CC00	DC	$C00	; Maximum heater voltage so the board doesn't burn up
SV_A1	DC	0	; Save register A1 during analog processing
SV_SR	DC	0	; Save status register during timer processing
EL_TIM_FRACTION DC 0	; Fraction of a millisecond of elapsed exposure time
INCR	DC	$CCCCCC	; Exposure time increment = 0.8 milliseconds
SH_DEL	DC	10	; Shutter closing time
TEMP	DC	0	; Temporary storage location for X:PBD word
COM_HDR	DC	0	; Header of command being executed

; During the downloading of this application program the one millisecond 
;   timer interrupts are enabled, so the utility board will attempt to execute 
;   the partially downloaded TIMER routine, and crash. A workaround is to 
;   put a RTI as the first instruction of TIMER so it doesn't execute, then 
;   write the correct instruction only after all the rest of the application 
;   program has been downloaded. Here it is - 

	ORG	P:APL_ADR,P:APL_ADR
	JMP	<SERVICE		; Millisecond timer interrupt
	MOVEC	SR,Y:<SV_SR 		; Save Status Register


	ENDSEC		; End of SECTION UTILAPPL

; End of program
        END 
