; ARC22.asm

; This file is used to generate DSP code for the 250 MHz fiber optic
; ARC22 timing board using a DSP56303 as its main processor.

; This version is for SPUD.
; 19Sep12 last change MPL

	PAGE    132     ; Printronix page width - 132 columns

; *** include header,  boot code, and board configuration files ***
	INCLUDE	"ARC22_hdr.asm"
	INCLUDE	"ARC22_boot.asm"

	INCLUDE	"SystemConfig.asm"

	ORG	P:,P:

; Put number of words of application in P: for loading application from EEPROM
	DC	TIMBOOT_X_MEMORY-@LCV(L)-1

; *******************************************************************
; Shift and read CCD
RDCCD
	BSET	#ST_RDC,X:<STATUS 	; Set status to reading out
	JSR	<PCI_READ_IMAGE		; Get the PCI board reading the image

	JSET	#TST_IMG,X:STATUS,SYNTHETIC_IMAGE	; jump for fake image

	MOVE	Y:<AFPXFER0,R0		; frame transfer
	JSR	<CLOCK
	MOVE  #<FRAMET,R0
	JSR   <PQSKIP
	JCS	<START

	MOVE  #<NPPRESKIP,R0		; skip to underscan
	JSR   <PSKIP
	JCS	<START
	MOVE	Y:<AFPXFER2,R0
	JSR	<CLOCK
	MOVE  #<NSCLEAR,R0
	JSR	<FSSKIP

	MOVE  #<NPUNDERSCAN,R0		; read underscan
	JSR   <PDATA
	JCS	<START

	MOVE	Y:<AFPXFER0,R0		; skip to ROI
	JSR	<CLOCK
	MOVE  #<NPSKIP,R0
	JSR   <PSKIP
	JCS	<START
	MOVE	Y:<AFPXFER2,R0
	JSR	<CLOCK
	MOVE  #<NSCLEAR,R0		
	JSR	<FSSKIP

	MOVE  #<NPDATA,R0		; read ROI
	JSR   <PDATA
	JCS	<START

;	MOVE  #<NPOVERSCAN,A		; test parallel overscan
;	TST	A
;	JLE	<RDC_END

;	MOVE	Y:<AFPXFER0,R0		; skip to overscan
;	JSR	<CLOCK
;	MOVE  #<NPPOSTSKIP,R0
;	JSR   <PSKIP
;	JCS	<START
;	MOVE	Y:<AFPXFER2,R0
;	JSR	<CLOCK
;	MOVE  #<NSCLEAR,R0
;	JSR	<FSSKIP

;	MOVE  #<NPOVERSCAN,R0		; read parallel overscan
;	JSR   <PDATA
;	JCS	<START

RDC_END	
	JCLR	#IDLMODE,X:<STATUS,NO_IDL	; Don't idle after readout
	MOVE	#IDLE,R0
	MOVE	R0,X:<IDL_ADR
	JMP	<RDC_E
NO_IDL
	MOVE	#<TST_RCV,R0
	MOVE	R0,X:<IDL_ADR
RDC_E
	JSR	<WAIT_TO_FINISH_CLOCKING
	BCLR	#ST_RDC,X:<STATUS		; Set status to not reading out

	JMP	<START			; DONE flag set by PCI when finished

; *******************************************************************
PDATA
	JSR	<CNPAMPS		; compensate for split register
	JLE	<PDATA0
	DO	A,PDATA0		; loop through # of binned rows into each serial register
	MOVE	#<NPBIN,R0		; shift NPBIN rows into serial register
	JSR	<PDSKIP
	JCC	<PDATA1
	ENDDO
	JMP	<PDATA0
PDATA1
	MOVE	#<NSPRESKIP,R0	; skip to serial underscan
	JSR	<SSKIP
	MOVE	#<NSUNDERSCAN,R0	; read underscan
	JSR	<SDATA
	MOVE	#<NSSKIP,R0		; skip to ROI
	JSR	<SSKIP
	MOVE	#<NSDATA,R0		; read ROI
	JSR	<SDATA
	MOVE	#<NSPOSTSKIP,R0	; skip to serial overscan
	JSR	<SSKIP
	MOVE	#<NSOVERSCAN,R0	; read overscan 
	JSR	<SDATA
	BCLR	#0,SR			; set CC
	NOP
	NOP
	NOP
