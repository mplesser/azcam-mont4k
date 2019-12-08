       COMMENT *

This file is used to generate boot DSP code for the utility board. 
This software is for use with the timIII = 250 MHz board.     

	*
        PAGE    132	; Printronix page width - 132 columns

; Define some useful DSP register locations
RST_ISR	EQU	$00	; Hardware reset interrupt 
ROM_ID  EQU     $06     ; Location of ROM Identification words = SWI interrupt
IRQA_ISR EQU    $08     ; Address of ISRA for 1 kHz timer interrupts
SCI_ISR EQU     $14     ; SCI Receive data interrupt address
SCI_ERR EQU     $16     ; SCI Receive with exception address
START	EQU     $0A     ; Address for beginning of code
CONTINUE EQU	$18	; Address for beginning of code
BUF_STR	EQU	$80	; Starting address of buffers in X:
BUF_LEN	EQU	$20	; Length of each buffer
SCI_BUF	EQU	BUF_STR		; Starting address of SCI buffer in X:
COM_BUF EQU     SCI_BUF+BUF_LEN	; Starting address of command buffer in X:
COM_TBL EQU     COM_BUF+BUF_LEN	; Starting address of command table in X:
NUM_COM EQU     24	; Number of entries in the command table
TIMEOUT	EQU	1666	; Timeout for receiving complete command = 1 millisec
APL_ADR	EQU	$90	; Starting address of application program
APL_XY	EQU	$1EE0	; Start of application data tables
RST_OFF	EQU	$6000	; Reset code offset in EEPROM
P_OFF	EQU	$6040	; P: memory offset into EEPROM
X_OFF	EQU	$6100	; X: memory offset into EEPROM
ROM_EXE	EQU	$6200	; P: start address for routines that execute from EEPROM
DLY_MUX EQU     70      ; Number of DSP cycles to delay for MUX settling
DLY_AD  EQU     100     ; Number of DSP cycles to delay for A/D settling

; Now assign a bunch of addresses to on-chip functions
BCR     EQU     $FFFE   ; Bus (=Port A) Control Register -> Wait States
PCC     EQU     $FFE1   ; Port C Control Register
PBC     EQU     $FFE0   ; Port B Control Register
PBDDR   EQU     $FFE2   ; Port B Data Direction Register
PBD     EQU     $FFE4   ; Port B Data Register
SCR     EQU     $FFF0   ; SCI Control Register
SSR     EQU     $FFF1   ; SCI Status Register
SCCR    EQU     $FFF2   ; SCI Clock Control Register
SRX     EQU     $FFF4   ; SCI Receiver low address byte
IPR     EQU     $FFFF   ; Interrupt Priority Register

; Addresses of memory mapped components in Y: data memory space
;  Write addresses first
WR_DIG  EQU     $FFF0   ; Write Digital output values D00-D15
WR_MUX  EQU     $FFF1   ; Select MUX connected to A/D input - one of 16
EN_DIG	EQU	$FFF2	; Enable digital outputs
WR_DAC3 EQU     $FFF7   ; Write to DAC#3 D00-D11
WR_DAC2 EQU     $FFF6   ; Write to DAC#2 D00-D11
WR_DAC1 EQU     $FFF5   ; Write to DAC#1 D00-D11
WR_DAC0 EQU     $FFF4   ; Write to DAC#0 D00-D11

; Read addresses next
RD_DIG  EQU     $FFF0   ; Read Digital input values D00-D15
STR_ADC EQU     $FFF1   ; Start A/D conversion, ignore data
RD_ADC  EQU     $FFF2   ; Read A/D converter value D00-D11
WATCH   EQU     $FFF7   ; Watch dog timer - tell it that DSP is alive

; Bit definitions of STATUS word
ST_SRVC EQU     0       ; Set if SERVICE routine needs executing
ST_EX   EQU     1       ; Set if timed exposure is in progress
ST_SH   EQU     2       ; Set if shutter is open
ST_READ	EQU	3	; Set if a readout needs to be initiated

; Bit definitions of software OPTIONS word
OPT_SH  EQU     0       ; Set to open and close shutter

; Bit definitions of Port B = Host Processor Interface
HVEN	EQU     0       ; Enable high voltage PS (+36V nominal) - Output
LVEN	EQU     1       ; Enable low voltage PS (+/-15 volt nominal) - Output
PWRST	EQU     2       ; Reset power conditioner counter - Output
SHUTTER EQU     3       ; Control shutter - Output
IRQ_T   EQU     4       ; Request interrupt service from timing board - Output
SYS_RST EQU     5       ; Reset entire system - Output
WATCH_T EQU     8       ; Processed watchdog signal from timing board - Input
PWREN	EQU	9	; Enable power conditioner board - Output

