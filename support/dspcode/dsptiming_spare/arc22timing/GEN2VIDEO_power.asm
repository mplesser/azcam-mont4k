; GEN2VIDEO_power.asm
; Power related code

; *******************************************************************
POWER_OFF
	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs
	BSET	#LVEN,X:HDR 
	BSET	#HVEN,X:HDR 
	JMP	<FINISH

; *******************************************************************
; Execute the power-on cycle, as a command
POWER_ON
	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs

; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and delay
	BCLR	#LVEN,X:HDR		; Set these signals to DSP outputs 
	MOVE	#2000000,X0
	DO      X0,*+3			; Wait 20 millisec for settling
	NOP 	

; Turn on the high +36 volt power line and delay
	BCLR	#HVEN,X:HDR		; HVEN = Low => Turn on +36V
	MOVE	#2000000,X0
	DO      X0,*+3			; Wait 20 millisec for settling
	NOP

	JCLR	#PWROK,X:HDR,PWR_ERR	; Test if the power turned on properly
	JSR	<SET_BIASES		; Turn on the DC bias supplies
	MOVE	#IDLE,R0		; Put controller in IDLE state
	MOVE	R0,X:<IDL_ADR
	JMP	<FINISH

; The power failed to turn on because of an error on the power control board
PWR_ERR	BSET	#LVEN,X:HDR		; Turn off the low voltage emable line
	BSET	#HVEN,X:HDR		; Turn off the high voltage emable line
	JMP	<ERROR

; *******************************************************************
SET_BIAS_VOLTAGES
	JSR	<SET_BIASES
	JMP	<FINISH

; Set all the DC bias voltages and video processor offset values, reading
;   them from the 'DACS' table
SET_BIASES
	BSET	#3,X:PCRD		; Turn on the serial clock
	BCLR	#1,X:<LATCH		; Separate updates of clock driver
	BSET	#CDAC,X:<LATCH		; Disable clearing of DACs
	BSET	#ENCK,X:<LATCH		; Enable clock and DAC output switches
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
	JSR	<PAL_DLY		; Delay for all this to happen

; Read DAC values from a table, and write them to the DACs
;	MOVE	#DACS,R0		; Get starting address of DAC values
	MOVE	Y:<ADACS,R0		; MPL
	NOP
	NOP
	NOP
	DO      Y:(R0)+,L_DAC		; Repeat Y:(R0)+ times
	MOVE	Y:(R0)+,A		; Read the table entry
	JSR	<XMIT_A_WORD		; Transmit it to TIM-A-STD
	NOP
L_DAC

; Let the DAC voltages all ramp up before exiting
	MOVE	#400000,X0
	DO	X0,*+3			; 4 millisec delay
	NOP
	BCLR	#3,X:PCRD		; Turn the serial clock off
	RTS

; *******************************************************************
CLR_SWS	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs
	JMP	<FINISH

CLEAR_SWITCHES_AND_DACS
	BCLR	#CDAC,X:<LATCH		; Clear all the DACs
	BCLR	#ENCK,X:<LATCH		; Disable all the output switches
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
	BSET	#3,X:PCRD	; Turn the serial clock on
	MOVE	#$0C3000,A	; Value of integrate speed and gain switches
	CLR	B
	MOVE	#$100000,X0	; Increment over board numbers for DAC writes
	MOVE	#$001000,X1	; Increment over board numbers for WRSS writes
	DO	#15,L_VIDEO	; Fifteen video processor boards maximum
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	ADD	X0,A
	MOVE	B,Y:WRSS
	JSR	<PAL_DLY	; Delay for the serial data transmission
	ADD	X1,B
L_VIDEO	
	BCLR	#3,X:PCRD		; Turn the serial clock off
	RTS