PDATA0
	RTS

; *******************************************************************
PDSKIP
	MOVE	Y:(R0),A		; shift data lines into serial reg
	TST	A
	JLE	<PDSKIP0
	DO	Y:(R0),PDSKIP0
	MOVE	Y:<APDXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PDSKIP1
	ENDDO
	NOP
PDSKIP1
	NOP
PDSKIP0
	RTS

; *******************************************************************
PSKIP
	JSR	<CNPAMPS
	JLE	<PSKIP0
	DO	A,PSKIP0
	MOVE	Y:<APXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PSKIP1
	ENDDO
	NOP
PSKIP1
	NOP
PSKIP0
	RTS

; *******************************************************************
PQSKIP
	JSR	<CNPAMPS
	JLE	<PQSKIP0
	DO	A,PQSKIP0
	MOVE	Y:<APQXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PQSKIP1
	ENDDO
	NOP
PQSKIP1
	NOP
PQSKIP0
	RTS

; *******************************************************************
RSKIP
	JSR	<CNPAMPS
	JLE	<RSKIP0
	DO	A,RSKIP0
	MOVE	Y:<ARXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<RSKIP1
	ENDDO
	NOP
RSKIP1
	NOP
RSKIP0
	RTS

; *******************************************************************
FSSKIP
	JSR	<CNSAMPS
	JLE	<FSSKIP0
	DO	A,FSSKIP0
	MOVE	Y:<AFSXFER,R0
	JSR	<CLOCK
	NOP
FSSKIP0
	RTS

; *******************************************************************
SSKIP
	JSR	<CNSAMPS
	JLE	<SSKIP0
	DO	A,SSKIP0
	MOVE	Y:<ASXFER0,R0
	JSR	<CLOCK
	MOVE	Y:<ASXFER2,R0
	JSR	<CLOCK
	NOP
SSKIP0
	RTS

; *******************************************************************
SDATA
	JSR	<CNSAMPS
	JLE	<SDATA0
	DO	A,SDATA0
	MOVE	Y:<ASXFER0,R0
	JSR	<CLOCK
	MOVE	X:<ONE,X0				; Get bin-1
	MOVE	Y:<NSBIN,A
	SUB	X0,A
	JLE	<SDATA1
	DO	A,SDATA1
	MOVE	Y:<ASXFER1,R0
	JSR	<CLOCK
	NOP
SDATA1
	MOVE	Y:<ASXFER2D,R0
	JSR	<CLOCK
SDATA0T
	NOP
SDATA0
	RTS

; *******************************************************************
; Compensate count for split serial
CNSAMPS	MOVE	Y:(R0),A		; get num pixels to read
	JCLR	#0,Y:<NSAMPS,CNSSHIFTLL	; split register?
	ASR	A				; yes, divide by 2
CNSSHIFTLL	TST	A
	RTS

; *******************************************************************
; Compensate count for split parallel
CNPAMPS	MOVE	Y:(R0),A		; get num rows to shift
	JCLR	#0,Y:<NPAMPS,CNPSHIFTLL	; split parallels?
	ASR	A				; yes, divide by 2
CNPSHIFTLL	TST	A				
	NOP					; MPL for Gen3
	NOP					; MPL for Gen3
	BCLR	#0,SR				; clear carry
	NOP					; MPL for Gen3
	RTS

; *******************************************************************
; slow clock for parallel shifts - Gen3 version
PCLOCK
	JCLR	#SSFHF,X:HDR,*		; Only write to FIFO if < half full
	NOP
	JCLR	#SSFHF,X:HDR,PCLOCK	; Guard against metastability
	MOVE    Y:(R0)+,X0      	; # of waveform entries 
	DO      X0,PCLK1			; Repeat X0 times
	MOVE	Y:(R0)+,A			; get waveform
	DO	Y:<PMULT,PCLK2
	MOVEP	A,Y:WRSS			; 30 nsec write the waveform to the SS 	
PCLK2	NOP
PCLK1 NOP
	RTS                     	; Return from subroutine

; *******************************************************************
CLEAR	JSR	<CLR_CCD			; clear CCD, executed as a command
	JMP     <FINISH