;**************************************************************************
;                                                                         *
;    Register assignments  						  *
;	 R1 - Address of SCI receiver contents				  *
;	 R2 - Address of processed SCI receiver contents		  *
;        R3 - Pointer to current top of command buffer                    *
;        R4 - Pointer to processed contents of command buffer		  *
;	 N4 - Address for internal jumps after receiving 'DON' replies	  *
;        R0, R5, R6, A, X0, X1 - Freely available for program use  	  *
;	 R7 - For use by SCI ISR only                                     *
;        B, Y0 and Y1 - For use by timer ISR only                         *
;									  *
;**************************************************************************

; Initialize the DSP. Because this is executed only on DSP boot from ROM
;  it is not incorporated into any download code.

 	ORG     P:RST_OFF,P:RST_OFF                    

	MOVEC	#$02,OMR	; Normal expanded mode
	NOP			; Allow time for the remapping to occur
	JMP	INIT		; DSP resets to $E000, but we load program
				;   to EEPROM starting at RST_OFF = $6000

INIT	MOVEP   #$0238,X:PBD    ; Power enables off, shutter high
                                ;  (closed), IRQA, SYSRST
				;  LVEN = HVEN = 1 => all power off

	MOVEP   #$0238,X:PBDDR  ; H2 - H5, H9 Outputs, H0 - H2, H6 - H8 Inputs

	ORI     #$03,MR         ; Temporarily mask interrupts

        MOVEP   #$0B04,X:SCR    ; SCI programming: 11-bit asynchronous
                                ;   protocol (1 start, 8 data, 1 even parity,
                                ;   1 stop); LSB before MSB; enable receiver
                                ;   and its interrupt; transmitter interrupts
                                ;   disabled.

        MOVEP   #$0000,X:SCCR   ; SCI clock: maximum asynchronous data
                                ;   rate (390,625 kbits/sec); internal clock.

        MOVEP   #>$03,X:PCC     ; Select Port C pins 1 and 2 for the SCI.

        MOVEP   #$0033,X:BCR	; Wait states for external memory accesses
				;   3 for PROM = 150 nsec
				;   3 for A/D, DAC, etc. = 150 nsec

; Load boot program into P: memory from EEPROM
	MOVE    #P_OFF,R0	; Starting P: address in EEPROM
	MOVE    #0,R1		; Put values starting at beginning of P:
	DO      #APL_ADR+2,P_MOVE ; Boot program is APL_ADR words long
				;     +2 is for SERVICE and TIMER stubs
	MOVE    P:(R0)+,A	; Get one word from EEPROM
	MOVE	A,P:(R1)+	; Write it to DSP P: memory
P_MOVE

; Load X: data memory from EEPROM
        MOVE    #X_OFF,R0	; Starting X: address in EEPROM
        MOVE    #0,R1		; Put values starting at beginning of X:
	DO      #$100,X_MOVE	; Assume 256 = $100 values exist
        MOVE    P:(R0)+,A	; Get one word from EEPROM
        MOVE    A,X:(R1)+	; Write it to DSP X: memory
X_MOVE

; Initialize various registers
        MOVE    #SCI_BUF,R1
	MOVE	#COM_BUF,R3
	MOVE	R1,R2
        MOVE    R3,R4
        MOVE    #31,M1		; Create circular buffers, modulo 32
        MOVE    M1,M2
	MOVE	M2,M3
	MOVE	M3,M4       
	MOVE	#<START,N4
	MOVE	X:<SRX_FST,R7	; Starting address of SCI receiver
	CLR	A
	CLR	B

; Set interrupt priorities levels	
	MOVEP   #$8007,X:IPR    ; Enable IRQA = timer 
				; Change priorities for operation
				;   SCI = 1 = link to timing board
				;   IRQA = 2 = timer
				;   Host = SSI = IRQB = 0 = disabled
        ANDI    #$FC,MR         ; Unmask all interrupt levels
	JMP	<XMT_CHK

;  *****  Put interrupt service routine vectors in their required places  *****
; After RESET jump to initialization code
 	ORG     P:RST_ISR,P:RST_ISR+P_OFF                   
	JMP     INIT		; This is the interrupt service for RESET

