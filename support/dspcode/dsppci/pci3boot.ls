Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 1



1                                  COMMENT *
2      
3                          This file is used to generate DSP code for the PCI interface
4                          board Rev. 5 using a DSP56301 as its main processor.
5      
6                          Runs on 250 MHz boards  -  Version 1.7
7      
8                          This version for AzCam is unchanged for ARC version.
9      
10                                 *
11                                   PAGE    132                               ; Printronix page width - 132 columns
12     
13                         ; Equates to define the X: memory tables
14        000000           VAR_TBL   EQU     0                                 ; Variables and constants table
15        000030           ARG_TBL   EQU     $30                               ; Command arguments and addresses
16     
17                         ; Various addressing control registers
18        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
19        FFFFFA           DCR       EQU     $FFFFFA                           ; DRAM Control Register
20        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
21        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
22        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
23        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
24        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
25        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
26        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
27     
28                         ; PCI control register
29        FFFFCD           DTXS      EQU     $FFFFCD                           ; DSP Slave transmit data FIFO
30        FFFFCC           DTXM      EQU     $FFFFCC                           ; DSP Master transmit data FIFO
31        FFFFCB           DRXR      EQU     $FFFFCB                           ; DSP Receive data FIFO
32        FFFFCA           DPSR      EQU     $FFFFCA                           ; DSP PCI Status Register
33        FFFFC9           DSR       EQU     $FFFFC9                           ; DSP Status Register
34        FFFFC8           DPAR      EQU     $FFFFC8                           ; DSP PCI Address Register
35        FFFFC7           DPMC      EQU     $FFFFC7                           ; DSP PCI Master Control Register
36        FFFFC6           DPCR      EQU     $FFFFC6                           ; DSP PCI Control Register
37        FFFFC5           DCTR      EQU     $FFFFC5                           ; DSP Control Register
38     
39                         ; Port E is the Synchronous Communications Interface (SCI) port
40        FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
41        FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
42        FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
43     
44                         ; Various PCI register bit equates
45        000001           STRQ      EQU     1                                 ; Slave transmit data request (DSR)
46        000002           SRRQ      EQU     2                                 ; Slave receive data request (DSR)
47        000017           HACT      EQU     23                                ; Host active, low true (DSR)
48        000001           MTRQ      EQU     1                                 ; Set whem master transmitter is not full (DPSR)
49        000004           MARQ      EQU     4                                 ; Master address request (DPSR)
50        000000           HCIE      EQU     0                                 ; Host command interrupt enable (DCTR)
51        000006           INTA      EQU     6                                 ; Request PCI interrupt (DCTR)
52        000005           APER      EQU     5                                 ; Address parity error
53        000006           DPER      EQU     6                                 ; Data parity error
54        000007           MAB       EQU     7                                 ; Master Abort
55        000008           TAB       EQU     8                                 ; Target Abort
56        000009           TDIS      EQU     9                                 ; Target Disconnect
57        00000A           TRTY      EQU     10                                ; Target Retry
58        00000B           TO        EQU     11                                ; Timeout
59        00000E           MDT       EQU     14                                ; Master Data Transfer complete
60        00000F           RDCQ      EQU     15                                ; Remaining Data Count Qualifier
61        000002           SCLK      EQU     2                                 ; SCLK = transmitter special code
62     
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 2



63                         ; DPCR bit definitions
64        00000E           CLRT      EQU     14                                ; Clear the master transmitter DTXM
65        000012           MACE      EQU     18                                ; Master access counter enable
66        000015           IAE       EQU     21                                ; Insert Address Enable
67     
68                         ; DMA register definitions
69        FFFFEF           DSR0      EQU     $FFFFEF                           ; Source address register
70        FFFFEE           DDR0      EQU     $FFFFEE                           ; Destination address register
71        FFFFED           DCO0      EQU     $FFFFED                           ; Counter register
72        FFFFEC           DCR0      EQU     $FFFFEC                           ; Control register
73     
74                         ; Addresses of ESSI port
75        FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register 0
76        FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
77        FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
78        FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
79     
80                         ; SSI Control Register A Bit Flags
81        000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
82     
83                         ; Miscellaneous addresses
84        FFFFFF           RDFIFO    EQU     $FFFFFF                           ; Read the FIFO for incoming fiber optic data
85        FFFF8F           TCSR0     EQU     $FFFF8F                           ; Triple timer control and status register 0
86        FFFF8B           TCSR1     EQU     $FFFF8B                           ; Triple timer control and status register 1
87        FFFF87           TCSR2     EQU     $FFFF87                           ; Triple timer control and status register 2
88     
89                         ; Phase Locked Loop initialization
90        050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 4 = 100 MHz
91     
92                         ; Port C is Enhanced Synchronous Serial Port 0
93        FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
94        FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
95        FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
96     
97                         ; Port D is Enhanced Synchronous Serial Port 1
98        FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
99        FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
100       FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
101    
102                        ; Bit number definitions of GPIO pins on Port D
103       000000           EF        EQU     0                                 ; FIFO Empty flag, low true
104       000001           HF        EQU     1                                 ; FIFO Half Full flag, low true
105    
106                        ; STATUS bit definitions
107       000000           ODD       EQU     0                                 ; Set if odd number of pixels are in the image
108       000001           TIMROMBURN EQU    1                                 ; Burning timing board EEPROM, ignore replies
109    
110                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
111                                  IF      @SCP("HOST","ROM")                ; Boot from ROM on power-on
118                                  ENDIF
119    
120                                  IF      @SCP("HOST","HOST")               ; Download via host computer
121       P:000000 P:000000                   ORG     P:0,P:0
122       P:000000 P:000000                   DC      END_ADR-INIT                      ; Number of boot words
123       P:000001 P:000001                   DC      INIT                              ; Starting address
124       P:000000 P:000000                   ORG     P:0,P:0
125       P:000000 P:000000 0C00B2  INIT      JMP     <START
126       P:000001 P:000001 000000            NOP
127                                           ENDIF
128    
129                                           IF      @SCP("HOST","ONCE")               ; Download via ONCE debugger
133                                           ENDIF
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 3



134    
135                                 ; Vectored interrupt table, addresses at the beginning are reserved
136       P:000002 P:000002                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; $02-$0f Reserved
137       P:000010 P:000010                   DC      0,0                               ; $11 - IRQA* = FIFO EF*
138       P:000012 P:000012                   DC      0,0                               ; $13 - IRQB* = FIFO HF*
139       P:000014 P:000014 0BF080            JSR     CLEAN_UP_PCI                      ; $15 - Software reset switch
                            000247
140       P:000016 P:000016                   DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Reserved for DMA and Timer
141       P:000022 P:000022                   DC      0,0,0,0,0,0,0,0,0,0,0,0           ;   interrupts
142       P:00002E P:00002E 0BF080            JSR     DOWNLOAD_PCI_DSP_CODE             ; $2F
                            000045
143    
144                                 ; Now we're at P:$30, where some unused vector addresses are located
145    
146                                 ; This is ROM only code that is only executed once on power-up when the
147                                 ;   ROM code is downloaded. It is skipped over on OnCE or PCI downloads.
148                                 ; Initialize the PLL - phase locked loop
149                                 INIT_PCI
150       P:000030 P:000030 08F4BD            MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL
                            050003
151       P:000032 P:000032 000000            NOP
152    
153                                 ; Program the PCI self-configuration registers
154       P:000033 P:000033 240000            MOVE              #0,X0
155       P:000034 P:000034 08F485            MOVEP             #$500000,X:DCTR         ; Set self-configuration mode
                            500000
156       P:000036 P:000036 0604A0            REP     #4
157       P:000037 P:000037 08C408            MOVEP             X0,X:DPAR               ; Dummy writes to configuration space
158       P:000038 P:000038 08F487            MOVEP             #>$0000,X:DPMC          ; Subsystem ID
                            000000
159       P:00003A P:00003A 08F488            MOVEP             #>$0000,X:DPAR          ; Subsystem Vendor ID
                            000000
160    
161                                 ; PCI Personal reset
162       P:00003C P:00003C 08C405            MOVEP             X0,X:DCTR               ; Personal software reset
163       P:00003D P:00003D 000000            NOP
164       P:00003E P:00003E 000000            NOP
165       P:00003F P:00003F 0A89B7            JSET    #HACT,X:DSR,*                     ; Test for personal reset completion
                            00003F
166       P:000041 P:000041 07F084            MOVE              P:(*+3),X0              ; Trick to write "JMP <START" to P:0
                            000044
167       P:000043 P:000043 070004            MOVE              X0,P:(0)
168       P:000044 P:000044 0C00B2            JMP     <START
169    
170                                 DOWNLOAD_PCI_DSP_CODE
171       P:000045 P:000045 0A8615            BCLR    #IAE,X:DPCR                       ; Do not insert PCI address with data
172       P:000046 P:000046 0A8982  DNL0      JCLR    #SRRQ,X:DSR,*                     ; Wait for a receiver word
                            000046
173       P:000048 P:000048 084E0B            MOVEP             X:DRXR,A                ; Read it
174       P:000049 P:000049 0140C5            CMP     #$555AAA,A                        ; Check for sanity header word
                            555AAA
175       P:00004B P:00004B 0E2046            JNE     <DNL0
176       P:00004C P:00004C 044EBA            MOVE              OMR,A
177       P:00004D P:00004D 0140C6            AND     #$FFFFF0,A
                            FFFFF0
178       P:00004F P:00004F 014C82            OR      #$00000C,A
179       P:000050 P:000050 000000            NOP
180       P:000051 P:000051 04CEBA            MOVE              A,OMR                   ; Set boot mode to $C = PCI
181       P:000052 P:000052 0AF080            JMP     $FF0000                           ; Jump to boot code internal to DSP
                            FF0000
182    
183       P:000054 P:000054                   DC      0,0,0,0,0,0,0,0,0,0,0,0           ; Filler
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 4



184       P:000060 P:000060                   DC      0,0                               ; $60 - PCI Transaction Termination
185       P:000062 P:000062                   DC      0,0,0,0,0,0,0,0,0                 ; $62-$71 Reserved PCI
186       P:00006B P:00006B                   DC      0,0,0,0,0,0,0
187       P:000072 P:000072 0A8506            BCLR    #INTA,X:DCTR                      ; $73 - Clear PCI interrupt
188       P:000073 P:000073                   DC      0                                 ; Clear interrupt bit
189    
190                                 ; These interrupts are non-maskable, called from the host with $80xx
191       P:000074 P:000074 0BF080            JSR     READ_NUMBER_OF_PIXELS_READ        ; $8075
                            0001E8
192       P:000076 P:000076 0BF080            JSR     CLEAN_UP_PCI                      ; $8077
                            000247
193       P:000078 P:000078 0BF080            JSR     ABORT_READOUT                     ; $8079
                            00022A
194       P:00007A P:00007A 0BF080            JSR     BOOT_EEPROM                       ; $807B
                            000199
195       P:00007C P:00007C                   DC      0,0,0,0                           ; Available
196    
197                                 ; These vector interrupts are masked at IPL = 1
198       P:000080 P:000080 0BF080            JSR     READ_REPLY_HEADER                 ; $81
                            0003EA
199       P:000082 P:000082 0BF080            JSR     READ_REPLY_VALUE                  ; $83
                            0003E7
200       P:000084 P:000084 0BF080            JSR     CLEAR_HOST_FLAG                   ; $85
                            0003EC
201       P:000086 P:000086 0BF080            JSR     RESET_CONTROLLER                  ; $87
                            0001EE
202       P:000088 P:000088 0BF080            JSR     READ_IMAGE                        ; $89
                            000251
203       P:00008A P:00008A                   DC      0,0                               ; Available
204       P:00008C P:00008C 0BF080            JSR     WRITE_BASE_PCI_ADDRESS            ; $8D
                            000214
205    
206       P:00008E P:00008E                   DC      0,0,0,0                           ; Available
207       P:000092 P:000092                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0
208       P:0000A0 P:0000A0                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
209    
210       P:0000B0 P:0000B0 0BF080            JSR     WRITE_COMMAND                     ; $B1
                            0001A3
211    
212                                 ; ******************************************************************
213                                 ;
214                                 ;       AA0 = RDFIFO* of incoming fiber optic data
215                                 ;       AA1 = EEPROM access
216                                 ;       AA2 = DRAM access
217                                 ;       AA3 = output to parallel data connector, for a video pixel clock
218                                 ;       $FFxxxx = Write to fiber optic transmitter
219                                 ;
220                                 ; ******************************************************************
221    
222       P:0000B2 P:0000B2 08F487  START     MOVEP             #>$00001,X:DPMC         ; 32-bit PCI <-> 24-bit DSP data
                            000001
223       P:0000B4 P:0000B4 0A8534            BSET    #20,X:DCTR                        ; HI32 mode = 1 => PCI
224       P:0000B5 P:0000B5 0A8515            BCLR    #21,X:DCTR
225       P:0000B6 P:0000B6 0A8516            BCLR    #22,X:DCTR
226       P:0000B7 P:0000B7 000000            NOP
227       P:0000B8 P:0000B8 0A8AAC            JSET    #12,X:DPSR,*                      ; Host data transfer not in progress
                            0000B8