; *******************************************************************
CLR_CCD
	MOVE	Y:<AFPXFER0,R0		; prep for fast flush
	JSR	<CLOCK
	MOVE    #<NPCLEAR,R0		; shift all rows
	JSR     <PQSKIP			
	MOVE	Y:<AFPXFER2,R0		; set clocks on clear exit
	JSR	<CLOCK
	MOVE    #<NSCLEAR,R0		; flush serial register
	JSR	<FSSKIP
	RTS

; *******************************************************************
FOR_PSHIFT
	MOVE	#<NPXSHIFT,R0		; forward shift rows
	JSR	<PSKIP
	JMP	<FINISH

; *******************************************************************
REV_PSHIFT
	MOVE	#<NPXSHIFT,R0		; reverse shift rows
	JSR	<RSKIP
	JMP	<FINISH

; *******************************************************************
; Set software to IDLE mode
START_IDLE_CLOCKING
	MOVE	#IDLE,R0			; Exercise clocks when idling
	MOVE	R0,X:<IDL_ADR
	BSET	#IDLMODE,X:<STATUS	; Idle after readout
	JMP     <FINISH			; Need to send header and 'DON'

; Keep the CCD idling when not reading out - MPL modified for AzCam
IDLE	DO      Y:<NSCLEAR,IDL1	; Loop over number of pixels per line
	MOVE    Y:<AFSXFER,R0 	; Serial transfer on pixel
	JSR     <CLOCK  		; Go to it
	MOVE	#COM_BUF,R3
	JSR	<GET_RCV		; Check for FO or SSI commands
	JCC	<NO_COM			; Continue IDLE if no commands received
	ENDDO
	JMP     <PRC_RCV		; Go process header and command
NO_COM	NOP
IDL1
	MOVE    Y:<APQXFER,R0	; Address of parallel clocking waveform
	JSR     <CLOCK  		; Go clock out the CCD charge
;	JSR     <PCLOCK  		; Go clock out the CCD charge
	JMP     <IDLE

; *******************************************************************

; Misc routines

; POWER_OFF
; POWER_ON
; SET_BIASES
; CLR_SWS
; CLEAR_SWITCHES_AND_DACS
; OPEN_SHUTTER
; CLOSE_SHUTTER
; OSHUT
; CSHUT
; EXPOSE
; START_EXPOSURE
; SET_EXPOSURE_TIME
; READ_EXPOSURE_TIME
; PAUSE_EXPOSURE
; RESUME_EXPOSURE
; ABORT_ALL
; SYNTHETIC_IMAGE
; XMT_PIX
; READ_AD
; PCI_READ_IMAGE
; WAIT_TO_FINISH_CLOCKING
; CLOCK
; PAL_DLY
; READ_CONTROLLER_CONFIGURATION
; ST_GAIN
; SET_DC
; SET_BIAS_NUMBER
; 

	INCLUDE	"POWERCODE"

; *******************************************************************
; Open the shutter by setting the backplane bit TIM-LATCH0
; reversed for ITL prober
OSHUT	BSET  #ST_SHUT,X:<STATUS 	; Set status bit to mean shutter open
	BSET	#SHUTTER,X:<LATCH	; Clear hardware shutter bit to open
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
      RTS

; *******************************************************************
; Close the shutter by clearing the backplane bit TIM-LATCH0
; reversed for ITL prober
CSHUT	BCLR  #ST_SHUT,X:<STATUS 	; Clear status to mean shutter closed
	BCLR	#SHUTTER,X:<LATCH	; Set hardware shutter bit to close
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
      RTS

; *******************************************************************
; Open the shutter from the timing board, executed as a command
OPEN_SHUTTER
	JSR	<OSHUT
	JMP	<FINISH

; *******************************************************************
; Close the shutter from the timing board, executed as a command
CLOSE_SHUTTER
	JSR	<CSHUT
	JMP	<FINISH

; *******************************************************************
; Start the exposure timer and monitor its progress
EXPOSE	MOVE	X:<EXPOSURE_TIME,B
	TST	B			; Special test for zero exposure time
	JEQ	<END_EXP		; Don't even start an exposure
	SUB	#1,B			; Timer counts from X:TCPR0+1 to zero
	BSET	#TIM_BIT,X:TCSR0	; Enable the timer #0
	MOVE	B,X:TCPR0