; The IRQA ISR is a long interrupt keyed to the 1 millisecond timer 
        ORG     P:IRQA_ISR,P:IRQA_ISR+P_OFF
	JSR	TIMER		; Jump to long TIMER routine for service

; The SCI interrupts when it receives data from the timing board.
        ORG     P:SCI_ISR,P:SCI_ISR+P_OFF
	JSR     SCI_RCV		; SCI Receive data interrupt service routine

; The SCI interrupts to here when there is an error.
        ORG     P:SCI_ERR,P:SCI_ERR+P_OFF       
	JSR     CLR_ERR

; Put the ID words for this version of the ROM code. It is placed at
;   the address of the SWI = software interrupt, which we never use. 
        ORG     P:ROM_ID,P:ROM_ID+P_OFF
        DC      $000000         ; Institution
                                ; Location
                                ; Instrument
        DC      $030003         ; Version 3.00, Board #3 = Utility

; Start the command interpreting code
        ORG     P:START,P:START+P_OFF         

; Check for TIMER interrupts and go handle them if necessary
	JSSET   #ST_SRVC,X:STATUS,SERVICE ; Do all millisecond service tasks
	MOVEP	Y:WATCH,A	; Reset watchdog timer

; Test SCI receiver pointers
	MOVE    R1,A            ; Pointer to current contents of receiver
	MOVE    R2,X0           ; Pointer to processed contents
	CMP     X0,A  X:(R2),X1 ; Are they equal? Get header
	JEQ     <TST_COM	; Yes, so check the receiver stack

; Jump over the ISRs
	JMP	<CONTINUE
        ORG     P:CONTINUE,P:CONTINUE+P_OFF         

; Check candidate header = (S,D,N) for self-consistency
	MOVE	X:<MASK1,A1	; Test for S.LE.3 and D.LE.3 and N.LE.7
	AND     X1,A		; X1 = header from above
	JNE     <RCV_SKP        ; Test failed, skip over header
	MOVE	X:<MASK2,A1 	; Test for S.NE.0 or D.NE.0
	AND     X1,A 
	JEQ     <RCV_SKP        ; Test failed, skip over header
	MOVE	#7,A1		; Test for N.GE.1
	AND     X1,A		; A = NWORDS in command
	JNE     <RCV_PR         ; Test suceeded - process command
RCV_SKP MOVE    (R2)+		; Header is wrong - skip over it
	JMP	<START		; Keep monitoring receiver

; Get all the words of the command before processing it
RCV_PR	MOVE	A,X1		; Number of words in command header
	DO	#<TIMEOUT,TIM_OUT
	MOVE	R1,A
	MOVE	R2,X0
	SUB	X0,A
        JGE     <RCV_L1		; X1 = Destination mask $00FF00
        MOVE    X:<C32,X0	; Correct for circular buffer
        ADD     X0,A		; No MOVE here - it isn't always executed
RCV_L1	CMP	X1,A  X1,X:<NWORDS
	JLT	<RCV_L2
	ENDDO
	JMP	<MV_COM
RCV_L2	NOP
TIM_OUT
	JMP	<RCV_SKP	; Increment R2 and BAD_HDR

; We've got the complete SCI command, so put it on the COM_BUF stack
MV_COM	DO	X:<NWORDS,SCI_WR
	MOVE	X:(R2)+,A	; R2 = SCI address
	MOVE	A,X:(R3)+	; R3 = command buffer address
SCI_WR	

; Test the command stack too
TST_COM	MOVE    R3,A            ; Pointer to current contents of receiver
        MOVE    R4,X0           ; Pointer to processed contents
	CMP     X0,A  X:<DMASK,X1 ; Are they equal? Get destination mask
	JEQ	<START		; Go back to the top

; Process the receiver entry - is its destination number = D_BRD_ID?
	MOVE    X:(R4),A        ; Get the header
        MOVE    A,X:<HDR_ID	; Store it for later use
        AND     X1,A  X:<DBRDID,X1 ; Extract destination byte only
	CMP     X1,A  		; = destination number?
	JEQ	<COMMAND	; It's a command for this board
        JGT     <ERROR		; Destination byte > #DBRDID, so error

; Transmit command over SCI back to the timing board
XMT_CHK	MOVE	R3,A
	MOVE	R4,X0
	CMP	X0,A		; R4 is incremented by SCI_XMT
	JEQ	<START		; We're all done, so start processing anew
	JSSET   #0,X:SSR,SCI_XMT ; If SCI XMT register is empty, transmit byte
	JMP	<XMT_CHK	; Keep looping