228       P:0000BA P:0000BA 000000            NOP
229       P:0000BB P:0000BB 0A8632            BSET    #MACE,X:DPCR                      ; Master access counter enable
230       P:0000BC P:0000BC 000000            NOP                                       ; End of PCI programming
231    
232                                 ; Set operation mode register OMR to normal expanded
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 5



233       P:0000BD P:0000BD 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
234       P:0000BE P:0000BE 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
235    
236                                 ; Move the table of constants from P: space to X: space
237       P:0000BF P:0000BF 61F400            MOVE              #CONSTANTS_TBL_START,R1 ; Start of table of constants
                            000483
238       P:0000C1 P:0000C1 300200            MOVE              #2,R0                   ; Leave X:0 for STATUS
239       P:0000C2 P:0000C2 060F80            DO      #CONSTANTS_TBL_LENGTH,L_WRITE
                            0000C5
240       P:0000C4 P:0000C4 07D984            MOVE              P:(R1)+,X0
241       P:0000C5 P:0000C5 445800            MOVE              X0,X:(R0)+              ; Write the constants to X:
242                                 L_WRITE
243    
244                                 ; Program the serial port ESSI0 = Port C for various parallel I/O operations
245       P:0000C6 P:0000C6 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
246       P:0000C8 P:0000C8 07F435            MOVEP             #$00080B,X:CRA0         ; Divide 100.0 MHz by 24 to get 4.17 MHz
                            00080B
247                                                                                     ; DC0-CD4 = 0 for non-network operation
248                                                                                     ; WL0-WL2 = ALC = 0 for 2-bit data words
249                                                                                     ; SSC1 = 0 for SC1 not used
250       P:0000CA P:0000CA 07F436            MOVEP             #$010120,X:CRB0         ; SCKD = 1 for internally generated clock
                            010120
251                                                                                     ; SHFD = 0 for MSB shifted first
252                                                                                     ; CKP = 0 for rising clock edge transitions
253                                                                                     ; TE0 = 1 to enable transmitter #0
254                                                                                     ; MOD = 0 for normal, non-networked mode
255                                                                                     ; FSL1 = 1, FSL0 = 0 for on-demand transmit
256       P:0000CC P:0000CC 07F43F            MOVEP             #%101000,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000028
257                                                                                     ; Set SCK0 = P3, STD0 = P5 to ESSI0
258       P:0000CE P:0000CE 07F43E            MOVEP             #%111100,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            00003C
259       P:0000D0 P:0000D0 07F43D            MOVEP             #%000000,X:PDRC         ; Data Register - AUX3 = input, AUX1 not use
d
                            000000
260    
261                                 ; 250 MHz definitions
262                                 ; Conversion from software bits to schematic labels for Port C and D
263                                 ;       PC0 = SC00 = AUX3               PD0 = SC10 = EF*
264                                 ;       PC1 = SC01 = A/B* = input       PD1 = SC11 = HF*
265                                 ;       PC2 = SC02 = No connect         PD2 = SC12 = RS*
266                                 ;       PC3 = SCK0 = No connect         PD3 = SCK1 = NWRFIFO*
267                                 ;       PC4 = SRD0 = AUX1               PD4 = SRD1 = No connect
268                                 ;       PC5 = STD0 = No connect         PD5 = STD1 = WRFIFO*
269    
270    
271                                 ; Program the serial port ESSI1 = Port D for general purpose I/O (GPIO)
272       P:0000D2 P:0000D2 07F42F            MOVEP             #%000000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000000
273       P:0000D4 P:0000D4 07F42E            MOVEP             #%011100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            00001C
274       P:0000D6 P:0000D6 07F42D            MOVEP             #%011000,X:PDRD         ; Data Register - Pulse RS* low
                            000018
275       P:0000D8 P:0000D8 060AA0            REP     #10
276       P:0000D9 P:0000D9 000000            NOP
277       P:0000DA P:0000DA 07F42D            MOVEP             #%011100,X:PDRD
                            00001C
278    
279                                 ; Program the SCI port to benign values
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 6



280       P:0000DC P:0000DC 07F41F            MOVEP             #%000,X:PCRE            ; Port Control Register   (0 => GPIO)
                            000000
281       P:0000DE P:0000DE 07F41E            MOVEP             #%110,X:PRRE            ; Port Direction Register (0 => Input)
                            000006
282       P:0000E0 P:0000E0 07F41D            MOVEP             #%010,X:PDRE            ; Port Data Register
                            000002
283                                 ;       PE0 = RXD
284                                 ;       PE1 = TXD
285                                 ;       PE2 = SCLK = XMT SC = Fiber optic transmitter special character when set
286    
287                                 ; Program the triple timer to assert TCI0 as a GPIO output = 1
288       P:0000E2 P:0000E2 07F40F            MOVEP             #$2800,X:TCSR0
                            002800
289       P:0000E4 P:0000E4 07F40B            MOVEP             #$2800,X:TCSR1
                            002800
290       P:0000E6 P:0000E6 07F407            MOVEP             #$2800,X:TCSR2
                            002800
291    
292                                 ; Program the address attribute pins AA0 to AA2. AA3 is not yet implemented.
293       P:0000E8 P:0000E8 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts Y:RDFIFO*
                            FFFC21
294       P:0000EA P:0000EA 08F4B8            MOVEP             #$008929,X:AAR1         ; P = $008000 to $00FFFF asserts AA1 low tru
e
                            008929
295       P:0000EC P:0000EC 08F4B7            MOVEP             #$000122,X:AAR2         ; Y = $000800 to $7FFFFF accesses SRAM
                            000122
296    
297                                 ; Program the bus control and DRAM memory access registers
298       P:0000EE P:0000EE 08F4BB            MOVEP             #$020022,X:BCR          ; Bus Control Register
                            020022
299       P:0000F0 P:0000F0 08F4BA            MOVEP             #$893A05,X:DCR          ; DRAM Control Register
                            893A05
300    
301                                 ; Clear all PCI error conditions
302       P:0000F2 P:0000F2 084E0A            MOVEP             X:DPSR,A
303       P:0000F3 P:0000F3 0140C2            OR      #$1FE,A
                            0001FE
304       P:0000F5 P:0000F5 000000            NOP
305       P:0000F6 P:0000F6 08CE0A            MOVEP             A,X:DPSR
306    
307                                 ; Only initialize STATUS and REPLY if booting from ROM after power-up
308                                           IF      @SCP("HOST","ROM")
310                                           ENDIF
311    
312                                 ; Establish interrupt priority levels IPL
313       P:0000F7 P:0000F7 08F4BF            MOVEP             #$0001C0,X:IPRC         ; IRQC priority IPL = 2 (reset switch, edge)
                            0001C0
314                                                                                     ; IRQB priority IPL = 2 or 0
315                                                                                     ;     (FIFO half full - HF*, level)
316       P:0000F9 P:0000F9 08F4BE            MOVEP             #>2,X:IPRP              ; Enable PCI Host interrupts, IPL = 1
                            000002
317       P:0000FB P:0000FB 0A8520            BSET    #HCIE,X:DCTR                      ; Enable host command interrupts
318       P:0000FC P:0000FC 0500B9            MOVE              #0,SR                   ; Don't mask any interrupts
319    
320                                 ; Initialize the fiber optic serial transmitter to zero
321       P:0000FD P:0000FD 01B786            JCLR    #TDE,X:SSISR0,*
                            0000FD
322       P:0000FF P:0000FF 07F43C            MOVEP             #$000000,X:TX00
                            000000
323    
324                                 ; Clear out the PCI receiver and transmitter FIFOs
325       P:000101 P:000101 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 7



326       P:000102 P:000102 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            000102
327       P:000104 P:000104 0A8982  CLR0      JCLR    #SRRQ,X:DSR,CLR1                  ; Wait for the receiver to be empty
                            000109