; special check for short shutter time MPL
CHK_RCV	
	MOVE	X:<EXPOSURE_TIME,A
	SUB	#200,A
	TST	A
	JLE	CHK_TIM

;CHK_RCV	
	MOVE	#COM_BUF,R3		; The beginning of the command buffer
	JCLR    #EF,X:HDR,EXP1		; Simple test for fast execution
	JSR	<GET_RCV		; Check for an incoming command
	JCS	<PRC_RCV		; If command is received, go check it
EXP1	JCLR	#ST_DITH,X:STATUS,CHK_TIM
	MOVE	Y:<AFSXFER,R0
	JSR	<CLOCK
CHK_TIM	JCLR	#TCF,X:TCSR0,CHK_RCV	; Wait for timer to equal compare value
END_EXP	BCLR	#TIM_BIT,X:TCSR0	; Disable the timer
	JMP	(R7)			; This contains the return address

; *******************************************************************
; Start the exposure, operate the shutter, and initiate CCD readout
START_EXPOSURE
	MOVE	#$020102,B
	JSR	<XMT_WRD
	MOVE	#'IIA',B			; responds to host with DON
	JSR	<XMT_WRD			;  indicating exposure started

	MOVE	#<TST_RCV,R0		; Process commands, don't idle, 
	MOVE	R0,X:<IDL_ADR		;  during the exposure
	JCLR	#SHUT,X:STATUS,L_SEX0
	JSR	<OSHUT			; Open the shutter if needed
L_SEX0	MOVE	#L_SEX1,R7		; Return address at end of exposure
	JMP	<EXPOSE			; Delay for specified exposure time
L_SEX1
	JCLR	#SHUT,X:STATUS,S_DEL0
	JSR	<CSHUT			; Close the shutter if necessary

; shutter delay
	MOVE	Y:<SH_DEL,A
	TST	A
	JLE	<S_DEL0
	MOVE	X:<C100K,X0			; assume 100 MHz DSP             
	DO	A,S_DEL0			; Delay by Y:SH_DEL milliseconds
	DO	X0,S_DEL1
	NOP
S_DEL1	NOP
S_DEL0	NOP

	JMP	<START			; finish

; *******************************************************************
; Set the desired exposure time
SET_EXPOSURE_TIME
	MOVE	X:(R3)+,Y0
	MOVE	Y0,X:EXPOSURE_TIME
	MOVEP	X:EXPOSURE_TIME,X:TCPR0
	JMP	<FINISH

; *******************************************************************
; Read the time remaining until the exposure ends
READ_EXPOSURE_TIME
	MOVE	X:TCR0,Y1		; Read elapsed exposure time
	JMP	<FINISH1

; *******************************************************************
; Pause the exposure - close the shutter, and stop the timer
PAUSE_EXPOSURE
	BCLR    #TIM_BIT,X:TCSR0	; Disable the DSP exposure timer
	JSR	<CSHUT			; Close the shutter
	JMP	<FINISH

; *******************************************************************
; Resume the exposure - open the shutter if needed and restart the timer
RESUME_EXPOSURE
	BSET	#TIM_BIT,X:TCSR0	; Re-enable the DSP exposure timer
	JCLR	#SHUT,X:STATUS,L_RES
	JSR	<OSHUT			; Open the shutter ir necessary
L_RES	JMP	<FINISH

; *******************************************************************
; Special ending after abort command to send a 'DON' to the host computer
ABORT_ALL
	BCLR    #TIM_BIT,X:TCSR0	; Disable the DSP exposure timer
	JSR	<CSHUT			; Close the shutter
	MOVE	#100000,X0
	DO	X0,L_WAIT0		; Wait one millisecond to delimit
	NOP				;   image data and the 'DON' reply
L_WAIT0
	JCLR	#IDLMODE,X:<STATUS,NO_IDL2 ; Don't idle after readout
	MOVE	#IDLE,R0
	MOVE	R0,X:<IDL_ADR
	JMP	<RDC_E2
NO_IDL2	MOVE	#<TST_RCV,R0
	MOVE	R0,X:<IDL_ADR