; Process the command - is it in the command table ?
COMMAND	MOVE    (R4)+           ; Increment over the header
        MOVE    X:(R4)+,A       ; Get the command buffer entry
	MOVE	#<COM_TBL,R0	; Get command table address
        DO      #NUM_COM,END_COM ; Loop over command table
        MOVE    X:(R0)+,X0      ; Get the command table entry
        CMP     X0,A  X:(R0),R5	; Are the receiver and table entries the same?
        JNE     <NOT_COM        ; No, keep looping
        ENDDO                   ; Restore the DO loop system registers
        JMP     (R5)            ; Jump execution to the command
NOT_COM MOVE    (R0)+           ; Increment the register past the table address
END_COM

; Step over the remaining words in the command if there's an error
	MOVE	X:<NWORDS,A 
	MOVE	X:<TWO,X0
	SUB	X0,A		; Header and command have been processed
	JEQ	<ERROR
	DO	A,INCR_R4
	MOVE	(R4)+		; Increment over unprocessed part of comamnd
INCR_R4

ERROR   MOVE    X:<ERR,X0	; Send the message - there was an error
        JMP     <FINISH1	; This protects against unknown commands

; Command execution is nearly over - generate header and message.
FINISH  MOVE    X:<DON,X0	; Send a DONE message as a reply
FINISH1	MOVE    X:<HDR_ID,A	; Get header of incoming command
	MOVE    X:<SMASK,X1	; This was the source byte, and is to 
	AND     X1,A  X:<TWO,X1	;   become the destination byte
	REP	#8		; Shift right one byte, add it to the
	LSR     A  X1,X:<NWORDS	;     header, and put 2 as the number
	ADD     X1,A  X:<SBRDID,X1 ;  of words in the string
	ADD     X1,A
	MOVE    A,X:(R3)+       ; Put header on the transmitter stack
	MOVE	X0,X:(R3)+	; Put value of X0 on the transmitter stack
	JMP	<XMT_CHK	; Go transmit

; Delay after EEPROM write in DSP internal memory because code cannot 
;   execute from EEPROM during a write operation
DLY_ROM	DO	X:<C50000,LP_WRR 
	MOVEP	Y:WATCH,A	; Delay 10 millisec for EEPROM write
LP_WRR
        JMP     <FINISH

; This ISR receives serial words a byte at a time over the asynchronous
;   serial link (SCI) and squashes them into a single 24-bit word
SCI_RCV	MOVEC   SR,X:<SAVE_SR	; Save Status Register
        MOVE    A1,X:<SAVE_A1	; Save A1
        MOVE    X1,X:<SAVE_X1   ; Save X1
        MOVE    X:<SRX_A1,A1	; Get SRX value of accumulator contents
        MOVE    X:(R7),X1       ; Get the SCI byte
        BCLR    #1,R7           ; Test for the address being $FFF6 = last byte
        OR      X1,A (R7)+	; Add the byte into the 24-bit word
        JCC     <MID_BYT        ; Not the last byte => only restore registers
END_BYT MOVE    A1,X:(R1)+      ; Put the 24-bit word into the SCI buffer
	MOVE	X:<SRX_FST,R7	; Restablish first address of SCI interface
        MOVE    #0,A1		; For zeroing out SRX_A1
MID_BYT	MOVE    A1,X:<SRX_A1	; Save A1 for next interrupt
        MOVEC   X:<SAVE_SR,SR	; Restore Status Register
        MOVE    X:<SAVE_A1,A1	; Restore A1
        MOVE    X:<SAVE_X1,X1   ; Restore X1
        RTI                     ; Return from interrupt service

; Clear error condition and interrupt on SCI receiver
CLR_ERR MOVEP   X:SSR,X:RCV_ERR ; Read SCI status register
	MOVEP   X:SRX,X:RCV_ERR ; This clears any error
	RTI

; Transmit 24-bit words over the SCI serial link to the timing board
; Accumulator A does not have to be saved and restored because XMT_CHK
;   sets it each time it is needed. 
SCI_XMT	MOVE    X:<STX_ADR,R0   ; Restore the starting address of the SCI
        MOVE    X:(R4),A
	MOVE    A,X:(R0)	; Transmit buffer
        BCLR    #1,R0           ; Test for last SCI address = $FFF6
        JCS     <DON_XMT        ; If address = $FFF6 clean up
        MOVE    (R0)+
        MOVE    R0,X:<STX_ADR   ; Restore the starting address of the SCI
        RTS 