328       P:000106 P:000106 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
329       P:000107 P:000107 000000            NOP
330       P:000108 P:000108 0C0104            JMP     <CLR0
331                                 CLR1
332    
333                                 ; Repy = DONE host flags
334       P:000109 P:000109 448600            MOVE              X:<FLAG_DONE,X0         ; Flag = 1 => Normal execution
335       P:00010A P:00010A 441C00            MOVE              X0,X:<HOST_FLAG
336       P:00010B P:00010B 0D0175            JSR     <FO_WRITE_HOST_FLAG
337    
338                                 ; ********************************************************************
339                                 ;
340                                 ;                       REGISTER  USAGE
341                                 ;
342                                 ;       X0, X1, Y0, Y1, A and B are used freely in READ_IMAGE. Interrups
343                                 ;               during readout will clobber these registers, as a result
344                                 ;               of which only catastrophic commands such as ABORT_READOUT
345                                 ;               and BOOT_EEPROM are allowed during readout.
346                                 ;
347                                 ;       X0, X1 and A are used for all interrupt handling routines, such
348                                 ;               as CLEAR_HOST-FLAGS, command processing and so on.
349                                 ;
350                                 ;       Y0, Y1 and B are used for all fiber optic processing routines,
351                                 ;               which are not in interrupt service routines.
352                                 ;
353                                 ; *********************************************************************
354    
355    
356    
357                                 ; ************  Start of command interpreting code  ******************
358    
359                                 ; Test for fiber optic data on the FIFO. Discard the header for now
360    
361                                 ; Check for the header $AC in the first byte = Y0. Wait a little while and
362                                 ;  clear the FIFO if its not $AC - there was probably noise on the line.
363                                 ; We assume only two word replies here - Header = (S,D,#words)  Reply
364    
365       P:00010C P:00010C 01AD80  GET_FO    JCLR    #EF,X:PDRD,*                      ; Test for new fiber optic data
                            00010C
366       P:00010E P:00010E 000000            NOP
367       P:00010F P:00010F 000000            NOP
368       P:000110 P:000110 01AD80            JCLR    #EF,X:PDRD,GET_FO
                            00010C
369       P:000112 P:000112 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
370       P:000113 P:000113 0E8187            JCS     <FO_ERR
371    
372                                 ; Check the header bytes for self-consistency
373       P:000114 P:000114 21A600            MOVE              B1,Y0
374       P:000115 P:000115 57F400            MOVE              #$FCFCF8,B              ; Test for S.LE.3 and D.LE.3 and N.LE.7
                            FCFCF8
375       P:000117 P:000117 20005E            AND     Y0,B
376       P:000118 P:000118 0E2180            JNE     <HDR_ERR                          ; Test failed
377       P:000119 P:000119 57F400            MOVE              #$030300,B              ; Test for either S.NE.0 or D.NE.0
                            030300
378       P:00011B P:00011B 20005E            AND     Y0,B
379       P:00011C P:00011C 0EA180            JEQ     <HDR_ERR                          ; Test failed
380       P:00011D P:00011D 57F400            MOVE              #>7,B
                            000007
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 8



381       P:00011F P:00011F 20005E            AND     Y0,B                              ; Extract NWORDS, must be >= 2
382       P:000120 P:000120 01418D            CMP     #1,B
383       P:000121 P:000121 0EF180            JLE     <HDR_ERR
384       P:000122 P:000122 20CF00            MOVE              Y0,B
385       P:000123 P:000123 0C1891            EXTRACTU #$008020,B,B                     ; Extract bits 15-8 = destination byte
                            008020
386       P:000125 P:000125 000000            NOP
387       P:000126 P:000126 511D00            MOVE              B0,X:<FO_DEST
388    
389                                 ; Check whether this is a self-test header
390       P:000127 P:000127 579D00            MOVE              X:<FO_DEST,B            ; B1 = Destination
391       P:000128 P:000128 01428D            CMP     #2,B
392       P:000129 P:000129 0EA191            JEQ     <SELF_TEST                        ; Command = $000203 'TDL' value
393    
394                                 ; Read the reply or command from the fiber optics FIFO
395       P:00012A P:00012A 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
396       P:00012B P:00012B 0E8187            JCS     <FO_ERR
397       P:00012C P:00012C 551E00            MOVE              B1,X:<FO_CMD
398    
399                                 ; Check for commands from the controller to the PCI board, FO_DEST = 1
400       P:00012D P:00012D 579D00            MOVE              X:<FO_DEST,B
401       P:00012E P:00012E 01418D            CMP     #1,B
402       P:00012F P:00012F 0E213E            JNE     <HOSTCMD
403       P:000130 P:000130 579E00            MOVE              X:<FO_CMD,B
404       P:000131 P:000131 0140CD            CMP     #'RDA',B                          ; Read the image
                            524441
405       P:000133 P:000133 0EA251            JEQ     <READ_IMAGE
406       P:000134 P:000134 0140CD            CMP     #'IIA',B
                            494941
407       P:000136 P:000136 0EA220            JEQ     <INITIALIZE_NUMBER_OF_PIXELS      ; IPXLS = 0
408       P:000137 P:000137 0140CD            CMP     #'RDI',B
                            524449
409       P:000139 P:000139 0EA165            JEQ     <READING_IMAGE                    ; Controller is reading an image
410       P:00013A P:00013A 0140CD            CMP     #'RDO',B
                            52444F
411       P:00013C P:00013C 0EA170            JEQ     <READING_IMAGE_OFF                ; Controller no longer reading an image
412       P:00013D P:00013D 0C010C            JMP     <GET_FO                           ; Not on the list -> just ignore it
413    
414                                 ; Check if the command or reply is for the host. If not just ignore it.
415       P:00013E P:00013E 579D00  HOSTCMD   MOVE              X:<FO_DEST,B
416       P:00013F P:00013F 01408D            CMP     #0,B
417       P:000140 P:000140 0E210C            JNE     <GET_FO
418       P:000141 P:000141 579E00            MOVE              X:<FO_CMD,B
419       P:000142 P:000142 0140CD            CMP     #'DON',B
                            444F4E
420       P:000144 P:000144 0EA155            JEQ     <CONTROLLER_DONE                  ; Normal DONE reply
421       P:000145 P:000145 0A00A1            JSET    #TIMROMBURN,X:STATUS,FO_REPLY     ; If executing TimRomBurn
                            000150
422       P:000147 P:000147 0140CD            CMP     #'ERR',B
                            455252
423       P:000149 P:000149 0EA159            JEQ     <CONTROLLER_ERROR                 ; Error reply
424       P:00014A P:00014A 0140CD            CMP     #'BSY',B
                            425359
425       P:00014C P:00014C 0EA161            JEQ     <CONTROLLER_BUSY                  ; Controller is busy executing a command
426       P:00014D P:00014D 0140CD            CMP     #'SYR',B
                            535952
427       P:00014F P:00014F 0EA15D            JEQ     <CONTROLLER_RESET                 ; Controller system reset
428    
429                                 ; The controller reply is none of the above so return it as a reply
430                                 FO_REPLY
431       P:000150 P:000150 551B00            MOVE              B1,X:<REPLY             ; Report value
432       P:000151 P:000151 468700            MOVE              X:<FLAG_REPLY,Y0        ; Flag = 2 => Reply with a value
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 9



433       P:000152 P:000152 461C00            MOVE              Y0,X:<HOST_FLAG
434       P:000153 P:000153 0D0175            JSR     <FO_WRITE_HOST_FLAG
435       P:000154 P:000154 0C010C            JMP     <GET_FO
436    
437                                 CONTROLLER_DONE
438       P:000155 P:000155 468600            MOVE              X:<FLAG_DONE,Y0         ; Flag = 1 => Normal execution
439       P:000156 P:000156 461C00            MOVE              Y0,X:<HOST_FLAG
440       P:000157 P:000157 0D0175            JSR     <FO_WRITE_HOST_FLAG
441       P:000158 P:000158 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
442    
443                                 CONTROLLER_ERROR
444       P:000159 P:000159 468800            MOVE              X:<FLAG_ERR,Y0          ; Flag = 3 => controller error
445       P:00015A P:00015A 461C00            MOVE              Y0,X:<HOST_FLAG
446       P:00015B P:00015B 0D0175            JSR     <FO_WRITE_HOST_FLAG
447       P:00015C P:00015C 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
448    
449                                 CONTROLLER_RESET
450       P:00015D P:00015D 468900            MOVE              X:<FLAG_SYR,Y0          ; Flag = 4 => controller reset
451       P:00015E P:00015E 461C00            MOVE              Y0,X:<HOST_FLAG
452       P:00015F P:00015F 0D0175            JSR     <FO_WRITE_HOST_FLAG
453       P:000160 P:000160 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
454    
455                                 CONTROLLER_BUSY
456       P:000161 P:000161 468B00            MOVE              X:<FLAG_BUSY,Y0         ; Flag = 6 => controller busy
457       P:000162 P:000162 461C00            MOVE              Y0,X:<HOST_FLAG
458       P:000163 P:000163 0D0175            JSR     <FO_WRITE_HOST_FLAG
459       P:000164 P:000164 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
460    
461                                 ; A special handshaking here ensures that the host computer has read the 'DON'
462                                 ;   reply to the start_exposure command before the reading_image state is
463                                 ;   set in the host flags. Reading_image occurs only after a start_exposure
464                                 READING_IMAGE
465       P:000165 P:000165 579C00            MOVE              X:<HOST_FLAG,B          ; Retrieve current host flag value
466       P:000166 P:000166 448A00            MOVE              X:<FLAG_RDI,X0
467       P:000167 P:000167 20004D            CMP     X0,B                              ; If we're already in read_image
468       P:000168 P:000168 0EA10C            JEQ     <GET_FO                           ;   mode then do nothing
469       P:000169 P:000169 20000B            TST     B                                 ; Wait for flag to be cleared, which
470       P:00016A P:00016A 0E2165            JNE     <READING_IMAGE                    ;  the host does when it gets the DONE
471    
472       P:00016B P:00016B 0A8500            BCLR    #HCIE,X:DCTR                      ; Disable host command interrupts
473       P:00016C P:00016C 468A00            MOVE              X:<FLAG_RDI,Y0
474       P:00016D P:00016D 461C00            MOVE              Y0,X:<HOST_FLAG
475       P:00016E P:00016E 0D0175            JSR     <FO_WRITE_HOST_FLAG               ; Set Host Flag to "reading out"
476       P:00016F P:00016F 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
477    
478                                 READING_IMAGE_OFF                                   ; Controller is no longer reading out
479       P:000170 P:000170 468500            MOVE              X:<FLAG_ZERO,Y0
480       P:000171 P:000171 461C00            MOVE              Y0,X:<HOST_FLAG
481       P:000172 P:000172 0D0175            JSR     <FO_WRITE_HOST_FLAG
482       P:000173 P:000173 0A8520            BSET    #HCIE,X:DCTR                      ; Enable host command interrupts
483       P:000174 P:000174 0C010C            JMP     <GET_FO                           ; Keep looping for fiber optic commands
484    
485                                 ; Write X:<HOST_FLAG to the DCTR flag bits 5,4,3, as an program
486                                 FO_WRITE_HOST_FLAG
487       P:000175 P:000175 57F000            MOVE              X:DCTR,B
                            FFFFC5
488       P:000177 P:000177 469C00            MOVE              X:<HOST_FLAG,Y0
489       P:000178 P:000178 0140CE            AND     #$FFFFC7,B                        ; Clear bits 5,4,3
                            FFFFC7
490       P:00017A P:00017A 000000            NOP
491       P:00017B P:00017B 20005A            OR      Y0,B                              ; Set flags appropriately
492       P:00017C P:00017C 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 10



493       P:00017D P:00017D 577000            MOVE              B,X:DCTR
                            FFFFC5
494       P:00017F P:00017F 00000C            RTS
495    
496                                 ; There was an erroneous header word on the fiber optic line
497       P:000180 P:000180 46F400  HDR_ERR   MOVE              #'HDR',Y0
                            484452
498       P:000182 P:000182 461B00            MOVE              Y0,X:<REPLY             ; Set REPLY = header as a diagnostic
499       P:000183 P:000183 468700            MOVE              X:<FLAG_REPLY,Y0        ; Flag = 2 => Reply with a value
500       P:000184 P:000184 461C00            MOVE              Y0,X:<HOST_FLAG
501       P:000185 P:000185 0D0175            JSR     <FO_WRITE_HOST_FLAG
502       P:000186 P:000186 0C010C            JMP     <GET_FO
503    
504                                 FO_ERR
505       P:000187 P:000187 07F42D            MOVEP             #%011000,X:PDRD         ; Clear FIFO RESET* for 2 milliseconds
                            000018
506       P:000189 P:000189 46F400            MOVE              #200000,Y0
                            030D40
507       P:00018B P:00018B 06C600            DO      Y0,*+3
                            00018D
508       P:00018D P:00018D 000000            NOP
509       P:00018E P:00018E 07F42D            MOVEP             #%011100,X:PDRD
                            00001C
510       P:000190 P:000190 0C010C            JMP     <GET_FO
511    
512                                 ; Connect PCI board fiber out <==> fiber in and execute 'TDL' timing board
513                                 SELF_TEST
514       P:000191 P:000191 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the 'COMMAND' into B1
515       P:000192 P:000192 0E8187            JCS     <FO_ERR
516       P:000193 P:000193 0140CD            CMP     #'TDL',B
                            54444C
517       P:000195 P:000195 0E2159            JNE     <CONTROLLER_ERROR                 ; Must be 'TDL' if destination = 2
518       P:000196 P:000196 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the argument into B1
519       P:000197 P:000197 0E8187            JCS     <FO_ERR
520       P:000198 P:000198 0C0150            JMP     <FO_REPLY                         ; Return argument as the reply value
521    
522                                 ; **************  Boot from byte-wide on-board EEPROM  *******************
523    
524                                 BOOT_EEPROM
525       P:000199 P:000199 08F4BB            MOVEP             #$0202A0,X:BCR          ; Bus Control Register for slow EEPROM
                            0202A0
526       P:00019B P:00019B 044EBA            MOVE              OMR,A
527       P:00019C P:00019C 0140C6            AND     #$FFFFF0,A
                            FFFFF0
528       P:00019E P:00019E 014982            OR      #$000009,A                        ; Boot mode = $9 = byte-wide EEPROM
529       P:00019F P:00019F 000000            NOP
530       P:0001A0 P:0001A0 04CEBA            MOVE              A,OMR
531       P:0001A1 P:0001A1 0AF080            JMP     $FF0000                           ; Jump to boot code internal to DSP
                            FF0000
532    
533                                 ; ***************  Command processing  ****************
534    
535                                 WRITE_COMMAND
536       P:0001A3 P:0001A3 0A8982            JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
537       P:0001A5 P:0001A5 084E0B            MOVEP             X:DRXR,A                ; Get the header
538       P:0001A6 P:0001A6 000000            NOP                                       ; Pipeline restriction
539       P:0001A7 P:0001A7 543000            MOVE              A1,X:<HEADER
540    
541                                 ; Check the header bytes for self-consistency
542       P:0001A8 P:0001A8 218400            MOVE              A1,X0
543       P:0001A9 P:0001A9 56F400            MOVE              #$FCFCF8,A              ; Test for S.LE.3 and D.LE.3 and N.LE.7
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 11



                            FCFCF8
544       P:0001AB P:0001AB 200046            AND     X0,A
545       P:0001AC P:0001AC 0E23D3            JNE     <ERROR                            ; Test failed
546       P:0001AD P:0001AD 56F400            MOVE              #$030300,A              ; Test for either S.NE.0 or D.NE.0
                            030300
547       P:0001AF P:0001AF 200046            AND     X0,A
548       P:0001B0 P:0001B0 0EA3D3            JEQ     <ERROR                            ; Test failed
549       P:0001B1 P:0001B1 56F400            MOVE              #>7,A
                            000007
550       P:0001B3 P:0001B3 200046            AND     X0,A                              ; Extract NUM_ARG, must be >= 0
551       P:0001B4 P:0001B4 000000            NOP                                       ; Pipeline restriction
552       P:0001B5 P:0001B5 014284            SUB     #2,A
553       P:0001B6 P:0001B6 0E93D3            JLT     <ERROR                            ; Number of arguments >= 0
554       P:0001B7 P:0001B7 543500            MOVE              A1,X:<NUM_ARG           ; Store number of arguments in command
555       P:0001B8 P:0001B8 014685            CMP     #6,A                              ; Number of arguemnts <= 6
556       P:0001B9 P:0001B9 0E73D3            JGT     <ERROR
557    
558                                 ; Get the DESTINATION number (1 = PCI, 2 = timing, 3 = utility)
559       P:0001BA P:0001BA 208E00            MOVE              X0,A                    ; Still the header
560       P:0001BB P:0001BB 0C1ED0            LSR     #8,A
561       P:0001BC P:0001BC 0140C6            AND     #>3,A                             ; Extract just three bits of
                            000003
562       P:0001BE P:0001BE 543400            MOVE              A1,X:<DESTINATION       ;   the destination byte
563       P:0001BF P:0001BF 0EA3D3            JEQ     <ERROR                            ; Destination of zero = host not allowed
564       P:0001C0 P:0001C0 014185            CMP     #1,A                              ; Destination byte for PCI board
565       P:0001C1 P:0001C1 0EA1CE            JEQ     <PCI
566    
567                                 ; Write the controller command and its arguments to the timing board
568       P:0001C2 P:0001C2 56B000            MOVE              X:<HEADER,A
569       P:0001C3 P:0001C3 0D03FC            JSR     <XMT_WRD                          ; Write the word to the fiber optics
570       P:0001C4 P:0001C4 0A8982            JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
571       P:0001C6 P:0001C6 084E0B            MOVEP             X:DRXR,A                ; Write the command
572       P:0001C7 P:0001C7 0D03FC            JSR     <XMT_WRD                          ; Write the command to the fiber optics
573       P:0001C8 P:0001C8 063500            DO      X:<NUM_ARG,L_ARGS1                ; Do loop won't execute if NUM_ARG = 0
                            0001CC
574       P:0001CA P:0001CA 084E0B            MOVEP             X:DRXR,A                ; Get the arguments
575       P:0001CB P:0001CB 0D03FC            JSR     <XMT_WRD                          ; Write the argument to the fiber optics
576       P:0001CC P:0001CC 000000            NOP                                       ; DO loop restriction
577       P:0001CD P:0001CD 000004  L_ARGS1   RTI                                       ; The controller will generate the reply
578    
579                                 ; Since it's a PCI command store the command and its arguments in X: memory
580       P:0001CE P:0001CE 0A8982  PCI       JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
581       P:0001D0 P:0001D0 08708B            MOVEP             X:DRXR,X:COMMAND        ; Get the command
                            000031
582       P:0001D2 P:0001D2 56B500            MOVE              X:<NUM_ARG,A            ; Get number of arguments in command
583       P:0001D3 P:0001D3 60F400            MOVE              #ARG1,R0                ; Starting address of argument list
                            000032
584       P:0001D5 P:0001D5 06CE00            DO      A,L_ARGS2                         ; DO loop won't execute if A = 0
                            0001D9
585       P:0001D7 P:0001D7 0A8982            JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
586       P:0001D9 P:0001D9 08588B            MOVEP             X:DRXR,X:(R0)+          ; Get arguments
587                                 L_ARGS2
588    
589                                 ; Process a PCI board non-vector command
590       P:0001DA P:0001DA 56B100            MOVE              X:<COMMAND,A            ; Get the command
591       P:0001DB P:0001DB 0140C5            CMP     #'TRM',A                          ; Is it the test DRAM command?
                            54524D
592       P:0001DD P:0001DD 0EA45B            JEQ     <TEST_DRAM
593       P:0001DE P:0001DE 0140C5            CMP     #'TDL',A                          ; Is it the test data link command?
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 12



                            54444C
594       P:0001E0 P:0001E0 0EA37B            JEQ     <TEST_DATA_LINK
595       P:0001E1 P:0001E1 0140C5            CMP     #'RDM',A
                            52444D
596       P:0001E3 P:0001E3 0EA37D            JEQ     <READ_MEMORY                      ; Is it the read memory command?
597       P:0001E4 P:0001E4 0140C5            CMP     #'WRM',A
                            57524D
598       P:0001E6 P:0001E6 0EA3A2            JEQ     <WRITE_MEMORY                     ; Is it the write memory command?
599       P:0001E7 P:0001E7 0C03D3            JMP     <ERROR                            ; Its not a recognized command
600    
601                                 ; ********************  Vector commands  *******************
602    
603                                 READ_NUMBER_OF_PIXELS_READ                          ; Write the reply to the DTXS FIFO
604       P:0001E8 P:0001E8 08F08D            MOVEP             X:R_PXLS_0,X:DTXS       ; DSP-to-host slave transmit
                            00001A
605       P:0001EA P:0001EA 000000            NOP
606       P:0001EB P:0001EB 08F08D            MOVEP             X:R_PXLS_1,X:DTXS       ; DSP-to-host slave transmit
                            000019
607    
608       P:0001ED P:0001ED 000004            RTI
609    
610                                 ; Reset the controller by transmitting a special byte code
611                                 RESET_CONTROLLER
612       P:0001EE P:0001EE 011D22            BSET    #SCLK,X:PDRE                      ; Enable special command mode
613       P:0001EF P:0001EF 000000            NOP
614       P:0001F0 P:0001F0 000000            NOP
615       P:0001F1 P:0001F1 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
616       P:0001F3 P:0001F3 44F400            MOVE              #$10000B,X0             ; Special command to reset controller
                            10000B
617       P:0001F5 P:0001F5 446000            MOVE              X0,X:(R0)
618       P:0001F6 P:0001F6 0606A0            REP     #6                                ; Wait for transmission to complete
619       P:0001F7 P:0001F7 000000            NOP
620       P:0001F8 P:0001F8 011D02            BCLR    #SCLK,X:PDRE                      ; Disable special command mode
621    
622                                 ; Wait until the timing board is reset, because FO data is invalid
623       P:0001F9 P:0001F9 44F400            MOVE              #10000,X0               ; Delay by about 350 milliseconds
                            002710
624       P:0001FB P:0001FB 06C400            DO      X0,L_DELAY
                            000201
625       P:0001FD P:0001FD 06E883            DO      #1000,L_RDFIFO
                            000200
626       P:0001FF P:0001FF 09463F            MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word to keep the
627       P:000200 P:000200 000000            NOP                                       ;   receiver empty
628                                 L_RDFIFO
629       P:000201 P:000201 000000            NOP
630                                 L_DELAY
631       P:000202 P:000202 000000            NOP
632    
633                                 ; Wait for 'SYR' from the controller, with a 260 millisecond timeout
634       P:000203 P:000203 061480            DO      #20,L_WAIT_SYR
                            000209
635       P:000205 P:000205 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
636       P:000206 P:000206 0E8209            JCS     <L_WAIT_SYR-1
637       P:000207 P:000207 00008C            ENDDO
638       P:000208 P:000208 0C020B            JMP     <L_SYS
639       P:000209 P:000209 000000            NOP
640                                 L_WAIT_SYR
641       P:00020A P:00020A 0C03D3            JMP     <ERROR                            ; Timeout, respond with error
642    
643       P:00020B P:00020B 0140CD  L_SYS     CMP     #$020002,B
                            020002
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 13



644       P:00020D P:00020D 0E23D3            JNE     <ERROR                            ; There was an error
645       P:00020E P:00020E 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
646       P:00020F P:00020F 0E83D3            JCS     <ERROR
647       P:000210 P:000210 0140CD            CMP     #'SYR',B
                            535952
648       P:000212 P:000212 0E23D3            JNE     <ERROR                            ; There was an error
649       P:000213 P:000213 0C03D6            JMP     <SYR                              ; Reply to host, return from interrupt
650    
651                                 ; ****************  Exposure and readout commands  ****************
652    
653                                 WRITE_BASE_PCI_ADDRESS
654       P:000214 P:000214 0A8982            JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
655       P:000216 P:000216 08480B            MOVEP             X:DRXR,A0
656       P:000217 P:000217 0A8982            JCLR    #SRRQ,X:DSR,ERROR                 ; Error if receiver FIFO has no data
                            0003D3
657       P:000219 P:000219 08440B            MOVEP             X:DRXR,X0               ; Get most significant word
658       P:00021A P:00021A 0C1940            INSERT  #$010010,X0,A
                            010010
659       P:00021C P:00021C 000000            NOP
660       P:00021D P:00021D 501200            MOVE              A0,X:<BASE_ADDR_0       ; BASE_ADDR is 8 + 24 bits
661       P:00021E P:00021E 541100            MOVE              A1,X:<BASE_ADDR_1
662       P:00021F P:00021F 0C03CC            JMP     <FINISH                           ; Write 'DON' reply
663    
664                                 ; Write the base PCI image address to the PCI address
665                                 INITIALIZE_NUMBER_OF_PIXELS
666       P:000220 P:000220 200013            CLR     A
667       P:000221 P:000221 000000            NOP
668       P:000222 P:000222 541900            MOVE              A1,X:<R_PXLS_1          ; Up counter of number of pixels read
669       P:000223 P:000223 501A00            MOVE              A0,X:<R_PXLS_0
670    
671       P:000224 P:000224 509200            MOVE              X:<BASE_ADDR_0,A0       ; BASE_ADDR is 2 x 16-bits
672       P:000225 P:000225 549100            MOVE              X:<BASE_ADDR_1,A1
673       P:000226 P:000226 000000            NOP
674       P:000227 P:000227 501400            MOVE              A0,X:<PCI_ADDR_0        ; PCI_ADDR is 8 + 24 bits
675       P:000228 P:000228 541300            MOVE              A1,X:<PCI_ADDR_1
676    
677       P:000229 P:000229 0C0155            JMP     <CONTROLLER_DONE                  ; Repy = DONE host flags
678    
679                                 ; Send an abort readout command to the controller to stop image transmission
680                                 ABORT_READOUT
681       P:00022A P:00022A 448600            MOVE              X:<FLAG_DONE,X0
682       P:00022B P:00022B 441C00            MOVE              X0,X:<HOST_FLAG
683       P:00022C P:00022C 0D0175            JSR     <FO_WRITE_HOST_FLAG
684    
685       P:00022D P:00022D 568E00            MOVE              X:<C000202,A
686       P:00022E P:00022E 0D03FC            JSR     <XMT_WRD                          ; Timing board header word
687       P:00022F P:00022F 56F400            MOVE              #'ABR',A
                            414252
688       P:000231 P:000231 0D03FC            JSR     <XMT_WRD                          ; Abort Readout
689    
690                                 ; Ensure that image data is no longer being received from the controller
691       P:000232 P:000232 01AD80  ABR0      JCLR    #EF,X:PDRD,ABR2                   ; Test for incoming FIFO data
                            000238
692       P:000234 P:000234 09443F  ABR1      MOVEP             Y:RDFIFO,X0             ; Read the FIFO until its empty
693       P:000235 P:000235 000000            NOP
694       P:000236 P:000236 01ADA0            JSET    #EF,X:PDRD,ABR1
                            000234
695       P:000238 P:000238 066089  ABR2      DO      #2400,ABR3                        ; Wait for about 30 microsec in case
                            00023A
696       P:00023A P:00023A 000000            NOP                                       ;   FIFO data is still arriving
697       P:00023B P:00023B 01ADA0  ABR3      JSET    #EF,X:PDRD,ABR1                   ; Keep emptying if more data arrived
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 14



                            000234
698    
699                                 ; Wait for a 'DON' reply from the controller
700       P:00023D P:00023D 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
701       P:00023E P:00023E 0E8247            JCS     <CLEAN_UP_PCI
702       P:00023F P:00023F 0140CD            CMP     #$020002,B
                            020002
703       P:000241 P:000241 0E23D3            JNE     <ERROR                            ; There was an error
704       P:000242 P:000242 0D0429            JSR     <RD_FO_TIMEOUT                    ; Move the FIFO reply into B1
705       P:000243 P:000243 0E83D3            JCS     <ERROR
706       P:000244 P:000244 0140CD            CMP     #'DON',B
                            444F4E
707       P:000246 P:000246 0E23D3            JNE     <ERROR                            ; There was an error
708    
709                                 ; Clean up the PCI board from wherever it was executing
710                                 CLEAN_UP_PCI
711       P:000247 P:000247 08F4BF            MOVEP             #$0001C0,X:IPRC         ; Disable HF* FIFO interrupt
                            0001C0
712       P:000249 P:000249 0A8520            BSET    #HCIE,X:DCTR                      ; Enable host command interrupts
713       P:00024A P:00024A 0501BB            MOVEC             #1,SP                   ; Point stack pointer to the top
714       P:00024B P:00024B 05F43D            MOVEC             #$000200,SSL            ; SR = zero except for interrupts
                            000200
715       P:00024D P:00024D 0500BB            MOVEC             #0,SP                   ; Writing to SSH preincrements the SP
716       P:00024E P:00024E 05B2BC            MOVEC             #START,SSH              ; Set PC to for full initialization
717       P:00024F P:00024F 000000            NOP
718       P:000250 P:000250 000004            RTI
719    
720                                 ; Read the image - change the serial receiver to expect 16-bit (image) data
721                                 READ_IMAGE
722       P:000251 P:000251 0A8500            BCLR    #HCIE,X:DCTR                      ; Disable host command interrupts
723       P:000252 P:000252 448A00            MOVE              X:<FLAG_RDI,X0
724       P:000253 P:000253 441C00            MOVE              X0,X:<HOST_FLAG
725       P:000254 P:000254 0D0175            JSR     <FO_WRITE_HOST_FLAG               ; Set HCTR bits to "reading out"
726       P:000255 P:000255 084E0A            MOVEP             X:DPSR,A                ; Clear all PCI error conditions
727       P:000256 P:000256 0140C2            OR      #$1FE,A
                            0001FE
728       P:000258 P:000258 000000            NOP
729       P:000259 P:000259 08CE0A            MOVEP             A,X:DPSR
730       P:00025A P:00025A 0A862E            BSET    #CLRT,X:DPCR                      ; Clear the master transmitter FIFO
731       P:00025B P:00025B 0A86AE            JSET    #CLRT,X:DPCR,*                    ; Wait for the clearing to be complete
                            00025B
732    
733                                 ; Compute the number of pixels to read from the controller
734       P:00025D P:00025D 0D0429            JSR     <RD_FO_TIMEOUT                    ; Read number of columns
735       P:00025E P:00025E 0E8187            JCS     <FO_ERR
736       P:00025F P:00025F 21A500            MOVE              B1,X1
737       P:000260 P:000260 0D0429            JSR     <RD_FO_TIMEOUT                    ; Read number of rows
738       P:000261 P:000261 0E8187            JCS     <FO_ERR
739       P:000262 P:000262 21A700            MOVE              B1,Y1                   ; Number of rows to read is in Y1
740       P:000263 P:000263 2000F0            MPY     X1,Y1,A
741       P:000264 P:000264 200022            ASR     A                                 ; Correct for 0 in LS bit after MPY
742       P:000265 P:000265 20001B            CLR     B
743       P:000266 P:000266 541500            MOVE              A1,X:<NPXLS_1           ; NPXLS set by controller
744       P:000267 P:000267 501600            MOVE              A0,X:<NPXLS_0
745       P:000268 P:000268 551700            MOVE              B1,X:<IPXLS_1           ; IPXLS = 0
746       P:000269 P:000269 511800            MOVE              B0,X:<IPXLS_0
747       P:00026A P:00026A 212500            MOVE              B0,X1                   ; X = 512 = 1/2 the FIFO depth
748       P:00026B P:00026B 448C00            MOVE              X:<C512,X0
749    
750                                 ; There are three separate stages of writing the image to the PCI bus
751                                 ;       a. Write complete 512 pixel FIFO half full blocks
752                                 ;       b. Write the pixels left over from the last complete FIFO block
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 15



753                                 ;       c. Write one pixel if the image has an odd number of pixels
754    
755    
756                                 ; Compute the number of pixel pairs from the FIFO --> PCI bus
757       P:00026C P:00026C 200013  L_FIFO    CLR     A
758       P:00026D P:00026D 479700            MOVE              X:<IPXLS_1,Y1           ; Compare it to image size
759       P:00026E P:00026E 469800            MOVE              X:<IPXLS_0,Y0
760       P:00026F P:00026F 549500            MOVE              X:<NPXLS_1,A1           ; Number of pixels to write to PCI
761       P:000270 P:000270 509600            MOVE              X:<NPXLS_0,A0
762       P:000271 P:000271 000000            NOP
763       P:000272 P:000272 200034            SUB     Y,A                               ; If (Npixels - Ipixels) <= 512
764       P:000273 P:000273 000000            NOP                                       ;   we're at the end of the image
765       P:000274 P:000274 200024            SUB     X,A
766       P:000275 P:000275 0EF2B7            JLE     <WRITE_LAST_LITTLE_BIT_OF_IMAGE
767    
768                                 ; (a) New DMA writing in burst mode, 16 pixels in a burst
769                                 WR_IMAGE
770       P:000276 P:000276 01ADA1            JSET    #HF,X:PDRD,*                      ; Wait for FIFO to be half full + 1
                            000276
771       P:000278 P:000278 000000            NOP
772       P:000279 P:000279 000000            NOP
773       P:00027A P:00027A 01ADA1            JSET    #HF,X:PDRD,WR_IMAGE               ; Protection against metastability
                            000276
774    
775                                 ; Copy the image block (512 pixels) to DSP X: memory
776       P:00027C P:00027C 300000            MOVE              #<IMAGE_BUFER,R0
777       P:00027D P:00027D 060082            DO      #512,L_BUFFER
                            00027F
778       P:00027F P:00027F 0958FF            MOVEP             Y:RDFIFO,Y:(R0)+
779                                 L_BUFFER
780       P:000280 P:000280 300000            MOVE              #<IMAGE_BUFER,R0
781       P:000281 P:000281 381000            MOVE              #16,N0                  ; Number of pixels per transfer (!!!)
782    
783                                 ; Prepare the HI32 DPMC and DPAR address registers
784       P:000282 P:000282 549300            MOVE              X:<PCI_ADDR_1,A1        ; Current PCI address
785       P:000283 P:000283 509400            MOVE              X:<PCI_ADDR_0,A0
786       P:000284 P:000284 0C1D10            ASL     #8,A,A
787       P:000285 P:000285 000000            NOP
788       P:000286 P:000286 0140C2            ORI     #$070000,A                        ; Burst length = # of PCI writes (!!!)
                            070000
789       P:000288 P:000288 000000            NOP                                       ;   = # of pixels / 2 - 1
790       P:000289 P:000289 547000            MOVE              A1,X:DPMC               ; DPMC = B[31:16] + $070000
                            FFFFC7
791       P:00028B P:00028B 0C1D20            ASL     #16,A,A                           ; Get PCI_ADDR[15:0] into A1[15:0]
792       P:00028C P:00028C 000000            NOP
793       P:00028D P:00028D 0140C6            AND     #$00FFFF,A
                            00FFFF
794       P:00028F P:00028F 000000            NOP
795       P:000290 P:000290 0140C2            OR      #$070000,A                        ; A1 will get written to DPAR register
                            070000
796    
797                                 ; Make sure its always 512 pixels per loop = 1/2 FIFO
798       P:000292 P:000292 607000            MOVE              R0,X:DSR0               ; Source address for DMA = pixel data
                            FFFFEF
799       P:000294 P:000294 08F4AE            MOVEP             #DTXM,X:DDR0            ; Destination = PCI master transmitter
                            FFFFCC
800       P:000296 P:000296 08F4AD            MOVEP             #>15,X:DCO0             ; DMA Count = # of pixels - 1 (!!!)
                            00000F
801    
802       P:000298 P:000298 062080            DO      #32,WR_BLK0                       ; x # of pixels = 512 (!!!)
                            0002A7
803       P:00029A P:00029A 08F4AC  AGAIN0    MOVEP             #$8EFA51,X:DCR0         ; Start DMA with control register DE=1
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 16



                            8EFA51
804       P:00029C P:00029C 08CC08            MOVEP             A1,X:DPAR               ; Initiate writing to the PCI bus
805       P:00029D P:00029D 000000            NOP
806       P:00029E P:00029E 000000            NOP
807       P:00029F P:00029F 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            00029F
808       P:0002A1 P:0002A1 0A8AAE            JSET    #MDT,X:DPSR,WR_OK0                ; If no error go to the next sub-block
                            0002A5
809       P:0002A3 P:0002A3 0D0324            JSR     <PCI_ERROR_RECOVERY
810       P:0002A4 P:0002A4 0C029A            JMP     <AGAIN0                           ; Just try to write the sub-block again
811       P:0002A5 P:0002A5 0140C0  WR_OK0    ADD     #>32,A                            ; PCI address = + 2 x # of pixels (!!!)
                            000020
812       P:0002A7 P:0002A7 204800            MOVE              (R0)+N0                 ; Pixel buffer address = + # of pixels
813                                 WR_BLK0
814    
815                                 ; Re-calculate and store the PCI address where image data is being written to
816       P:0002A8 P:0002A8 509800            MOVE              X:<IPXLS_0,A0           ; Number of pixels to write to PCI
817       P:0002A9 P:0002A9 549700            MOVE              X:<IPXLS_1,A1
818       P:0002AA P:0002AA 200020            ADD     X,A                               ; X = 512 = 1/2 FIFO size
819       P:0002AB P:0002AB 000000            NOP
820       P:0002AC P:0002AC 501800            MOVE              A0,X:<IPXLS_0           ; Number of pixels to write to PCI
821       P:0002AD P:0002AD 541700            MOVE              A1,X:<IPXLS_1
822       P:0002AE P:0002AE 549300            MOVE              X:<PCI_ADDR_1,A1        ; Current PCI address
823       P:0002AF P:0002AF 509400            MOVE              X:<PCI_ADDR_0,A0
824       P:0002B0 P:0002B0 200020            ADD     X,A                               ; Add the byte increment = 1024
825       P:0002B1 P:0002B1 200020            ADD     X,A
826       P:0002B2 P:0002B2 000000            NOP
827       P:0002B3 P:0002B3 541300            MOVE              A1,X:<PCI_ADDR_1        ; Incremented current PCI address
828       P:0002B4 P:0002B4 501400            MOVE              A0,X:<PCI_ADDR_0
829       P:0002B5 P:0002B5 0D0315            JSR     <C_RPXLS                          ; Calculate number of pixels read
830       P:0002B6 P:0002B6 0C026C            JMP     <L_FIFO                           ; Go process the next 1/2 FIFO
831    
832                                 ; (b) Write the pixels left over
833                                 WRITE_LAST_LITTLE_BIT_OF_IMAGE
834       P:0002B7 P:0002B7 0A0000            BCLR    #ODD,X:<STATUS
835       P:0002B8 P:0002B8 200020            ADD     X,A
836       P:0002B9 P:0002B9 200022            ASR     A                                 ; Two pixels written per loop
837       P:0002BA P:0002BA 0E02BC            JCC     *+2
838       P:0002BB P:0002BB 0A0020            BSET    #ODD,X:<STATUS                    ; ODD = 1 if carry bit is set
839       P:0002BC P:0002BC 559300            MOVE              X:<PCI_ADDR_1,B1        ; Current PCI address
840       P:0002BD P:0002BD 519400            MOVE              X:<PCI_ADDR_0,B0
841       P:0002BE P:0002BE 06C800            DO      A0,WR_BLK1
                            0002E0
842       P:0002C0 P:0002C0 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only. FC = 0 (32-bit)
                            010010
843       P:0002C2 P:0002C2 000000            NOP
844       P:0002C3 P:0002C3 08C807            MOVEP             A0,X:DPMC               ; DSP master control register
845       P:0002C4 P:0002C4 000000            NOP                                       ; FC = 0 -> 32-bit PCI writes
846       P:0002C5 P:0002C5 0C1890            EXTRACTU #$010000,B,A
                            010000
847       P:0002C7 P:0002C7 000000            NOP
848       P:0002C8 P:0002C8 210C00            MOVE              A0,A1
849       P:0002C9 P:0002C9 0140C2            OR      #$070000,A                        ; A1 gets written to DPAR register
                            070000
850       P:0002CB P:0002CB 000000            NOP
851    
852       P:0002CC P:0002CC 01AD80            JCLR    #EF,X:PDRD,*
                            0002CC
853       P:0002CE P:0002CE 0970BF            MOVEP             Y:RDFIFO,X:DTXM         ; Least significant word to transmit
                            FFFFCC
854       P:0002D0 P:0002D0 01AD80            JCLR    #EF,X:PDRD,*
                            0002D0
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 17



855       P:0002D2 P:0002D2 0970BF            MOVEP             Y:RDFIFO,X:DTXM         ; Most significant word to transmit
                            FFFFCC
856       P:0002D4 P:0002D4 08CC08  AGAIN1    MOVEP             A1,X:DPAR               ; Write to PCI bus
857       P:0002D5 P:0002D5 000000            NOP                                       ; Pipeline delay
858       P:0002D6 P:0002D6 000000            NOP                                       ; Pipeline delay
859       P:0002D7 P:0002D7 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Wait until the PCI operation is done
                            0002D7
860       P:0002D9 P:0002D9 0A8AAE            JSET    #MDT,X:DPSR,WR_OK1                ; If no error go to the next sub-block
                            0002DD
861       P:0002DB P:0002DB 0D0324            JSR     <PCI_ERROR_RECOVERY
862       P:0002DC P:0002DC 0C02D4            JMP     <AGAIN1                           ; Just try to write the sub-block again
863       P:0002DD P:0002DD 468400  WR_OK1    MOVE              X:<FOUR,Y0              ; Number of bytes per PCI write
864       P:0002DE P:0002DE 270000            MOVE              #0,Y1
865       P:0002DF P:0002DF 200038            ADD     Y,B                               ; Increment PCI address
866       P:0002E0 P:0002E0 000000            NOP
867                                 WR_BLK1
868    
869    
870                                 ; (c) Write the very last pixel if there is an odd number of pixels in the image
871       P:0002E1 P:0002E1 0A0080            JCLR    #ODD,X:STATUS,END_WR
                            000304
872       P:0002E3 P:0002E3 0C1890            EXTRACTU #$010010,B,A                     ; Get D31-16 bits only. FC = 0 (32-bit)
                            010010
873       P:0002E5 P:0002E5 000000            NOP
874       P:0002E6 P:0002E6 0AC876            BSET    #22,A0                            ; FC mode = 1
875       P:0002E7 P:0002E7 000000            NOP
876       P:0002E8 P:0002E8 08C807            MOVEP             A0,X:DPMC               ; DSP master control register
877       P:0002E9 P:0002E9 000000            NOP
878       P:0002EA P:0002EA 0C1890            EXTRACTU #$010000,B,A
                            010000
879       P:0002EC P:0002EC 000000            NOP
880       P:0002ED P:0002ED 210C00            MOVE              A0,A1
881       P:0002EE P:0002EE 000000            NOP
882       P:0002EF P:0002EF 0140C2            OR      #$C70000,A                        ; Write 16 LS bits only
                            C70000
883       P:0002F1 P:0002F1 000000            NOP
884       P:0002F2 P:0002F2 01AD80            JCLR    #EF,X:PDRD,*
                            0002F2
885       P:0002F4 P:0002F4 0970BF            MOVEP             Y:RDFIFO,X:DTXM         ; Least significant word to transmit
                            FFFFCC
886       P:0002F6 P:0002F6 08CC08  AGAIN2    MOVEP             A1,X:DPAR               ; Write to PCI bus
887       P:0002F7 P:0002F7 000000            NOP                                       ; Pipeline delay
888       P:0002F8 P:0002F8 000000            NOP                                       ; Pipeline delay
889       P:0002F9 P:0002F9 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Bit is clear if PCI still in progress
                            0002F9
890       P:0002FB P:0002FB 0A8AAE            JSET    #MDT,X:DPSR,DONE2                 ; If no error then we're all done
                            0002FF
891       P:0002FD P:0002FD 0D0324            JSR     <PCI_ERROR_RECOVERY
892       P:0002FE P:0002FE 0C02F6            JMP     <AGAIN2                           ; Just try to write the sub-block again
893       P:0002FF P:0002FF 46F400  DONE2     MOVE              #>2,Y0                  ; Number of bytes per PCI write
                            000002
894       P:000301 P:000301 270000            MOVE              #0,Y1
895       P:000302 P:000302 200038            ADD     Y,B                               ; Increment PCI address
896       P:000303 P:000303 000000            NOP
897    
898                                 ; Calculate and store the PCI address where image data is being written to
899       P:000304 P:000304 511400  END_WR    MOVE              B0,X:<PCI_ADDR_0        ; Update the PCI Address
900       P:000305 P:000305 551300            MOVE              B1,X:<PCI_ADDR_1
901    
902                                 ; As a kludge, delay to prevent elapsed exposure time read errors
903       P:000306 P:000306 44F400            MOVE              #1000,X0                ; 1 millisecond
                            0003E8
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 18



904       P:000308 P:000308 06C400            DO      X0,L_KLUDGE1
                            00030D
905       P:00030A P:00030A 066480            DO      #100,L_KLUDGE2                    ; 1 microsecond
                            00030C
906       P:00030C P:00030C 000000            NOP
907                                 L_KLUDGE2
908       P:00030D P:00030D 000000            NOP
909                                 L_KLUDGE1
910       P:00030E P:00030E 000000            NOP
911                                 ; End of kludge
912    
913       P:00030F P:00030F 0D0315            JSR     <C_RPXLS                          ; Calculate number of pixels read
914       P:000310 P:000310 448600            MOVE              X:<FLAG_DONE,X0
915       P:000311 P:000311 441C00            MOVE              X0,X:<HOST_FLAG
916       P:000312 P:000312 0D0175            JSR     <FO_WRITE_HOST_FLAG               ; Clear Host Flag to 'DONE'
917       P:000313 P:000313 0A8520            BSET    #HCIE,X:DCTR                      ; Enable host command interrupts
918                                 ;       BSET    #INTA,X:DCTR            ; Assert the PCI bus interrupt
919       P:000314 P:000314 0C010C            JMP     <GET_FO                           ; We're all done, go process FO input
920    
921                                 ; R_PXLS is the number of pixels read out since the last IIA command
922       P:000315 P:000315 200013  C_RPXLS   CLR     A
923       P:000316 P:000316 469200            MOVE              X:<BASE_ADDR_0,Y0       ; BASE_ADDR is 2 x 16-bits
924       P:000317 P:000317 479100            MOVE              X:<BASE_ADDR_1,Y1
925       P:000318 P:000318 549300            MOVE              X:<PCI_ADDR_1,A1        ; Current PCI address
926       P:000319 P:000319 509400            MOVE              X:<PCI_ADDR_0,A0
927       P:00031A P:00031A 000000            NOP
928       P:00031B P:00031B 200034            SUB     Y,A                               ; Current (PCI - BASE) address
929       P:00031C P:00031C 200022            ASR     A                                 ; /2 => convert byte address to pixel
930       P:00031D P:00031D 000000            NOP
931    
932       P:00031E P:00031E 501A00            MOVE              A0,X:<R_PXLS_0          ; R_PXLS is 2 x 16 bits, number of
933       P:00031F P:00031F 0C1880            EXTRACTU #$010010,A,A                     ;   image pixels read so far
                            010010
934       P:000321 P:000321 000000            NOP
935       P:000322 P:000322 501900            MOVE              A0,X:<R_PXLS_1
936       P:000323 P:000323 00000C            RTS
937    
938                                 ; Recover from an error writing to the PCI bus
939                                 PCI_ERROR_RECOVERY
940       P:000324 P:000324 0A8A8A            JCLR    #TRTY,X:DPSR,ERROR1               ; Retry error
                            000329
941       P:000326 P:000326 08F48A            MOVEP             #$0400,X:DPSR           ; Clear target retry error bit
                            000400
942       P:000328 P:000328 00000C            RTS
943       P:000329 P:000329 0A8A8B  ERROR1    JCLR    #TO,X:DPSR,ERROR2                 ; Timeout error
                            00032E
944       P:00032B P:00032B 08F48A            MOVEP             #$0800,X:DPSR           ; Clear timeout error bit
                            000800
945       P:00032D P:00032D 00000C            RTS
946       P:00032E P:00032E 0A8A89  ERROR2    JCLR    #TDIS,X:DPSR,ERROR3               ; Target disconnect error
                            000333
947       P:000330 P:000330 08F48A            MOVEP             #$0200,X:DPSR           ; Clear target disconnect bit
                            000200
948       P:000332 P:000332 00000C            RTS
949       P:000333 P:000333 0A8A88  ERROR3    JCLR    #TAB,X:DPSR,ERROR4                ; Target abort error
                            000338
950       P:000335 P:000335 08F48A            MOVEP             #$0800,X:DPSR           ; Clear target abort error bit
                            000800
951       P:000337 P:000337 00000C            RTS
952       P:000338 P:000338 0A8A87  ERROR4    JCLR    #MAB,X:DPSR,ERROR5                ; Master abort error
                            00033D
953       P:00033A P:00033A 08F48A            MOVEP             #$0080,X:DPSR           ; Clear master abort error bit
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 19



                            000080
954       P:00033C P:00033C 00000C            RTS
955       P:00033D P:00033D 0A8A86  ERROR5    JCLR    #DPER,X:DPSR,ERROR6               ; Data parity error
                            000342
956       P:00033F P:00033F 08F48A            MOVEP             #$0040,X:DPSR           ; Clear data parity error bit
                            000040
957       P:000341 P:000341 00000C            RTS
958       P:000342 P:000342 0A8A85  ERROR6    JCLR    #APER,X:DPSR,ERROR7               ; Address parity error
                            000346
959       P:000344 P:000344 08F48A            MOVEP             #$0020,X:DPSR           ; Clear address parity error bit
                            000020
960       P:000346 P:000346 00000C  ERROR7    RTS
961    
962                                 ; Write the remaining pixels of the DMA block on a retry error
963       P:000347 P:000347 0A8A8A  WR_ERR    JCLR    #TRTY,X:DPSR,TST_TO               ; Bit is set if its a retry
                            000372
964    
965                                 ; Save DPMC and DPAR for later use
966       P:000349 P:000349 087087            MOVEP             X:DPMC,X:SV_DPMC        ; These registers are changed here,
                            00001F
967       P:00034B P:00034B 542100            MOVE              A1,X:<SV_A1             ;   so save and restore them
968    
969                                 WR_ERR_AGAIN
970       P:00034C P:00034C 084E0A            MOVEP             X:DPSR,A                ; Get Remaining Data count bits[21:16]
971       P:00034D P:00034D 0C1EE0            LSR     #16,A                             ; Put RDC field in A1
972       P:00034E P:00034E 0A8A8F            JCLR    #RDCQ,X:DPSR,*+3
                            000351
973       P:000350 P:000350 014180            ADD     #1,A                              ; Add one if RDCQ is set
974       P:000351 P:000351 000000            NOP
975       P:000352 P:000352 218700            MOVE              A1,Y1                   ; Save Y1 = # of PCI words remaining
976    
977                                 ; Compute number of bytes completed, using previous DPMC burst length
978       P:000353 P:000353 084E07            MOVEP             X:DPMC,A
979       P:000354 P:000354 0140C6            ANDI    #$3F0000,A
                            3F0000
980       P:000356 P:000356 0C1EE0            LSR     #16,A
981       P:000357 P:000357 200074            SUB     Y1,A                              ; A1 = # of PCI writes completed
982       P:000358 P:000358 0C1E84            LSL     #2,A                              ; Convert to a byte address
983       P:000359 P:000359 000000            NOP
984       P:00035A P:00035A 218600            MOVE              A1,Y0                   ; Byte address of # completed
985    
986       P:00035B P:00035B 084E08            MOVEP             X:DPAR,A                ; Save Y0 = DPAR + # of bytes completed
987       P:00035C P:00035C 200050            ADD     Y0,A
988       P:00035D P:00035D 000000            NOP
989       P:00035E P:00035E 218600            MOVE              A1,Y0                   ; New DPAR value
990    
991                                 ; Write the new burst length to the X:DPMC register
992       P:00035F P:00035F 084E07            MOVEP             X:DPMC,A
993       P:000360 P:000360 0C1970            INSERT  #$006028,Y1,A                     ; Y1 = new burst length
                            006028
994       P:000362 P:000362 000000            NOP
995       P:000363 P:000363 08CC07            MOVEP             A1,X:DPMC               ; Update DPMC burst length
996    
997                                 ; Clear the TRTY error condition and initiate the PCI writing
998       P:000364 P:000364 08F48A            MOVEP             #$0400,X:DPSR           ; Clear the target retry bit
                            000400
999       P:000366 P:000366 08C608            MOVEP             Y0,X:DPAR               ; Initiate writing to the PCI bus
1000      P:000367 P:000367 000000            NOP
1001      P:000368 P:000368 000000            NOP
1002      P:000369 P:000369 0A8A84            JCLR    #MARQ,X:DPSR,*                    ; Test for PCI operation completion
                            000369
1003      P:00036B P:00036B 0A8AAE            JSET    #MDT,X:DPSR,WR_ERR_OK             ; Test for Master Data Transfer complete
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 20



                            00036E
1004      P:00036D P:00036D 0C034C            JMP     <WR_ERR_AGAIN
1005                                WR_ERR_OK
1006      P:00036E P:00036E 08F087            MOVEP             X:SV_DPMC,X:DPMC        ; Restore these two registers
                            00001F
1007      P:000370 P:000370 54A100            MOVE              X:<SV_A1,A1
1008      P:000371 P:000371 00000C            RTS
1009   
1010                                ; Handle these error conditions later
1011      P:000372 P:000372 0A8A8B  TST_TO    JCLR    #TO,X:DPSR,TST_DIS                ; Bit is set if its a Time Out
                            000374
1012      P:000374 P:000374 0A8A89  TST_DIS   JCLR    #TDIS,X:DPSR,TST_TAB              ; Bit is set if its a Target Disconnect
                            000376
1013      P:000376 P:000376 0A8A88  TST_TAB   JCLR    #TAB,X:DPSR,TST_MAB               ; Bit is set if its a Target Abort
                            000378
1014      P:000378 P:000378 0A8A87  TST_MAB   JCLR    #MAB,X:DPSR,ERROR                 ; Bit is set if its a Master Abort
                            0003D3
1015   
1016      P:00037A P:00037A 00000C            RTS
1017   
1018                                ; ***** Test Data Link, Read Memory and Write Memory Commands ******
1019   
1020                                ; Test the data link by echoing back ARG1
1021                                TEST_DATA_LINK
1022      P:00037B P:00037B 44B200            MOVE              X:<ARG1,X0
1023      P:00037C P:00037C 0C03CF            JMP     <FINISH1
1024   
1025                                ; Read from PCI memory. The address is masked to 16 bits, so only
1026                                ;   the bottom 64k words of DRAM will be accessed.
1027                                READ_MEMORY
1028      P:00037D P:00037D 56B200            MOVE              X:<ARG1,A               ; Get the address in an accumulator
1029      P:00037E P:00037E 0140C6            AND     #$FFFF,A                          ; Mask off only 16 address bits
                            00FFFF
1030      P:000380 P:000380 219000            MOVE              A1,R0                   ; Get the address in an address register
1031      P:000381 P:000381 56B200            MOVE              X:<ARG1,A               ; Get the address in an accumulator
1032      P:000382 P:000382 000000            NOP
1033      P:000383 P:000383 0ACE14            JCLR    #20,A,RDX                         ; Test address bit for Program memory
                            000387
1034      P:000385 P:000385 07E084            MOVE              P:(R0),X0               ; Read from Program Memory
1035      P:000386 P:000386 0C03CF            JMP     <FINISH1                          ; Send out a header with the value
1036      P:000387 P:000387 0ACE15  RDX       JCLR    #21,A,RDY                         ; Test address bit for X: memory
                            00038B
1037      P:000389 P:000389 44E000            MOVE              X:(R0),X0               ; Write to X data memory
1038      P:00038A P:00038A 0C03CF            JMP     <FINISH1                          ; Send out a header with the value
1039      P:00038B P:00038B 0ACE16  RDY       JCLR    #22,A,RDR                         ; Test address bit for Y: memory
                            00038F
1040      P:00038D P:00038D 4CE000            MOVE                          Y:(R0),X0   ; Read from Y data memory
1041      P:00038E P:00038E 0C03CF            JMP     <FINISH1                          ; Send out a header with the value
1042      P:00038F P:00038F 0ACE17  RDR       JCLR    #23,A,ERROR                       ; Test address bit for read from EEPROM memo
ry
                            0003D3
1043   
1044                                ; Read the word from the PCI board EEPROM
1045      P:000391 P:000391 08F4BB            MOVEP             #$0202A0,X:BCR          ; Bus Control Register for slow EEPROM
                            0202A0
1046      P:000393 P:000393 458300            MOVE              X:<THREE,X1             ; Convert to word address to a byte address
1047      P:000394 P:000394 220400            MOVE              R0,X0                   ; Get 16-bit address in a data register
1048      P:000395 P:000395 2000A0            MPY     X1,X0,A                           ; Multiply
1049      P:000396 P:000396 200022            ASR     A                                 ; Eliminate zero fill of fractional multiply
1050      P:000397 P:000397 211000            MOVE              A0,R0                   ; Need to address memory
1051      P:000398 P:000398 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
1052      P:000399 P:000399 060380            DO      #3,L1RDR
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 21



                            00039D
1053      P:00039B P:00039B 07D88A            MOVE              P:(R0)+,A2              ; Read each ROM byte
1054      P:00039C P:00039C 0C1C10            ASR     #8,A,A                            ; Move right into A1
1055      P:00039D P:00039D 000000            NOP
1056                                L1RDR
1057      P:00039E P:00039E 218400            MOVE              A1,X0                   ; Prepare for FINISH1
1058      P:00039F P:00039F 08F4BB            MOVEP             #$020022,X:BCR          ; Restore fast FIFO access
                            020022
1059      P:0003A1 P:0003A1 0C03CF            JMP     <FINISH1
1060   
1061                                ; Program WRMEM - write to PCI memory, reply = DONE host flags. The address is
1062                                ;  masked to 16 bits, so only the bottom 64k words of DRAM will be accessed.
1063                                WRITE_MEMORY
1064      P:0003A2 P:0003A2 56B200            MOVE              X:<ARG1,A               ; Get the address in an accumulator
1065      P:0003A3 P:0003A3 0140C6            AND     #$FFFF,A                          ; Mask off only 16 address bits
                            00FFFF
1066      P:0003A5 P:0003A5 219000            MOVE              A1,R0                   ; Get the address in an address register
1067      P:0003A6 P:0003A6 56B200            MOVE              X:<ARG1,A               ; Get the address in an accumulator
1068      P:0003A7 P:0003A7 44B300            MOVE              X:<ARG2,X0              ; Get the data to be written
1069      P:0003A8 P:0003A8 0ACE14            JCLR    #20,A,WRX                         ; Test address bit for Program memory
                            0003AC
1070      P:0003AA P:0003AA 076084            MOVE              X0,P:(R0)               ; Write to Program memory
1071      P:0003AB P:0003AB 0C03CC            JMP     <FINISH
1072      P:0003AC P:0003AC 0ACE15  WRX       JCLR    #21,A,WRY                         ; Test address bit for X: memory
                            0003B0
1073      P:0003AE P:0003AE 446000            MOVE              X0,X:(R0)               ; Write to X: memory
1074      P:0003AF P:0003AF 0C03CC            JMP     <FINISH
1075      P:0003B0 P:0003B0 0ACE16  WRY       JCLR    #22,A,WRR                         ; Test address bit for Y: memory
                            0003B4
1076      P:0003B2 P:0003B2 4C6000            MOVE                          X0,Y:(R0)   ; Write to Y: memory
1077      P:0003B3 P:0003B3 0C03CC            JMP     <FINISH
1078      P:0003B4 P:0003B4 0ACE17  WRR       JCLR    #23,A,ERROR                       ; Test address bit for write to EEPROM
                            0003D3
1079   
1080                                ; Write the word to the on-board PCI EEPROM
1081      P:0003B6 P:0003B6 08F4BB            MOVEP             #$0202A0,X:BCR          ; Bus Control Register for slow EEPROM
                            0202A0
1082      P:0003B8 P:0003B8 458300            MOVE              X:<THREE,X1             ; Convert to word address to a byte address
1083      P:0003B9 P:0003B9 220400            MOVE              R0,X0                   ; Get 16-bit address in a data register
1084      P:0003BA P:0003BA 2000A0            MPY     X1,X0,A                           ; Multiply
1085      P:0003BB P:0003BB 200022            ASR     A                                 ; Eliminate zero fill of fractional multiply
1086      P:0003BC P:0003BC 211000            MOVE              A0,R0                   ; Need to address memory
1087      P:0003BD P:0003BD 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
1088      P:0003BE P:0003BE 56B300            MOVE              X:<ARG2,A               ; Get the data to be written, again
1089      P:0003BF P:0003BF 060380            DO      #3,L1WRR                          ; Loop over three bytes of the word
                            0003C8
1090      P:0003C1 P:0003C1 07588C            MOVE              A1,P:(R0)+              ; Write each EEPROM byte
1091      P:0003C2 P:0003C2 0C1C10            ASR     #8,A,A                            ; Move right one byte
1092      P:0003C3 P:0003C3 44F400            MOVE              #1000000,X0
                            0F4240
1093      P:0003C5 P:0003C5 06C400            DO      X0,L2WRR                          ; Delay by 10 millisec for EEPROM write
                            0003C7
1094      P:0003C7 P:0003C7 000000            NOP
1095                                L2WRR
1096      P:0003C8 P:0003C8 000000            NOP                                       ; DO loop nesting restriction
1097                                L1WRR
1098      P:0003C9 P:0003C9 08F4BB            MOVEP             #$020022,X:BCR          ; Restore fast FIFO access
                            020022
1099      P:0003CB P:0003CB 0C03CC            JMP     <FINISH
1100   
1101                                ;  ***** Subroutines for generating replies to command execution ******
1102                                ; Return from the interrupt with a reply = DONE host flags
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 22



1103      P:0003CC P:0003CC 448600  FINISH    MOVE              X:<FLAG_DONE,X0         ; Flag = 1 => Normal execution
1104      P:0003CD P:0003CD 441C00            MOVE              X0,X:<HOST_FLAG
1105      P:0003CE P:0003CE 0C03DC            JMP     <RTI_WRITE_HOST_FLAG
1106   
1107                                ; Return from the interrupt with value in (X1,X0)
1108      P:0003CF P:0003CF 441B00  FINISH1   MOVE              X0,X:<REPLY             ; Report value
1109      P:0003D0 P:0003D0 448700            MOVE              X:<FLAG_REPLY,X0        ; Flag = 2 => Reply with a value
1110      P:0003D1 P:0003D1 441C00            MOVE              X0,X:<HOST_FLAG
1111      P:0003D2 P:0003D2 0C03DC            JMP     <RTI_WRITE_HOST_FLAG
1112   
1113                                ; Routine for returning from the interrupt on an error
1114      P:0003D3 P:0003D3 448800  ERROR     MOVE              X:<FLAG_ERR,X0          ; Flag = 3 => Error value
1115      P:0003D4 P:0003D4 441C00            MOVE              X0,X:<HOST_FLAG
1116      P:0003D5 P:0003D5 0C03DC            JMP     <RTI_WRITE_HOST_FLAG
1117   
1118                                ; Routine for returning from the interrupt with a system reset
1119      P:0003D6 P:0003D6 448900  SYR       MOVE              X:<FLAG_SYR,X0          ; Flag = 4 => System reset
1120      P:0003D7 P:0003D7 441C00            MOVE              X0,X:<HOST_FLAG
1121      P:0003D8 P:0003D8 0C03DC            JMP     <RTI_WRITE_HOST_FLAG
1122   
1123                                ; Routine for returning a BUSY status from the controller
1124      P:0003D9 P:0003D9 448B00  BUSY      MOVE              X:<FLAG_BUSY,X0         ; Flag = 6 => Controller is busy
1125      P:0003DA P:0003DA 441C00            MOVE              X0,X:<HOST_FLAG
1126      P:0003DB P:0003DB 0C03DC            JMP     <RTI_WRITE_HOST_FLAG
1127   
1128                                ; Write X:<HOST_FLAG to the DCTR flag bits 5,4,3, as an interrupt
1129                                RTI_WRITE_HOST_FLAG
1130      P:0003DC P:0003DC 56F000            MOVE              X:DCTR,A
                            FFFFC5
1131      P:0003DE P:0003DE 449C00            MOVE              X:<HOST_FLAG,X0
1132      P:0003DF P:0003DF 0140C6            AND     #$FFFFC7,A                        ; Clear bits 5,4,3
                            FFFFC7
1133      P:0003E1 P:0003E1 000000            NOP
1134      P:0003E2 P:0003E2 200042            OR      X0,A                              ; Set flags appropriately
1135      P:0003E3 P:0003E3 000000            NOP
1136      P:0003E4 P:0003E4 567000            MOVE              A,X:DCTR
                            FFFFC5
1137      P:0003E6 P:0003E6 000004            RTI
1138   
1139                                ; Put the reply value into the transmitter FIFO
1140                                READ_REPLY_VALUE
1141      P:0003E7 P:0003E7 08F08D            MOVEP             X:REPLY,X:DTXS          ; DSP-to-host slave transmit
                            00001B
1142      P:0003E9 P:0003E9 000004            RTI
1143   
1144                                READ_REPLY_HEADER
1145      P:0003EA P:0003EA 44B000            MOVE              X:<HEADER,X0
1146      P:0003EB P:0003EB 0C03CF            JMP     <FINISH1
1147   
1148                                ; Clear the reply flags and receiver FIFO after a successful reply transaction,
1149                                ;   but leave the Read Image flags set if the controller is reading out.
1150                                CLEAR_HOST_FLAG
1151      P:0003EC P:0003EC 448500            MOVE              X:<FLAG_ZERO,X0
1152      P:0003ED P:0003ED 441C00            MOVE              X0,X:<HOST_FLAG
1153      P:0003EE P:0003EE 44F400            MOVE              #$FFFFC7,X0
                            FFFFC7
1154      P:0003F0 P:0003F0 56F000            MOVE              X:DCTR,A
                            FFFFC5
1155      P:0003F2 P:0003F2 200046            AND     X0,A
1156      P:0003F3 P:0003F3 000000            NOP
1157      P:0003F4 P:0003F4 547000            MOVE              A1,X:DCTR
                            FFFFC5
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 23



1158   
1159      P:0003F6 P:0003F6 0A8982  CLR_RCV   JCLR    #SRRQ,X:DSR,CLR_RTS               ; Wait for the receiver to be empty
                            0003FB
1160      P:0003F8 P:0003F8 08440B            MOVEP             X:DRXR,X0               ; Read receiver to empty it
1161      P:0003F9 P:0003F9 000000            NOP                                       ; Wait for flag to change
1162      P:0003FA P:0003FA 0C03F6            JMP     <CLR_RCV
1163                                CLR_RTS
1164      P:0003FB P:0003FB 000004            RTI
1165   
1166                                ; *************  Miscellaneous subroutines used everywhere  *************
1167   
1168                                ; 250 MHz code - Transmit contents of Accumulator A1 to the timing board.
1169      P:0003FC P:0003FC 507000  XMT_WRD   MOVE              A0,X:SV_A0              ; Save registers used in XMT_WRD
                            000020
1170      P:0003FE P:0003FE 547000            MOVE              A1,X:SV_A1
                            000021
1171      P:000400 P:000400 527000            MOVE              A2,X:SV_A2
                            000022
1172      P:000402 P:000402 457000            MOVE              X1,X:SV_X1
                            000024
1173      P:000404 P:000404 447000            MOVE              X0,X:SV_X0
                            000023
1174      P:000406 P:000406 477000            MOVE              Y1,X:SV_Y1
                            000026
1175      P:000408 P:000408 467000            MOVE              Y0,X:SV_Y0
                            000025
1176      P:00040A P:00040A 47F400            MOVE              #$1000AC,Y1
                            1000AC
1177      P:00040C P:00040C 0C1D10            ASL     #8,A,A
1178      P:00040D P:00040D 60F400            MOVE              #$FFF000,R0             ; Memory mapped address of transmitter
                            FFF000
1179      P:00040F P:00040F 214600            MOVE              A2,Y0
1180      P:000410 P:000410 0C1D10            ASL     #8,A,A
1181      P:000411 P:000411 000000            NOP
1182      P:000412 P:000412 214500            MOVE              A2,X1
1183      P:000413 P:000413 0C1D10            ASL     #8,A,A
1184      P:000414 P:000414 000000            NOP
1185      P:000415 P:000415 214400            MOVE              A2,X0
1186      P:000416 P:000416 476000            MOVE              Y1,X:(R0)               ; Header = $AC
1187      P:000417 P:000417 466000            MOVE              Y0,X:(R0)               ; MS Byte
1188      P:000418 P:000418 456000            MOVE              X1,X:(R0)               ; Middle byte
1189      P:000419 P:000419 446000            MOVE              X0,X:(R0)               ; LS byte
1190      P:00041A P:00041A 507000            MOVE              A0,X:SV_A0
                            000020
1191      P:00041C P:00041C 547000            MOVE              A1,X:SV_A1
                            000021
1192      P:00041E P:00041E 527000            MOVE              A2,X:SV_A2
                            000022
1193      P:000420 P:000420 45F000            MOVE              X:SV_X1,X1              ; Restore registers used here
                            000024
1194      P:000422 P:000422 44F000            MOVE              X:SV_X0,X0
                            000023
1195      P:000424 P:000424 47F000            MOVE              X:SV_Y1,Y1
                            000026
1196      P:000426 P:000426 46F000            MOVE              X:SV_Y0,Y0
                            000025
1197      P:000428 P:000428 00000C            RTS
1198   
1199                                ; Read one word of the fiber optic FIFO into B1 with a timeout
1200                                RD_FO_TIMEOUT
1201      P:000429 P:000429 46F400            MOVE              #1000000,Y0             ; 13 millisecond timeout
                            0F4240
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 24



1202      P:00042B P:00042B 06C600            DO      Y0,LP_TIM
                            000435
1203      P:00042D P:00042D 01AD80            JCLR    #EF,X:PDRD,NOT_YET                ; Test for new fiber optic data
                            000435
1204      P:00042F P:00042F 000000            NOP
1205      P:000430 P:000430 000000            NOP
1206      P:000431 P:000431 01AD80            JCLR    #EF,X:PDRD,NOT_YET                ; For metastability, check it twice
                            000435
1207      P:000433 P:000433 00008C            ENDDO
1208      P:000434 P:000434 0C043A            JMP     <RD_FIFO                          ; Go read the FIFO word
1209      P:000435 P:000435 000000  NOT_YET   NOP
1210      P:000436 P:000436 000000  LP_TIM    NOP
1211      P:000437 P:000437 0AF960            BSET    #0,SR                             ; Timeout reached, error return
1212      P:000438 P:000438 000000            NOP
1213      P:000439 P:000439 00000C            RTS
1214   
1215                                ; Read one word from the fiber optics FIFO, check it and put it in B1
1216      P:00043A P:00043A 09463F  RD_FIFO   MOVEP             Y:RDFIFO,Y0             ; Read the FIFO word
1217      P:00043B P:00043B 578D00            MOVE              X:<C00FF00,B            ; DMASK = $00FF00
1218      P:00043C P:00043C 20005E            AND     Y0,B
1219      P:00043D P:00043D 0140CD            CMP     #$00AC00,B
                            00AC00
1220      P:00043F P:00043F 0EA44C            JEQ     <GT_RPLY                          ; If byte equalS $AC then continue
1221      P:000440 P:000440 07F42D            MOVEP             #%011000,X:PDRD         ; Clear RS* low for 2 milliseconds
                            000018
1222      P:000442 P:000442 47F400            MOVE              #200000,Y1
                            030D40
1223      P:000444 P:000444 06C700            DO      Y1,*+3
                            000446
1224      P:000446 P:000446 000000            NOP
1225      P:000447 P:000447 07F42D            MOVEP             #%011100,X:PDRD         ; Data Register - Set RS* high
                            00001C
1226      P:000449 P:000449 0AF960            BSET    #0,SR                             ; Set carry bit => error
1227      P:00044A P:00044A 000000            NOP
1228      P:00044B P:00044B 00000C            RTS
1229   
1230      P:00044C P:00044C 20CF00  GT_RPLY   MOVE              Y0,B
1231      P:00044D P:00044D 0C1EA1            LSL     #16,B                             ; Shift byte in D7-D0 to D23-D16
1232      P:00044E P:00044E 000000            NOP
1233      P:00044F P:00044F 21A700            MOVE              B1,Y1
1234      P:000450 P:000450 4EF000            MOVE                          Y:RDFIFO,Y0 ; Read the FIFO word
                            FFFFFF
1235      P:000452 P:000452 57F400            MOVE              #$00FFFF,B
                            00FFFF
1236      P:000454 P:000454 20005E            AND     Y0,B                              ; Select out D15-D0
1237      P:000455 P:000455 20007A            OR      Y1,B                              ; Add D23-D16 to D15-D0
1238      P:000456 P:000456 000000            NOP
1239      P:000457 P:000457 000000            NOP
1240      P:000458 P:000458 0AF940            BCLR    #0,SR                             ; Clear carry bit => no error
1241      P:000459 P:000459 000000            NOP
1242      P:00045A P:00045A 00000C            RTS
1243   
1244                                ; This might work with some effort
1245                                ;GT_RPLY        MOVE    Y:RDFIFO,B              ; Read the FIFO word
1246                                ;       EXTRACTU #$010018,B,B
1247                                ;       INSERT  #$008000,Y0,B           ; Add MSB to D23-D16
1248                                ;       NOP
1249                                ;       MOVE    B0,B1
1250                                ;       NOP
1251                                ;       NOP
1252                                ;       BCLR    #0,SR                   ; Clear carry bit => no error
1253                                ;       NOP
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 25



1254                                ;       RTS
1255   
1256                                ; ************************  Test on board DRAM  ***********************
1257                                ; Test Y: memory mapped to AA0 from $000000 to $7FFFFF (8 megapixels)
1258                                ; DRAM definitions
1259   
1260                                TEST_DRAM
1261   
1262                                ; Test Y: is memory mapped to AA2 from $000800 to $7FFFFF (8 megapixels)
1263      P:00045B P:00045B 20001B            CLR     B
1264      P:00045C P:00045C 270100            MOVE              #$10000,Y1
1265      P:00045D P:00045D 21F000            MOVE              B,R0
1266      P:00045E P:00045E 068080            DO      #$80,L_WRITE_RAM1
                            000466
1267      P:000460 P:000460 0D047B            JSR     <TRM_BUSY                         ; 'TRM' is still busy
1268      P:000461 P:000461 06C700            DO      Y1,L_WRITE_RAM0
                            000465
1269      P:000463 P:000463 5D5800            MOVE                          B1,Y:(R0)+
1270      P:000464 P:000464 014388            ADD     #3,B
1271      P:000465 P:000465 000000            NOP
1272                                L_WRITE_RAM0
1273      P:000466 P:000466 000000            NOP
1274                                L_WRITE_RAM1
1275   
1276      P:000467 P:000467 20001B            CLR     B
1277      P:000468 P:000468 270100            MOVE              #$10000,Y1
1278      P:000469 P:000469 21F000            MOVE              B,R0
1279      P:00046A P:00046A 068080            DO      #$80,L_CHECK_RAM1
                            000477
1280      P:00046C P:00046C 0D047B            JSR     <TRM_BUSY                         ; 'TRM' is still busy
1281      P:00046D P:00046D 06C700            DO      Y1,L_CHECK_RAM0
                            000476
1282      P:00046F P:00046F 4DD800            MOVE                          Y:(R0)+,X1
1283      P:000470 P:000470 0C1FFD            CMPU    X1,B
1284      P:000471 P:000471 0EA475            JEQ     <L_RAM4
1285      P:000472 P:000472 00008C            ENDDO
1286      P:000473 P:000473 00008C            ENDDO
1287      P:000474 P:000474 0C0479            JMP     <ERROR_Y
1288      P:000475 P:000475 014388  L_RAM4    ADD     #3,B
1289      P:000476 P:000476 000000            NOP
1290                                L_CHECK_RAM0
1291      P:000477 P:000477 000000            NOP
1292                                L_CHECK_RAM1
1293   
1294      P:000478 P:000478 0C03CC            JMP     <FINISH
1295   
1296      P:000479 P:000479 601000  ERROR_Y   MOVE              R0,X:<TRM_ADR
1297      P:00047A P:00047A 0C03D3            JMP     <ERROR
1298   
1299                                TRM_BUSY
1300      P:00047B P:00047B 552100            MOVE              B1,X:<SV_A1             ; FO_WRITE_HOST_FLAG uses B
1301      P:00047C P:00047C 468B00            MOVE              X:<FLAG_BUSY,Y0         ; Flag = 6 => controller busy
1302      P:00047D P:00047D 461C00            MOVE              Y0,X:<HOST_FLAG
1303      P:00047E P:00047E 0D0175            JSR     <FO_WRITE_HOST_FLAG
1304      P:00047F P:00047F 55A100            MOVE              X:<SV_A1,B1
1305      P:000480 P:000480 00000C            RTS
1306   
1307                                ;  ****************  Setup memory tables in X: space ********************
1308   
1309                                ; Define the address in P: space where the table of constants begins
1310   
1311      X:000000 P:000481                   ORG     X:VAR_TBL,P:
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 26



1312   
1313                                ; Parameters
1314      X:000000 P:000481         STATUS    DC      0                                 ; Execution status bits
1315      X:000001 P:000482                   DC      0                                 ; Reserved
1316   
1317                                          IF      @SCP("HOST","HOST")               ; Download via host computer
1318                                 CONSTANTS_TBL_START
1319      000483                              EQU     @LCV(L)
1320                                          ENDIF
1321   
1322                                          IF      @SCP("HOST","ROM")                ; Boot ROM code
1324                                          ENDIF
1325   
1326                                          IF      @SCP("HOST","ONCE")               ; Download via ONCE debugger
1328                                          ENDIF
1329   
1330                                ; Parameter table in P: space to be copied into X: space during
1331                                ;   initialization, and must be copied from ROM in the boot process
1332      X:000002 P:000483         ONE       DC      1                                 ; One
1333      X:000003 P:000484         THREE     DC      3                                 ; Three
1334      X:000004 P:000485         FOUR      DC      4                                 ; Four
1335   
1336                                ; Host flags are bits 5,4,3 of the HSTR
1337      X:000005 P:000486         FLAG_ZERO DC      0                                 ; Flag = 0 => command is still executing
1338      X:000006 P:000487         FLAG_DONE DC      $000008                           ; Flag = 1 => DONE
1339      X:000007 P:000488         FLAG_REPLY DC     $000010                           ; Flag = 2 => reply value available
1340      X:000008 P:000489         FLAG_ERR  DC      $000018                           ; Flag = 3 => error
1341      X:000009 P:00048A         FLAG_SYR  DC      $000020                           ; Flag = 4 => controller reset
1342      X:00000A P:00048B         FLAG_RDI  DC      $000028                           ; Flag = 5 => reading out image
1343      X:00000B P:00048C         FLAG_BUSY DC      $000030                           ; Flag = 6 => controller is busy
1344      X:00000C P:00048D         C512      DC      512                               ; 1/2 the FIFO size
1345      X:00000D P:00048E         C00FF00   DC      $00FF00
1346      X:00000E P:00048F         C000202   DC      $000202                           ; Timing board header
1347      X:00000F P:000490         TRM_MEM   DC      0                                 ; Test DRAM, memory type of failure
1348      X:000010 P:000491         TRM_ADR   DC      0                                 ; Test DRAM, address of failure
1349   
1350                                ; Tack the length of the variable table onto the length of code to be booted
1351                                 CONSTANTS_TBL_LENGTH
1352      00000F                              EQU     @CVS(P,*-ONE)                     ; Length of variable table
1353   
1354                                ; Ending address of program so its length can be calculated for bootstrapping
1355                                ; The constants defined after this are NOT initialized, so need not be
1356                                ;    downloaded.
1357   
1358      000492                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
1359   
1360                                ; Miscellaneous variables
1361                                 BASE_ADDR_1
1362      X:000011 P:000492                   DC      0                                 ; Starting PCI address of image, MS byte
1363                                 BASE_ADDR_0
1364      X:000012 P:000493                   DC      0                                 ; Starting PCI address of image, LS 24-bits
1365      X:000013 P:000494         PCI_ADDR_1 DC     0                                 ; Current PCI address of image, MS byte
1366      X:000014 P:000495         PCI_ADDR_0 DC     0                                 ; Current PCI address of image, LS 24-bits
1367      X:000015 P:000496         NPXLS_1   DC      0                                 ; # of pxls in current READ_IMAGE call, MS b
yte
1368      X:000016 P:000497         NPXLS_0   DC      0                                 ; # of pxls in current READ_IMAGE, LS 24-bit
s
1369      X:000017 P:000498         IPXLS_1   DC      0                                 ; Up pixel counter, MS byte
1370      X:000018 P:000499         IPXLS_0   DC      0                                 ; Up pixel counter, 24-bits
1371      X:000019 P:00049A         R_PXLS_1  DC      0                                 ; Up pixel counter, MS 16-bits
1372      X:00001A P:00049B         R_PXLS_0  DC      0                                 ; Up pixel counter, LS 16-bits
1373      X:00001B P:00049C         REPLY     DC      0                                 ; Reply value
Motorola DSP56300 Assembler  Version 6.3.4   10-01-21  10:05:15  pci3boot.asm  Page 27



1374      X:00001C P:00049D         HOST_FLAG DC      0                                 ; Value of host flags written to X:DCTR
1375      X:00001D P:00049E         FO_DEST   DC      0                                 ; Whether host or PCI board receives command
1376      X:00001E P:00049F         FO_CMD    DC      0                                 ; Fiber optic command or reply
1377      X:00001F P:0004A0         SV_DPMC   DC      0                                 ; Save register
1378      X:000020 P:0004A1         SV_A0     DC      0                                 ; Place for saving accumulator A
1379      X:000021 P:0004A2         SV_A1     DC      0                                 ; Accumulator A in interrupt service routine
1380      X:000022 P:0004A3         SV_A2     DC      0
1381      X:000023 P:0004A4         SV_X0     DC      0                                 ; Save location for data register X
1382      X:000024 P:0004A5         SV_X1     DC      0
1383      X:000025 P:0004A6         SV_Y0     DC      0                                 ; Save location for data register Y
1384      X:000026 P:0004A7         SV_Y1     DC      0
1385   
1386                                ; Check that the parameter table is not too big
1387                                          IF      @CVS(N,*)>=ARG_TBL
1389                                          ENDIF
1390   
1391      X:000030 P:0004A8                   ORG     X:ARG_TBL,P:
1392   
1393                                ; Table that contains the header, command and its arguments
1394      X:000030 P:0004A8         HEADER    DC      0                                 ; (Source, Destination, Number of words)
1395      X:000031 P:0004A9         COMMAND   DC      0                                 ; Manual command
1396      X:000032 P:0004AA         ARG1      DC      0                                 ; First command argument
1397      X:000033 P:0004AB         ARG2      DC      0                                 ; Second command argument
1398                                 DESTINATION
1399      X:000034 P:0004AC                   DC      0                                 ; Derived from header
1400      X:000035 P:0004AD         NUM_ARG   DC      0                                 ; Derived from header
1401   
1402      Y:000000 P:0004AE                   ORG     Y:0,P:
1403   
1404                                ; This must be the LAST constant definition, because it is a large table
1405                                 IMAGE_BUFER
1406      Y:000000 P:0004AE                   DC      0                                 ; Copy image data from FIFO to here
1407   
1408                                ; End of program
1409                                          END

0    Errors
0    Warnings


