       COMMENT *

timhdr.asm for ARC22 timing code

This is a header file that is shared between the fiber optic timing board
boot and application code files for Rev. 5 = 250 MHz timing boards

Utility board support version 

Last change 29Oct06 MPL

	*

	PAGE    132     ; Printronix page width - 132 columns

; Various addressing control registers
BCR	EQU	$FFFFFB		; Bus Control Register
AAR0	EQU	$FFFFF9		; Address Attribute Register, channel 0	
AAR1	EQU	$FFFFF8		; Address Attribute Register, channel 1	
AAR2	EQU	$FFFFF7		; Address Attribute Register, channel 2	
AAR3	EQU	$FFFFF6		; Address Attribute Register, channel 3	
PCTL	EQU	$FFFFFD		; PLL control register
IPRP	EQU	$FFFFFE		; Interrupt Priority register - Peripheral
IPRC	EQU	$FFFFFF		; Interrupt Priority register - Core

; Port E is the Synchronous Communications Interface (SCI) port
PCRE	EQU	$FFFF9F		; Port Control Register
PRRE	EQU	$FFFF9E		; Port Direction Register
PDRE	EQU	$FFFF9D		; Port Data Register
SCR	EQU	$FFFF9C		; SCI Control Register
SCCR	EQU	$FFFF9B		; SCI Clock Control Register

SRXH	EQU	$FFFF9A		; SCI Receive Data Register, High byte
SRXM	EQU	$FFFF99		; SCI Receive Data Register, Middle byte
SRXL	EQU	$FFFF98		; SCI Receive Data Register, Low byte

STXH	EQU	$FFFF97		; SCI Transmit Data register, High byte
STXM	EQU	$FFFF96		; SCI Transmit Data register, Middle byte
STXL	EQU	$FFFF95		; SCI Transmit Data register, Low byte

STXA	EQU	$FFFF94		; SCI Transmit Address Register
SSR	EQU	$FFFF93		; SCI Status Register

SCITE	EQU	9		; X:SCR bit set to enable the SCI transmitter
SCIRE	EQU	8		; X:SCR bit set to enable the SCI receiver 
TRNE	EQU	0		; This is set in X:SSR when the transmitter 
				;  shift and data registers are both empty
TDRE	EQU	1		; This is set in X:SSR when the transmitter
				;  data register is empty
RDRF	EQU	2		; X:SSR bit set when receiver register is full
SELSCI	EQU	15		; 1 for SCI to backplane, 0 to front connector


; ESSI Flags
TDE	EQU	6		; Set when transmitter data register is empty
RDF	EQU	7		; Set when receiver is full of data
TE	EQU	16		; Transmitter enable

; Phase Locked Loop initialization
PLL_INIT EQU	$050003		; PLL = 25 MHz x 2 = 100 MHz

; Port B general purpose I/O
HPCR	EQU	$FFFFC4		; Control register (bits 1-6 cleared for GPIO)
HDR	EQU	$FFFFC9		; Data register
HDDR	EQU	$FFFFC8		; Data Direction Register bits (=1 for output)

; Port C is Enhanced Synchronous Serial Port 0 = ESSI0
PCRC	EQU	$FFFFBF		; Port C Control Register
PRRC	EQU	$FFFFBE		; Port C Data direction Register
PDRC	EQU	$FFFFBD		; Port C GPIO Data Register
TX00	EQU	$FFFFBC		; Transmit Data Register #0
RX0	EQU	$FFFFB8		; Receive data register
SSISR0	EQU	$FFFFB7		; Status Register
CRB0	EQU	$FFFFB6		; Control Register B
CRA0	EQU	$FFFFB5		; Control Register A

; Port D is Enhanced Synchronous Serial Port 1 = ESSI1
PCRD	EQU	$FFFFAF		; Port D Control Register
PRRD	EQU	$FFFFAE		; Port D Data direction Register
PDRD	EQU	$FFFFAD		; Port D GPIO Data Register
TX10	EQU	$FFFFAC		; Transmit Data Register 0
SSISR1	EQU	$FFFFA7		; Status Register
CRB1	EQU	$FFFFA6		; Control Register B
CRA1	EQU	$FFFFA5		; Control Register A

; Timer module addresses
TCSR0	EQU	$FFFF8F		; Timer control and status register
TLR0	EQU	$FFFF8E		; Timer load register = 0
TCPR0	EQU	$FFFF8D		; Timer compare register = exposure time
TCR0	EQU	$FFFF8C		; Timer count register = elapsed time
TPLR	EQU	$FFFF83		; Timer prescaler load register => milliseconds
TPCR	EQU	$FFFF82		; Timer prescaler count register
TIM_BIT	EQU	0		; Set to enable the timer
TRM	EQU	9		; Set to enable the timer preloading
TCF	EQU	21		; Set when timer counter = compare register

; Board specific addresses and constants
RDFO	EQU	$FFFFF1		; Read incoming fiber optic data byte
WRFO	EQU	$FFFFF2		; Write fiber optic data replies
WRSS	EQU	$FFFFF3		; Write switch state
WRLATCH	EQU	$FFFFF5		; Write to a latch
RDAD	EQU	$010000		; Read A/D values into the DSP
EF	EQU	9		; Serial receiver empty flag

; DSP port A bit equates
PWROK	EQU	0		; Power control board says power is OK
LED1	EQU	1		; Control one of two LEDs
LVEN	EQU	2		; Low voltage power enable
HVEN	EQU	3		; High voltage power enable
SSFHF	EQU	14		; Switch state FIFO half full flag

; Port D equate
SSFEF	EQU	1		; Switch state FIFO empty flag

; Other equates
WRENA	EQU	2		; Enable writing to the EEPROM

; Latch U12 bit equates
CDAC	EQU	0		; Clear the analog board DACs
ENCK	EQU	2		; Enable the clock outputs
SHUTTER	EQU	4		; Control the shutter
TIM_U_RST EQU	5		; Reset the utility board

; Software status bits, defined at X:<STATUS = X:0
ST_RCV	EQU	0	; Set to indicate word is from SCI = utility board
IDLMODE	EQU	2	; Set if need to idle after readout
ST_SHUT	EQU	3	; Set to indicate shutter is closed, clear for open
ST_RDC	EQU	4	; Set if executing 'RDC' command - reading out
SPLIT_S	EQU	5	; Set if split serial
SPLIT_P	EQU	6	; Set if split parallel
MPPMODE	EQU	7	; Set if parallels are in MPP mode - MPL
NOT_CLR	EQU	8	; Set if not to clear CCD before exposure
TST_IMG	EQU	10	; Set if controller is to generate a test image
SHUT		EQU	11	; Set if opening shutter at beginning of exposure
ST_DITH	EQU	12	; Set if to dither during exposure
NOREAD	EQU	13	; Set if not to call RDCCD after expose MPL

; Address for the table containing the incoming SCI words
SCI_TABLE	EQU	$400