; We're done tranmitting the three bytes of each 24-bit DSP word.
DON_XMT MOVE    (R4)+
        MOVE    R0,X:<STX_ADR   ; Restore starting address of SCI = $FFF4
        RTS

; Check for overflow
        IF	@CVS(N,*)>APL_ADR
        WARN    'Internal P: memory overflow!'	; Make sure application code
	ENDIF					;  will not be overwritten

; Specify the memory location where the application program is to be loaded
	ORG	P:APL_ADR,P:APL_ADR+P_OFF

; Define TIMER as a simple jump addresses so the "bootrom" program 
;   can work until the application program can be loaded
SERVICE	RTS			; Just return from subroutine call
TIMER	RTI			; Just return from interrupt

; The following boot routines execute directly from EEPROM, one 24-bit word
;   at a time. Two reasons for this - to conserve DSP P: space, and to allow
;   reading or writing to EEPROM space that overlaps with the P: internal
;   DSP memory space.

 	ORG     P:ROM_EXE,P:ROM_EXE                 

; Test Data Link - simply return value received after 'TDL'
TDL     MOVE    X:(R4)+,X0      ; Get data value
        JMP     <FINISH1	; Return from executing TDL command

; Its a read from DSP memory - get the data and send it over the link
RDMEM	MOVE    X:(R4),R0	; Need the address in an address register
	MOVE	X:(R4)+,X0	; Need address also in a 24-bit register
        JCLR    #20,X0,RDX	; Test address bit for Program memory
        MOVE	P:(R0),X0	; Read from Program memory
        JMP     <FINISH1	; Send out a header with the value
RDX     JCLR    #21,X0,RDY	; Test address bit for X: memory
        MOVE    X:(R0),X0	; Write to X data memory
        JMP     <FINISH1	; Send out a header with the value
RDY     JCLR    #22,X0,RDR	; Test address bit for Y: memory
        MOVE    Y:(R0),X0	; Read from Y data memory
	JMP     <FINISH1	; Send out a header with the value
RDR	JCLR	#23,X0,ERROR	; Test for read of EEPROM memory
	MOVEC	#$03,OMR	; Development mode - disable internal P: memory
	NOP
	MOVE	P:(R0),X0	; Read from EEPROM
	MOVEC	#$02,OMR	; Normal mode - enable internal P: memory
	NOP
	JMP	<FINISH1

; Program WRMEM - ('WRM' address datum), write to memory.
WRMEM	MOVE    X:(R4),R0	; Get the desired address
	MOVE	X:(R4)+,X0	; We need a 24-bit version of the address
	MOVE    X:(R4)+,X1	; Get value into X1 some MOVE works easily
	JCLR    #20,X0,WRX	; Test address bit for Program memory
	MOVE	R0,X0		; Get 16-bit version of the address
	MOVE	X:<C512,A	; If address >= $200 then its an EEPROM write
	CMP	X0,A		;   and a delay 10 milliseconds is needed
	MOVE	X1,P:(R0)	; Write to Program memory
	JLE	<DLY_ROM	; Jump to delay routine if needed   
	JMP     <FINISH
WRX	JCLR    #21,X0,WRY	; Test address bit for X: memory
	MOVE    X1,X:(R0)	; Write to X: memory
	JMP     <FINISH
WRY	JCLR    #22,X0,WRR	; Test address bit for Y: memory
	MOVE    X1,Y:(R0)	; Write to Y: memory
	JMP	<FINISH
WRR	JCLR    #23,X0,ERROR	; Test address bit for ROM memory
	MOVE	#3,OMR		; Development mode - disable internal P: memory
	NOP
	MOVE	X1,P:(R0)	; Write to EEPROM
	MOVE	#2,OMR		; Normal mode - enable internal P: memory
	NOP
	JMP	<DLY_ROM	; Delay 10 milliseconds for EEPROM write