RDC_E2	JSR	<WAIT_TO_FINISH_CLOCKING
	BCLR	#ST_RDC,X:<STATUS	; Set status to not reading out

	MOVE	#$000202,X0		; Send 'DON' to the host computer
	MOVE	X0,X:<HEADER
	JMP	<FINISH

; *******************************************************************
; Generate a synthetic image by simply incrementing the pixel counts
SYNTHETIC_IMAGE
	CLR	A
;	DO      Y:<NPR,LPR_TST      	; Loop over each line readout
;	DO      Y:<NSR,LSR_TST		; Loop over number of pixels per line
	DO      Y:<NPIMAGE,LPR_TST      	; Loop over each line readout
	DO      Y:<NSIMAGE,LSR_TST		; Loop over number of pixels per line
	REP	#20			; #20 => 1.0 microsec per pixel
	NOP
	ADD	#1,A			; Pixel data = Pixel data + 1
	NOP
	MOVE	A,B
	JSR	<XMT_PIX		;  transmit them
	NOP
LSR_TST	
	NOP
LPR_TST	
        JMP     <RDC_END		; Normal exit

; *******************************************************************
; Transmit the 16-bit pixel datum in B1 to the host computer
XMT_PIX	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	RTS

; *******************************************************************
; Test the hardware to read A/D values directly into the DSP instead
;   of using the SXMIT option, A/Ds #2 and 3.
READ_AD	MOVE	X:(RDAD+2),B
	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	REP	#10
	NOP
	MOVE	X:(RDAD+3),B
	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	REP	#10
	NOP
	RTS

; *******************************************************************
; Alert the PCI interface board that images are coming soon
PCI_READ_IMAGE
	MOVE	#$020104,B		; Send header word to the FO transmitter
	JSR	<XMT_WRD
	MOVE	#'RDA',B
	JSR	<XMT_WRD
;	MOVE	Y:NSR,B			; Number of columns to read
	MOVE	Y:NSIMAGE,B			; Number of columns to read
	JSR	<XMT_WRD
;	MOVE	Y:NPR,B			; Number of rows to read		
	MOVE	Y:NPIMAGE,B			; Number of columns to read
	JSR	<XMT_WRD
	RTS

; *******************************************************************
; Wait for the clocking to be complete before proceeding
WAIT_TO_FINISH_CLOCKING
	JSET	#SSFEF,X:PDRD,*		; Wait for the SS FIFO to be empty	
	RTS

; *******************************************************************
; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
;   and 10 nanosec for the wait state that is required for SRAM writes and 
;   FIFO setup times. It looks reliable, so will be used for now.

; Core subroutine for clocking out CCD charge
CLOCK
	JCLR	#SSFHF,X:HDR,*		; Only write to FIFO if < half full
	NOP
	JCLR	#SSFHF,X:HDR,CLOCK	; Guard against metastability
	MOVE    Y:(R0)+,X0      	; # of waveform entries 
	DO      X0,CLK1                 ; Repeat X0 times
	MOVEP	Y:(R0)+,Y:WRSS		; 30 nsec Write the waveform to the SS 	
CLK1
	NOP
	RTS                     	; Return from subroutine

; *******************************************************************
; Work on later !!!
; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec 
;   the one wait state that is required for SRAM writes and FIFO setup times. 
;   However, the assembler gives a WARNING about pipeline problems if its
;   put in a DO loop. This problem needs to be resolved later, and in the
;   meantime I'll be using the MOVEP instruction. 

;	MOVE	#$FFFF03,R6		; Write switch states, X:(R6)
;	MOVE	Y:(R0)+,A  A,X:(R6)

; Delay for serial writes to the PALs and DACs by 8 microsec
PAL_DLY	DO	#800,DLY	 ; Wait 8 usec for serial data transmission
	NOP
DLY	NOP
	RTS

; *******************************************************************
; Let the host computer read the controller configuration
READ_CONTROLLER_CONFIGURATION
	MOVE	Y:<CONFIG,Y1		; Just transmit the configuration
	JMP	<FINISH1

; *******************************************************************
; Set the video processor boards in DC-coupled diagnostic mode or not
; Command syntax is  SDC #	# = 0 for normal operation
;				# = 1 for DC coupled diagnostic mode
SET_DC	BSET	#3,X:PCRD	; Turn the serial clock on
	MOVE	X:(R3)+,X0
	JSET	#0,X0,SDC_1
	BCLR	#10,Y:<GAIN
	BCLR	#11,Y:<GAIN
	JMP	<SDC_A
SDC_1	BSET	#10,Y:<GAIN
	BSET	#11,Y:<GAIN
SDC_A	MOVE	#$100000,X0	; Increment value
	DO	#15,SDC_LOOP
	MOVE	Y:<GAIN,A
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	JSR	<PAL_DLY	; Wait for SSI and PAL to be empty
	ADD	X0,B		; Increment the video processor board number
SDC_LOOP
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<FINISH

; include SBN command
	INCLUDE	"SBNCODE"

TIMBOOT_X_MEMORY	EQU	@LCV(L)

;  ****************  Setup memory tables in X: space ********************

; Define the address in P: space where the table of constants begins

	IF	@SCP("DOWNLOAD","HOST")
	ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
	ENDIF

	IF	@SCP("DOWNLOAD","ROM")
	ORG     X:END_COMMAND_TABLE,P:
	ENDIF

; Application commands
	DC	'PON',POWER_ON
	DC	'POF',POWER_OFF
	DC	'SBV',SET_BIAS_VOLTAGES
	DC	'IDL',START_IDLE_CLOCKING
	DC	'OSH',OPEN_SHUTTER
	DC	'CSH',CLOSE_SHUTTER
	DC	'RDC',RDCCD   
	DC	'CLR',CLEAR   

; Exposure and readout control routines
	DC	'SET',SET_EXPOSURE_TIME
	DC	'RET',READ_EXPOSURE_TIME
	DC	'SEX',START_EXPOSURE
	DC	'PEX',PAUSE_EXPOSURE
	DC	'REX',RESUME_EXPOSURE
	DC	'AEX',ABORT_ALL
	DC	'ABR',ABORT_ALL		; MPL temporary
	DC	'FPX',FOR_PSHIFT
	DC	'RPX',REV_PSHIFT

; Support routines
	DC	'SGN',ST_GAIN
	DC	'SDC',SET_DC
	DC	'SBN',SET_BIAS_NUMBER
	DC	'SMX',SET_MUX
	DC	'CSW',CLR_SWS
	DC	'RCC',READ_CONTROLLER_CONFIGURATION

END_APPLICATON_COMMAND_TABLE	EQU	@LCV(L)

	IF	@SCP("DOWNLOAD","HOST")
NUM_COM	EQU	(@LCV(R)-COM_TBL_R)/2	; Number of boot + application commands
EXPOSING		EQU	CHK_TIM		; Address if exposing
	ENDIF

	IF	@SCP("DOWNLOAD","ROM")
	ORG     Y:0,P:
	ENDIF

; Now let's go for the timing waveform tables
	IF	@SCP("DOWNLOAD","HOST")
 	ORG     Y:0,Y:0
	ENDIF

; *** include waveform header info ***
GENCNT	EQU	1		; clock tables index
VIDEO		EQU	$000000	; Video processor board (all are addressed together)
CLK2		EQU	$002000	; Clock driver board select = board 2 low bank 
CLK3		EQU	$003000	; Clock driver board select = board 2 high bank
CLKV		EQU	$200000	; Clock driver board DAC voltage selection address (ARC32)

; for ARC-48
VIDEO_CONFIG	EQU	$0C000C	; WARP = DAC_OUT = ON; H16B, Reset FIFOs
VID0		EQU	$000000 ; Address of the first ARC-48 video board
VID1		EQU	$100000 ; Address of the second ARC-48 video board
DAC_ADDR	EQU	$0E0000 ; DAC Channel Address
DAC_RegM	EQU	$0F4000 ; DAC m Register
DAC_RegC	EQU	$0F8000 ; DAC c Register
DAC_RegD	EQU	$0FC000 ; DAC X1 Register
VIDEO_DACS	EQU	$000000	; Address of DACs on the video board
CLK_ZERO 	EQU	$000800	; Zero volts on clock driver line

; *** include waveform table ***
	INCLUDE "WAVEFILE"

; *** DSP Y memory parameter table ***
; Values in this block start at Y:0 and are overwritten by AzCam
; All values are unbinned pixels unless noted.