; Read EEPROM code into DSP locations starting at P:APL_ADR
LDA	ORI	#$03,MR		; Temporarily mask interrupts
	MOVE	X:(R4)+,X0	; Number of application program
	MOVE	X:<ZERO,A
	CMP	X0,A  X:<C300,Y0
	JEQ	LDA_0		; Application #0 is a special case
	MPY	X0,Y0,A  X:<ZERO,X1
	ASR	A  X:<C1D00,X0
	ADD	X,A  #APL_ADR,R5
	MOVE	A0,R0		; EEPROM address = # x $300 + $1D00
	DO	#$200-APL_ADR,LD_LA0  ;  Thus  ( 1 <= # <= 10 )
	MOVE	P:(R0)+,A	; Read from EEPROM
	MOVE	A,P:(R5)+	; Write to DSP
LD_LA0
	JMP	LD_X		; Keep R0 value

; Special case - application #0 can spill from internal P: DSP to EEPROM memory
LDA_0	MOVE	#APL_ADR,R0
	DO	#$200-APL_ADR,LD_LA1
	MOVE	#3,OMR		; Development mode - disable internal P: memory
	NOP
	MOVE	P:(R0),A	; Read from EEPROM
	MOVE	#2,OMR		; Normal mode - enable internal P: memory
	NOP
	MOVE	A,P:(R0)+	; Write to DSP
LD_LA1

; Load in the application command table into X:CMD_TBL
	MOVE	#APL_XY,R0
LD_X	MOVE	#COM_TBL,R5
	DO	#32,LD_LA2	; 16 application commands
	MOVE	P:(R0)+,A
	MOVE	A,X:(R5)+
LD_LA2

; Load the Y: data memory contents 
	MOVE	#0,R5		; Start at bottom of Y: memory
	DO	#$100,LD_LA3	; Read from EEPROM and write
	MOVE	P:(R0)+,A	;   them to Y: memory
	MOVE	A,Y:(R5)+
LD_LA3
	ANDI    #$FC,MR         ; Unmask interrupts
	JMP	<FINISH		; Send 'DON' message

; Parameter definitions in X: memory space
	ORG	X:0,P:X_OFF
STATUS  DC      0       ; Status word
OPTIONS DC      0       ; Software options
NWORDS  DC      0	; Number of words in destination command packet
HDR_ID  DC      0       ; 24-bit header containing board ID's

; Places for saving register values
SAVE_SR DC      0       ; Status Register
SAVE_X1 DC      0
SAVE_A1	DC	0
RCV_ERR DC      0
STX_ADR DC      $FFF4   ; Current SCI XMT byte address ($FFF4, 5 or 6)
SRX_FST	DC      $FFF4   ; Current SCI RCV byte address ($FFF4, 5 or 6)
SRX_A1	DC      0       ; Contents of accumulator A1 in RCV ISR

; Constant definitions, useful for saving program memory space
ZERO	DC	0	
ONE     DC      1
TWO	DC	2
C32	DC	32
C512	DC	512	; Boundary between DSP and EEPROM P: memory
C1D00	DC	$1D00	; Offset for loading application programs
MASK1	DC	$FCFCF8	; Mask for checking header
MASK2	DC	$030300	; Mask for checking header
CFFF    DC      $FFF    ; Mask for 12-bit A/D converter
C300    DC      $300	; Constant for resetting the DSP
C50000	DC      50000   ; 5 millisec delay for +/- 15v settling
SBRDID  DC	$030000 ; Source Identification number
DBRDID  DC	$000300 ; Destination Identification number
DMASK   DC	$00FF00 ; Mask to get destination board number out
SMASK   DC	$FF0000 ; Mask to get source board number out
HOST    DC      $030002 ; Header to host computer
VME     DC      $030102 ; Header to VMEINF board
TIMING  DC      $030202 ; Header to timing board
UTIL	DC	$030302	; Header to utility board
ERR	DC	'ERR'	; For sending error messages
DON	DC	'DON'	; For sending completion messages

; The last part of the command table is not defined for "bootrom"
;  The command table is resident in X: data memory; 32 entries maximum
        ORG     X:COM_TBL,P:COM_TBL+X_OFF
	DC	0,START,0,START,0,START,0,START ; This is where application
	DC	0,START,0,START,0,START,0,START ;    commands go
	DC	0,START,0,START,0,START,0,START
	DC	0,START,0,START,0,START,0,START
	DC      'TDL',TDL       ; Test Data Link        
	DC      'RDM',RDMEM	; Read DSP or EEPROM memory
	DC	'WRM',WRMEM	; Write DSP or EEPROM memory 
	DC	'LDA',LDA	; Load application program from EEPROM      
        DC      'ERR',START	; Do nothing
	DC	0,START,0,START,0,START
	
; End of program
        END 