CAMSTAT		DC	0	; not used
NSDATA		DC	1	; number BINNED serial columns in ROI
NPDATA		DC	1	; number of BINNED parallel rows in ROI
NSBIN		DC	1	; Serial binning parameter (>= 1)
NPBIN		DC	1	; Parallel binning parameter (>= 1)

NSAMPS		DC	0	; 0 => 1 amp, 1 => split serials
NPAMPS		DC	0	; 0 => 1 amp, 1 => split parallels
NSCLEAR		DC	1	; number of columns to clear during flush				
NPCLEAR		DC	1	; number of rows to clear during flush

NSPRESKIP	DC	0	; number of cols to skip before underscan
NSUNDERSCAN	DC	0	; number of BINNED columns in underscan
NSSKIP		DC	0	; number of cols to skip between underscan and data
NSPOSTSKIP	DC	0	; number of cols to skip between data and overscan
NSOVERSCAN	DC	0	; number of BINNED columns in overscan

NPPRESKIP	DC	0	; number of rows to skip before underscan
NPUNDERSCAN	DC	0	; number of BINNED rows in underscan
NPSKIP		DC	0	; number of rows to skip between underscan and data
NPPOSTSKIP	DC	0	; number of rows to skip between data and overscan
NPOVERSCAN	DC	0	; number of BINNED rows in overscan

NPXSHIFT	DC	0	; number of rows to parallel shift
TESTDATA	DC	0	; 0 => normal, 1 => send incremented fake data
FRAMET		DC	0	; number of storage rows for frame transfer shift
PREFLASH	DC	0	; not used 
GAIN		DC	0	; Video proc gain and integrator speed stored here
TST_DAT		DC	0	; Place for synthetic test image pixel data
SH_DEL		DC	100	; Delay (msecs) between shutter closing and image readout
CONFIG		DC	0	; Controller configuration - was CC
NSIMAGE		DC	1	; total number of columns in image
NPIMAGE		DC	1	; total number of rows in image
PAD3		DC	0	; unused
PAD4		DC	0	; unused
IDLEONE		DC	2	; lines to shift in IDLE (really 1)

; Values in this block start at Y:20 and are overwritten if waveform table
; is downloaded
PMULT			DC	PARMULT	; parallel clock multiplier
ACLEAR0		DC	TNOP		; Clear prologue - NOT USED
ACLEAR2		DC	TNOP		; Clear epilogue - NOT USED
AREAD0		DC	TNOP		; Read prologue - NOT USED
AREAD8		DC	TNOP		; Read epilogue - NOT USED
AFPXFER0	DC	FPXFER0	; Fast parallel transfer prologue
AFPXFER2	DC	FPXFER2	; Fast parallel transfer epilogue
APXFER		DC	PXFER		; Parallel transfer - storage only
APDXFER		DC	PXFER		; Parallel transfer (data) - storage only
APQXFER		DC	PQXFER	; Parallel transfer - storage and image
ARXFER		DC	RXFER		; Reverse parallel transfer (for focus)
AFSXFER		DC	FSXFER	; Fast serial transfer
ASXFER0		DC	SXFER0	; Serial transfer prologue
ASXFER1		DC	SXFER1	; Serial transfer ( * colbin-1 )
ASXFER2		DC	SXFER2	; Serial transfer epilogue - no data
ASXFER2D	DC	SXFER2D	; Serial transfer epilogue - data
ADACS		DC	DACS

; *** clock boards pins and states***
	INCLUDE "CLKPINOUT"

; *** video definitions ***
	INCLUDE "VIDDEFS"

; *** DACS table for video and clock boards ***
DACS	DC	EDACS-DACS-1
	INCLUDE "VIDBRD0"
	INCLUDE "VIDBRD1"
	INCLUDE "VIDBRD2"
	INCLUDE "VIDBRD3"
	INCLUDE "CLKBRD0"
	INCLUDE "CLKBRD1"
EDACS

; *** Timing NOP statement ***
TNOP		DC	ETNOP-TNOP-GENCNT
		DC	$00E000
		DC	$00E000
ETNOP

; *** waveforms ***
	INCLUDE "CLOCKING"

END_APPLICATON_Y_MEMORY	EQU	@LCV(L)

	END

; end of ARC22.asm
