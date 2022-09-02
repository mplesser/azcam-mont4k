Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 1



1                          ; ARC22.asm
2      
3                          ; This file is used to generate DSP code for the 250 MHz fiber optic
4                          ; ARC22 timing board using a DSP56303 as its main processor.
5      
6                          ; This version is for SPUD.
7                          ; 19Sep12 last change MPL
8      
9                                    PAGE    132                               ; Printronix page width - 132 columns
10     
11                         ; *** include header,  boot code, and board configuration files ***
12                                   INCLUDE "ARC22_hdr.asm"
13                                COMMENT *
14     
15                         timhdr.asm for ARC22 timing code
16     
17                         This is a header file that is shared between the fiber optic timing board
18                         boot and application code files for Rev. 5 = 250 MHz timing boards
19     
20                         Utility board support version
21     
22                         Last change 29Oct06 MPL
23     
24                                 *
25     
26                                   PAGE    132                               ; Printronix page width - 132 columns
27     
28                         ; Various addressing control registers
29        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
30        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
31        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
32        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
33        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
34        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
35        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
36        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
37     
38                         ; Port E is the Synchronous Communications Interface (SCI) port
39        FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
40        FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
41        FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
42        FFFF9C           SCR       EQU     $FFFF9C                           ; SCI Control Register
43        FFFF9B           SCCR      EQU     $FFFF9B                           ; SCI Clock Control Register
44     
45        FFFF9A           SRXH      EQU     $FFFF9A                           ; SCI Receive Data Register, High byte
46        FFFF99           SRXM      EQU     $FFFF99                           ; SCI Receive Data Register, Middle byte
47        FFFF98           SRXL      EQU     $FFFF98                           ; SCI Receive Data Register, Low byte
48     
49        FFFF97           STXH      EQU     $FFFF97                           ; SCI Transmit Data register, High byte
50        FFFF96           STXM      EQU     $FFFF96                           ; SCI Transmit Data register, Middle byte
51        FFFF95           STXL      EQU     $FFFF95                           ; SCI Transmit Data register, Low byte
52     
53        FFFF94           STXA      EQU     $FFFF94                           ; SCI Transmit Address Register
54        FFFF93           SSR       EQU     $FFFF93                           ; SCI Status Register
55     
56        000009           SCITE     EQU     9                                 ; X:SCR bit set to enable the SCI transmitter
57        000008           SCIRE     EQU     8                                 ; X:SCR bit set to enable the SCI receiver
58        000000           TRNE      EQU     0                                 ; This is set in X:SSR when the transmitter
59                                                                             ;  shift and data registers are both empty
60        000001           TDRE      EQU     1                                 ; This is set in X:SSR when the transmitter
61                                                                             ;  data register is empty
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_hdr.asm  Page 2



62        000002           RDRF      EQU     2                                 ; X:SSR bit set when receiver register is full
63        00000F           SELSCI    EQU     15                                ; 1 for SCI to backplane, 0 to front connector
64     
65     
66                         ; ESSI Flags
67        000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
68        000007           RDF       EQU     7                                 ; Set when receiver is full of data
69        000010           TE        EQU     16                                ; Transmitter enable
70     
71                         ; Phase Locked Loop initialization
72        050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 2 = 100 MHz
73     
74                         ; Port B general purpose I/O
75        FFFFC4           HPCR      EQU     $FFFFC4                           ; Control register (bits 1-6 cleared for GPIO)
76        FFFFC9           HDR       EQU     $FFFFC9                           ; Data register
77        FFFFC8           HDDR      EQU     $FFFFC8                           ; Data Direction Register bits (=1 for output)
78     
79                         ; Port C is Enhanced Synchronous Serial Port 0 = ESSI0
80        FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
81        FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
82        FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
83        FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register #0
84        FFFFB8           RX0       EQU     $FFFFB8                           ; Receive data register
85        FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
86        FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
87        FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
88     
89                         ; Port D is Enhanced Synchronous Serial Port 1 = ESSI1
90        FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
91        FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
92        FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
93        FFFFAC           TX10      EQU     $FFFFAC                           ; Transmit Data Register 0
94        FFFFA7           SSISR1    EQU     $FFFFA7                           ; Status Register
95        FFFFA6           CRB1      EQU     $FFFFA6                           ; Control Register B
96        FFFFA5           CRA1      EQU     $FFFFA5                           ; Control Register A
97     
98                         ; Timer module addresses
99        FFFF8F           TCSR0     EQU     $FFFF8F                           ; Timer control and status register
100       FFFF8E           TLR0      EQU     $FFFF8E                           ; Timer load register = 0
101       FFFF8D           TCPR0     EQU     $FFFF8D                           ; Timer compare register = exposure time
102       FFFF8C           TCR0      EQU     $FFFF8C                           ; Timer count register = elapsed time
103       FFFF83           TPLR      EQU     $FFFF83                           ; Timer prescaler load register => milliseconds
104       FFFF82           TPCR      EQU     $FFFF82                           ; Timer prescaler count register
105       000000           TIM_BIT   EQU     0                                 ; Set to enable the timer
106       000009           TRM       EQU     9                                 ; Set to enable the timer preloading
107       000015           TCF       EQU     21                                ; Set when timer counter = compare register
108    
109                        ; Board specific addresses and constants
110       FFFFF1           RDFO      EQU     $FFFFF1                           ; Read incoming fiber optic data byte
111       FFFFF2           WRFO      EQU     $FFFFF2                           ; Write fiber optic data replies
112       FFFFF3           WRSS      EQU     $FFFFF3                           ; Write switch state
113       FFFFF5           WRLATCH   EQU     $FFFFF5                           ; Write to a latch
114       010000           RDAD      EQU     $010000                           ; Read A/D values into the DSP
115       000009           EF        EQU     9                                 ; Serial receiver empty flag
116    
117                        ; DSP port A bit equates
118       000000           PWROK     EQU     0                                 ; Power control board says power is OK
119       000001           LED1      EQU     1                                 ; Control one of two LEDs
120       000002           LVEN      EQU     2                                 ; Low voltage power enable
121       000003           HVEN      EQU     3                                 ; High voltage power enable
122       00000E           SSFHF     EQU     14                                ; Switch state FIFO half full flag
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_hdr.asm  Page 3



123    
124                        ; Port D equate
125       000001           SSFEF     EQU     1                                 ; Switch state FIFO empty flag
126    
127                        ; Other equates
128       000002           WRENA     EQU     2                                 ; Enable writing to the EEPROM
129    
130                        ; Latch U12 bit equates
131       000000           CDAC      EQU     0                                 ; Clear the analog board DACs
132       000002           ENCK      EQU     2                                 ; Enable the clock outputs
133       000004           SHUTTER   EQU     4                                 ; Control the shutter
134       000005           TIM_U_RST EQU     5                                 ; Reset the utility board
135    
136                        ; Software status bits, defined at X:<STATUS = X:0
137       000000           ST_RCV    EQU     0                                 ; Set to indicate word is from SCI = utility board
138       000002           IDLMODE   EQU     2                                 ; Set if need to idle after readout
139       000003           ST_SHUT   EQU     3                                 ; Set to indicate shutter is closed, clear for open
140       000004           ST_RDC    EQU     4                                 ; Set if executing 'RDC' command - reading out
141       000005           SPLIT_S   EQU     5                                 ; Set if split serial
142       000006           SPLIT_P   EQU     6                                 ; Set if split parallel
143       000007           MPPMODE   EQU     7                                 ; Set if parallels are in MPP mode - MPL
144       000008           NOT_CLR   EQU     8                                 ; Set if not to clear CCD before exposure
145       00000A           TST_IMG   EQU     10                                ; Set if controller is to generate a test image
146       00000B           SHUT      EQU     11                                ; Set if opening shutter at beginning of exposure
147       00000C           ST_DITH   EQU     12                                ; Set if to dither during exposure
148       00000D           NOREAD    EQU     13                                ; Set if not to call RDCCD after expose MPL
149    
150                        ; Address for the table containing the incoming SCI words
151       000400           SCI_TABLE EQU     $400
152                                  INCLUDE "ARC22_boot.asm"
153                               COMMENT *
154    
155                        This file is used to generate boot DSP code for the 250 MHz fiber optic timing board
156                        using a DSP56303 as its main processor.
157    
158                        21Jun12 last change MPL - ST_DITH OFF
159                        Added utility board support Dec. 2002
160    
161                                *
162    
163                                  PAGE    132                               ; Printronix page width - 132 columns
164    
165                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
166                                  IF      @SCP("HOST","ROM")
173                                  ENDIF
174    
175                                  IF      @SCP("HOST","HOST")
176       P:000000 P:000000                   ORG     P:0,P:0
177       P:000000 P:000000 0C018E            JMP     <INIT
178       P:000001 P:000001 000000            NOP
179                                           ENDIF
180    
181                                 ;  This ISR receives serial words a byte at a time over the asynchronous
182                                 ;    serial link (SCI) and squashes them into a single 24-bit word
183       P:000002 P:000002 602400  SCI_RCV   MOVE              R0,X:<SAVE_R0           ; Save R0
184       P:000003 P:000003 052139            MOVEC             SR,X:<SAVE_SR           ; Save Status Register
185       P:000004 P:000004 60A700            MOVE              X:<SCI_R0,R0            ; Restore R0 = pointer to SCI receive regist
er
186       P:000005 P:000005 542300            MOVE              A1,X:<SAVE_A1           ; Save A1
187       P:000006 P:000006 452200            MOVE              X1,X:<SAVE_X1           ; Save X1
188       P:000007 P:000007 54A600            MOVE              X:<SCI_A1,A1            ; Get SRX value of accumulator contents
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 4



189       P:000008 P:000008 45E000            MOVE              X:(R0),X1               ; Get the SCI byte
190       P:000009 P:000009 0AD041            BCLR    #1,R0                             ; Test for the address being $FFF6 = last by
te
191       P:00000A P:00000A 000000            NOP
192       P:00000B P:00000B 000000            NOP
193       P:00000C P:00000C 000000            NOP
194       P:00000D P:00000D 205862            OR      X1,A      (R0)+                   ; Add the byte into the 24-bit word
195       P:00000E P:00000E 0E0013            JCC     <MID_BYT                          ; Not the last byte => only restore register
s
196       P:00000F P:00000F 545C00  END_BYT   MOVE              A1,X:(R4)+              ; Put the 24-bit word into the SCI buffer
197       P:000010 P:000010 60F400            MOVE              #SRXL,R0                ; Re-establish first address of SCI interfac
e
                            FFFF98
198       P:000012 P:000012 2C0000            MOVE              #0,A1                   ; For zeroing out SCI_A1
199       P:000013 P:000013 602700  MID_BYT   MOVE              R0,X:<SCI_R0            ; Save the SCI receiver address
200       P:000014 P:000014 542600            MOVE              A1,X:<SCI_A1            ; Save A1 for next interrupt
201       P:000015 P:000015 05A139            MOVEC             X:<SAVE_SR,SR           ; Restore Status Register
202       P:000016 P:000016 54A300            MOVE              X:<SAVE_A1,A1           ; Restore A1
203       P:000017 P:000017 45A200            MOVE              X:<SAVE_X1,X1           ; Restore X1
204       P:000018 P:000018 60A400            MOVE              X:<SAVE_R0,R0           ; Restore R0
205       P:000019 P:000019 000004            RTI                                       ; Return from interrupt service
206    
207                                 ; Clear error condition and interrupt on SCI receiver
208       P:00001A P:00001A 077013  CLR_ERR   MOVEP             X:SSR,X:RCV_ERR         ; Read SCI status register
                            000025
209       P:00001C P:00001C 077018            MOVEP             X:SRXL,X:RCV_ERR        ; This clears any error
                            000025
210       P:00001E P:00001E 000004            RTI
211    
212       P:00001F P:00001F                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
213       P:000030 P:000030                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
214       P:000040 P:000040                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
215    
216                                 ; Tune the table so the following instruction is at P:$50 exactly.
217       P:000050 P:000050 0D0002            JSR     SCI_RCV                           ; SCI receive data interrupt
218       P:000051 P:000051 000000            NOP
219       P:000052 P:000052 0D001A            JSR     CLR_ERR                           ; SCI receive error interrupt
220       P:000053 P:000053 000000            NOP
221    
222                                 ; *******************  Command Processing  ******************
223    
224                                 ; Read the header and check it for self-consistency
225       P:000054 P:000054 609F00  START     MOVE              X:<IDL_ADR,R0
226       P:000055 P:000055 018FA0            JSET    #TIM_BIT,X:TCSR0,CHK_TIM          ; MPL If exposing go check the timer
                            000373
227                                 ;       JSET    #ST_RDC,X:<STATUS,CONTINUE_READING
228       P:000057 P:000057 0AE080            JMP     (R0)
229    
230       P:000058 P:000058 330700  TST_RCV   MOVE              #<COM_BUF,R3
231       P:000059 P:000059 0D00A3            JSR     <GET_RCV
232       P:00005A P:00005A 0E0059            JCC     *-1
233    
234                                 ; Check the header and read all the remaining words in the command
235       P:00005B P:00005B 0C00FD  PRC_RCV   JMP     <CHK_HDR                          ; Update HEADER and NWORDS
236       P:00005C P:00005C 578600  PR_RCV    MOVE              X:<NWORDS,B             ; Read this many words total in the command
237       P:00005D P:00005D 000000            NOP
238       P:00005E P:00005E 01418C            SUB     #1,B                              ; We've already read the header
239       P:00005F P:00005F 000000            NOP
240       P:000060 P:000060 06CF00            DO      B,RD_COM
                            000068
241       P:000062 P:000062 205B00            MOVE              (R3)+                   ; Increment past what's been read already
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 5



242       P:000063 P:000063 0B0080  GET_WRD   JSCLR   #ST_RCV,X:STATUS,CHK_FO
                            0000A7
243       P:000065 P:000065 0B00A0            JSSET   #ST_RCV,X:STATUS,CHK_SCI
                            0000D3
244       P:000067 P:000067 0E0063            JCC     <GET_WRD
245       P:000068 P:000068 000000            NOP
246       P:000069 P:000069 330700  RD_COM    MOVE              #<COM_BUF,R3            ; Restore R3 = beginning of the command
247    
248                                 ; Is this command for the timing board?
249       P:00006A P:00006A 448500            MOVE              X:<HEADER,X0
250       P:00006B P:00006B 579B00            MOVE              X:<DMASK,B
251       P:00006C P:00006C 459A4E            AND     X0,B      X:<TIM_DRB,X1           ; Extract destination byte
252       P:00006D P:00006D 20006D            CMP     X1,B                              ; Does header = timing board number?
253       P:00006E P:00006E 0EA07E            JEQ     <COMMAND                          ; Yes, process it here
254       P:00006F P:00006F 0E909B            JLT     <FO_XMT                           ; Send it to fiber optic transmitter
255    
256                                 ; Transmit the command to the utility board over the SCI port
257       P:000070 P:000070 060600            DO      X:<NWORDS,DON_XMT                 ; Transmit NWORDS
                            00007C
258       P:000072 P:000072 60F400            MOVE              #STXL,R0                ; SCI first byte address
                            FFFF95
259       P:000074 P:000074 44DB00            MOVE              X:(R3)+,X0              ; Get the 24-bit word to transmit
260       P:000075 P:000075 060380            DO      #3,SCI_SPT
                            00007B
261       P:000077 P:000077 019381            JCLR    #TDRE,X:SSR,*                     ; Continue ONLY if SCI XMT is empty
                            000077
262       P:000079 P:000079 445800            MOVE              X0,X:(R0)+              ; Write to SCI, byte pointer + 1
263       P:00007A P:00007A 000000            NOP                                       ; Delay for the status flag to be set
264       P:00007B P:00007B 000000            NOP
265                                 SCI_SPT
266       P:00007C P:00007C 000000            NOP
267                                 DON_XMT
268       P:00007D P:00007D 0C0054            JMP     <START
269    
270                                 ; Process the receiver entry - is it in the command table ?
271       P:00007E P:00007E 0203DF  COMMAND   MOVE              X:(R3+1),B              ; Get the command
272       P:00007F P:00007F 205B00            MOVE              (R3)+
273       P:000080 P:000080 205B00            MOVE              (R3)+                   ; Point R3 to the first argument
274       P:000081 P:000081 302800            MOVE              #<COM_TBL,R0            ; Get the command table starting address
275       P:000082 P:000082 061E80            DO      #NUM_COM,END_COM                  ; Loop over the command table
                            000089
276       P:000084 P:000084 47D800            MOVE              X:(R0)+,Y1              ; Get the command table entry
277       P:000085 P:000085 62E07D            CMP     Y1,B      X:(R0),R2               ; Does receiver = table entries address?
278       P:000086 P:000086 0E2089            JNE     <NOT_COM                          ; No, keep looping
279       P:000087 P:000087 00008C            ENDDO                                     ; Restore the DO loop system registers
280       P:000088 P:000088 0AE280            JMP     (R2)                              ; Jump execution to the command
281       P:000089 P:000089 205800  NOT_COM   MOVE              (R0)+                   ; Increment the register past the table addr
ess
282                                 END_COM
283       P:00008A P:00008A 0C008B            JMP     <ERROR                            ; The command is not in the table
284    
285                                 ; It's not in the command table - send an error message
286       P:00008B P:00008B 479D00  ERROR     MOVE              X:<ERR,Y1               ; Send the message - there was an error
287       P:00008C P:00008C 0C008E            JMP     <FINISH1                          ; This protects against unknown commands
288    
289                                 ; Send a reply packet - header and reply
290       P:00008D P:00008D 479800  FINISH    MOVE              X:<DONE,Y1              ; Send 'DON' as the reply
291       P:00008E P:00008E 578500  FINISH1   MOVE              X:<HEADER,B             ; Get header of incoming command
292       P:00008F P:00008F 469C00            MOVE              X:<SMASK,Y0             ; This was the source byte, and is to
293       P:000090 P:000090 330700            MOVE              #<COM_BUF,R3            ;     become the destination byte
294       P:000091 P:000091 46935E            AND     Y0,B      X:<TWO,Y0
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 6



295       P:000092 P:000092 0C1ED1            LSR     #8,B                              ; Shift right eight bytes, add it to the
296       P:000093 P:000093 460600            MOVE              Y0,X:<NWORDS            ;     header, and put 2 as the number
297       P:000094 P:000094 469958            ADD     Y0,B      X:<SBRD,Y0              ;     of words in the string
298       P:000095 P:000095 200058            ADD     Y0,B                              ; Add source board's header, set Y1 for abov
e
299       P:000096 P:000096 000000            NOP
300       P:000097 P:000097 575B00            MOVE              B,X:(R3)+               ; Put the new header on the transmitter stac
k
301       P:000098 P:000098 475B00            MOVE              Y1,X:(R3)+              ; Put the argument on the transmitter stack
302       P:000099 P:000099 570500            MOVE              B,X:<HEADER
303       P:00009A P:00009A 0C0069            JMP     <RD_COM                           ; Decide where to send the reply, and do it
304    
305                                 ; Transmit words to the host computer over the fiber optics link
306       P:00009B P:00009B 63F400  FO_XMT    MOVE              #COM_BUF,R3
                            000007
307       P:00009D P:00009D 060600            DO      X:<NWORDS,DON_FFO                 ; Transmit all the words in the command
                            0000A1
308       P:00009F P:00009F 57DB00            MOVE              X:(R3)+,B
309       P:0000A0 P:0000A0 0D00E9            JSR     <XMT_WRD
310       P:0000A1 P:0000A1 000000            NOP
311       P:0000A2 P:0000A2 0C0054  DON_FFO   JMP     <START
312    
313                                 ; Check for commands from the fiber optic FIFO and the utility board (SCI)
314       P:0000A3 P:0000A3 0D00A7  GET_RCV   JSR     <CHK_FO                           ; Check for fiber optic command from FIFO
315       P:0000A4 P:0000A4 0E80A6            JCS     <RCV_RTS                          ; If there's a command, check the header
316       P:0000A5 P:0000A5 0D00D3            JSR     <CHK_SCI                          ; Check for an SCI command
317       P:0000A6 P:0000A6 00000C  RCV_RTS   RTS
318    
319                                 ; Because of FIFO metastability require that EF be stable for two tests
320       P:0000A7 P:0000A7 0A8989  CHK_FO    JCLR    #EF,X:HDR,TST2                    ; EF = Low,  Low  => CLR SR, return
                            0000AA
321       P:0000A9 P:0000A9 0C00AD            JMP     <TST3                             ;      High, Low  => try again
322       P:0000AA P:0000AA 0A8989  TST2      JCLR    #EF,X:HDR,CLR_CC                  ;      Low,  High => try again
                            0000CF
323       P:0000AC P:0000AC 0C00A7            JMP     <CHK_FO                           ;      High, High => read FIFO
324       P:0000AD P:0000AD 0A8989  TST3      JCLR    #EF,X:HDR,CHK_FO
                            0000A7
325    
326       P:0000AF P:0000AF 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
327       P:0000B1 P:0000B1 000000            NOP
328       P:0000B2 P:0000B2 000000            NOP
329       P:0000B3 P:0000B3 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
330       P:0000B5 P:0000B5 2B0000            MOVE              #0,B2
331       P:0000B6 P:0000B6 0140CE            AND     #$FF,B
                            0000FF
332       P:0000B8 P:0000B8 0140CD            CMP     #>$AC,B                           ; It must be $AC to be a valid word
                            0000AC
333       P:0000BA P:0000BA 0E20CF            JNE     <CLR_CC
334       P:0000BB P:0000BB 4EF000            MOVE                          Y:RDFO,Y0   ; Read the MS byte
                            FFFFF1
335       P:0000BD P:0000BD 0C1951            INSERT  #$008010,Y0,B
                            008010
336       P:0000BF P:0000BF 4EF000            MOVE                          Y:RDFO,Y0   ; Read the middle byte
                            FFFFF1
337       P:0000C1 P:0000C1 0C1951            INSERT  #$008008,Y0,B
                            008008
338       P:0000C3 P:0000C3 4EF000            MOVE                          Y:RDFO,Y0   ; Read the LS byte
                            FFFFF1
339       P:0000C5 P:0000C5 0C1951            INSERT  #$008000,Y0,B
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 7



                            008000
340       P:0000C7 P:0000C7 000000            NOP
341       P:0000C8 P:0000C8 516300            MOVE              B0,X:(R3)               ; Put the word into COM_BUF
342       P:0000C9 P:0000C9 0A0000            BCLR    #ST_RCV,X:<STATUS                 ; Its a command from the host computer
343       P:0000CA P:0000CA 000000  SET_CC    NOP
344       P:0000CB P:0000CB 0AF960            BSET    #0,SR                             ; Valid word => SR carry bit = 1
345       P:0000CC P:0000CC 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
346       P:0000CE P:0000CE 00000C            RTS
347       P:0000CF P:0000CF 0AF940  CLR_CC    BCLR    #0,SR                             ; Not valid word => SR carry bit = 0
348       P:0000D0 P:0000D0 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
349       P:0000D2 P:0000D2 00000C            RTS
350    
351                                 ; Test the SCI (= synchronous communications interface) for new words
352       P:0000D3 P:0000D3 44F000  CHK_SCI   MOVE              X:(SCI_TABLE+33),X0
                            000421
353       P:0000D5 P:0000D5 228E00            MOVE              R4,A
354       P:0000D6 P:0000D6 209000            MOVE              X0,R0
355       P:0000D7 P:0000D7 200045            CMP     X0,A
356       P:0000D8 P:0000D8 0EA0CF            JEQ     <CLR_CC                           ; There is no new SCI word
357       P:0000D9 P:0000D9 44D800            MOVE              X:(R0)+,X0
358       P:0000DA P:0000DA 446300            MOVE              X0,X:(R3)
359       P:0000DB P:0000DB 220E00            MOVE              R0,A
360       P:0000DC P:0000DC 0140C5            CMP     #(SCI_TABLE+32),A                 ; Wrap it around the circular
                            000420
361       P:0000DE P:0000DE 0EA0E2            JEQ     <INIT_PROCESSED_SCI               ;   buffer boundary
362       P:0000DF P:0000DF 547000            MOVE              A1,X:(SCI_TABLE+33)
                            000421
363       P:0000E1 P:0000E1 0C00E7            JMP     <SCI_END
364                                 INIT_PROCESSED_SCI
365       P:0000E2 P:0000E2 56F400            MOVE              #SCI_TABLE,A
                            000400
366       P:0000E4 P:0000E4 000000            NOP
367       P:0000E5 P:0000E5 567000            MOVE              A,X:(SCI_TABLE+33)
                            000421
368       P:0000E7 P:0000E7 0A0020  SCI_END   BSET    #ST_RCV,X:<STATUS                 ; Its a utility board (SCI) word
369       P:0000E8 P:0000E8 0C00CA            JMP     <SET_CC
370    
371                                 ; Transmit the word in B1 to the host computer over the fiber optic data link
372                                 XMT_WRD
373       P:0000E9 P:0000E9 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
374       P:0000EB P:0000EB 60F400            MOVE              #FO_HDR+1,R0
                            000002
375       P:0000ED P:0000ED 060380            DO      #3,XMT_WRD1
                            0000F1
376       P:0000EF P:0000EF 0C1D91            ASL     #8,B,B
377       P:0000F0 P:0000F0 000000            NOP
378       P:0000F1 P:0000F1 535800            MOVE              B2,X:(R0)+
379                                 XMT_WRD1
380       P:0000F2 P:0000F2 60F400            MOVE              #FO_HDR,R0
                            000001
381       P:0000F4 P:0000F4 61F400            MOVE              #WRFO,R1
                            FFFFF2
382       P:0000F6 P:0000F6 060480            DO      #4,XMT_WRD2
                            0000F9
383       P:0000F8 P:0000F8 46D800            MOVE              X:(R0)+,Y0              ; Should be MOVEP  X:(R0)+,Y:WRFO
384       P:0000F9 P:0000F9 4E6100            MOVE                          Y0,Y:(R1)
385                                 XMT_WRD2
386       P:0000FA P:0000FA 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 8



                            028FE1
387       P:0000FC P:0000FC 00000C            RTS
388    
389                                 ; Check the command or reply header in X:(R3) for self-consistency
390       P:0000FD P:0000FD 46E300  CHK_HDR   MOVE              X:(R3),Y0
391       P:0000FE P:0000FE 579600            MOVE              X:<MASK1,B              ; Test for S.LE.3 and D.LE.3 and N.LE.7
392       P:0000FF P:0000FF 20005E            AND     Y0,B
393       P:000100 P:000100 0E208B            JNE     <ERROR                            ; Test failed
394       P:000101 P:000101 579700            MOVE              X:<MASK2,B              ; Test for either S.NE.0 or D.NE.0
395       P:000102 P:000102 20005E            AND     Y0,B
396       P:000103 P:000103 0EA08B            JEQ     <ERROR                            ; Test failed
397       P:000104 P:000104 579500            MOVE              X:<SEVEN,B
398       P:000105 P:000105 20005E            AND     Y0,B                              ; Extract NWORDS, must be > 0
399       P:000106 P:000106 0EA08B            JEQ     <ERROR
400       P:000107 P:000107 44E300            MOVE              X:(R3),X0
401       P:000108 P:000108 440500            MOVE              X0,X:<HEADER            ; Its a correct header
402       P:000109 P:000109 550600            MOVE              B1,X:<NWORDS            ; Number of words in the command
403       P:00010A P:00010A 0C005C            JMP     <PR_RCV
404    
405                                 ;  *****************  Boot Commands  *******************
406    
407                                 ; Test Data Link - simply return value received after 'TDL'
408       P:00010B P:00010B 47DB00  TDL       MOVE              X:(R3)+,Y1              ; Get the data value
409       P:00010C P:00010C 0C008E            JMP     <FINISH1                          ; Return from executing TDL command
410    
411                                 ; Read DSP or EEPROM memory ('RDM' address): read memory, reply with value
412       P:00010D P:00010D 47DB00  RDMEM     MOVE              X:(R3)+,Y1
413       P:00010E P:00010E 20EF00            MOVE              Y1,B
414       P:00010F P:00010F 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
415       P:000111 P:000111 21B000            MOVE              B1,R0                   ; Need the address in an address register
416       P:000112 P:000112 20EF00            MOVE              Y1,B
417       P:000113 P:000113 000000            NOP
418       P:000114 P:000114 0ACF14            JCLR    #20,B,RDX                         ; Test address bit for Program memory
                            000118
419       P:000116 P:000116 07E087            MOVE              P:(R0),Y1               ; Read from Program Memory
420       P:000117 P:000117 0C008E            JMP     <FINISH1                          ; Send out a header with the value
421       P:000118 P:000118 0ACF15  RDX       JCLR    #21,B,RDY                         ; Test address bit for X: memory
                            00011C
422       P:00011A P:00011A 47E000            MOVE              X:(R0),Y1               ; Write to X data memory
423       P:00011B P:00011B 0C008E            JMP     <FINISH1                          ; Send out a header with the value
424       P:00011C P:00011C 0ACF16  RDY       JCLR    #22,B,RDR                         ; Test address bit for Y: memory
                            000120
425       P:00011E P:00011E 4FE000            MOVE                          Y:(R0),Y1   ; Read from Y data memory
426       P:00011F P:00011F 0C008E            JMP     <FINISH1                          ; Send out a header with the value
427       P:000120 P:000120 0ACF17  RDR       JCLR    #23,B,ERROR                       ; Test address bit for read from EEPROM memo
ry
                            00008B
428       P:000122 P:000122 479400            MOVE              X:<THREE,Y1             ; Convert to word address to a byte address
429       P:000123 P:000123 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
430       P:000124 P:000124 2000B8            MPY     Y0,Y1,B                           ; Multiply
431       P:000125 P:000125 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
432       P:000126 P:000126 213000            MOVE              B0,R0                   ; Need to address memory
433       P:000127 P:000127 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
434       P:000128 P:000128 0D0176            JSR     <RD_WORD                          ; Read word from EEPROM
435       P:000129 P:000129 21A700            MOVE              B1,Y1                   ; FINISH1 transmits Y1 as its reply
436       P:00012A P:00012A 0C008E            JMP     <FINISH1
437    
438                                 ; Program WRMEM ('WRM' address datum): write to memory, reply 'DON'.
439       P:00012B P:00012B 47DB00  WRMEM     MOVE              X:(R3)+,Y1              ; Get the address to be written to
440       P:00012C P:00012C 20EF00            MOVE              Y1,B
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 9



441       P:00012D P:00012D 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
442       P:00012F P:00012F 21B000            MOVE              B1,R0                   ; Need the address in an address register
443       P:000130 P:000130 20EF00            MOVE              Y1,B
444       P:000131 P:000131 46DB00            MOVE              X:(R3)+,Y0              ; Get datum into Y0 so MOVE works easily
445       P:000132 P:000132 0ACF14            JCLR    #20,B,WRX                         ; Test address bit for Program memory
                            000136
446       P:000134 P:000134 076086            MOVE              Y0,P:(R0)               ; Write to Program memory
447       P:000135 P:000135 0C008D            JMP     <FINISH
448       P:000136 P:000136 0ACF15  WRX       JCLR    #21,B,WRY                         ; Test address bit for X: memory
                            00013A
449       P:000138 P:000138 466000            MOVE              Y0,X:(R0)               ; Write to X: memory
450       P:000139 P:000139 0C008D            JMP     <FINISH
451       P:00013A P:00013A 0ACF16  WRY       JCLR    #22,B,WRR                         ; Test address bit for Y: memory
                            00013E
452       P:00013C P:00013C 4E6000            MOVE                          Y0,Y:(R0)   ; Write to Y: memory
453       P:00013D P:00013D 0C008D            JMP     <FINISH
454       P:00013E P:00013E 0ACF17  WRR       JCLR    #23,B,ERROR                       ; Test address bit for write to EEPROM
                            00008B
455       P:000140 P:000140 013D02            BCLR    #WRENA,X:PDRC                     ; WR_ENA* = 0 to enable EEPROM writing
456       P:000141 P:000141 460E00            MOVE              Y0,X:<SV_A1             ; Save the datum to be written
457       P:000142 P:000142 479400            MOVE              X:<THREE,Y1             ; Convert word address to a byte address
458       P:000143 P:000143 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
459       P:000144 P:000144 2000B8            MPY     Y1,Y0,B                           ; Multiply
460       P:000145 P:000145 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
461       P:000146 P:000146 213000            MOVE              B0,R0                   ; Need to address memory
462       P:000147 P:000147 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
463       P:000148 P:000148 558E00            MOVE              X:<SV_A1,B1             ; Get the datum to be written
464       P:000149 P:000149 060380            DO      #3,L1WRR                          ; Loop over three bytes of the word
                            000152
465       P:00014B P:00014B 07588D            MOVE              B1,P:(R0)+              ; Write each EEPROM byte
466       P:00014C P:00014C 0C1C91            ASR     #8,B,B
467       P:00014D P:00014D 469E00            MOVE              X:<C100K,Y0             ; Move right one byte, enter delay = 1 msec
468       P:00014E P:00014E 06C600            DO      Y0,L2WRR                          ; Delay by 12 milliseconds for EEPROM write
                            000151
469       P:000150 P:000150 060CA0            REP     #12                               ; Assume 100 MHz DSP56303
470       P:000151 P:000151 000000            NOP
471                                 L2WRR
472       P:000152 P:000152 000000            NOP                                       ; DO loop nesting restriction
473                                 L1WRR
474       P:000153 P:000153 013D22            BSET    #WRENA,X:PDRC                     ; WR_ENA* = 1 to disable EEPROM writing
475       P:000154 P:000154 0C008D            JMP     <FINISH
476    
477                                 ; Load application code from P: memory into its proper locations
478       P:000155 P:000155 47DB00  LDAPPL    MOVE              X:(R3)+,Y1              ; Application number, not used yet
479       P:000156 P:000156 0D0158            JSR     <LOAD_APPLICATION
480       P:000157 P:000157 0C008D            JMP     <FINISH
481    
482                                 LOAD_APPLICATION
483       P:000158 P:000158 60F400            MOVE              #$8000,R0               ; Starting EEPROM address
                            008000
484       P:00015A P:00015A 0D0176            JSR     <RD_WORD                          ; Number of words in boot code
485       P:00015B P:00015B 21A600            MOVE              B1,Y0
486       P:00015C P:00015C 479400            MOVE              X:<THREE,Y1
487       P:00015D P:00015D 2000B8            MPY     Y0,Y1,B
488       P:00015E P:00015E 20002A            ASR     B
489       P:00015F P:00015F 213000            MOVE              B0,R0                   ; EEPROM address of start of P: application
490       P:000160 P:000160 0AD06F            BSET    #15,R0                            ; To access EEPROM
491       P:000161 P:000161 0D0176            JSR     <RD_WORD                          ; Read number of words in application P:
492       P:000162 P:000162 61F400            MOVE              #(X_BOOT_START+1),R1    ; End of boot P: code that needs keeping
                            000226
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 10



493       P:000164 P:000164 06CD00            DO      B1,RD_APPL_P
                            000167
494       P:000166 P:000166 0D0176            JSR     <RD_WORD
495       P:000167 P:000167 07598D            MOVE              B1,P:(R1)+
496                                 RD_APPL_P
497       P:000168 P:000168 0D0176            JSR     <RD_WORD                          ; Read number of words in application X:
498       P:000169 P:000169 61F400            MOVE              #END_COMMAND_TABLE,R1
                            000036
499       P:00016B P:00016B 06CD00            DO      B1,RD_APPL_X
                            00016E
500       P:00016D P:00016D 0D0176            JSR     <RD_WORD
501       P:00016E P:00016E 555900            MOVE              B1,X:(R1)+
502                                 RD_APPL_X
503       P:00016F P:00016F 0D0176            JSR     <RD_WORD                          ; Read number of words in application Y:
504       P:000170 P:000170 310100            MOVE              #1,R1                   ; There is no Y: memory in the boot code
505       P:000171 P:000171 06CD00            DO      B1,RD_APPL_Y
                            000174
506       P:000173 P:000173 0D0176            JSR     <RD_WORD
507       P:000174 P:000174 5D5900            MOVE                          B1,Y:(R1)+
508                                 RD_APPL_Y
509       P:000175 P:000175 00000C            RTS
510    
511                                 ; Read one word from EEPROM location R0 into accumulator B1
512       P:000176 P:000176 060380  RD_WORD   DO      #3,L_RDBYTE
                            000179
513       P:000178 P:000178 07D88B            MOVE              P:(R0)+,B2
514       P:000179 P:000179 0C1C91            ASR     #8,B,B
515                                 L_RDBYTE
516       P:00017A P:00017A 00000C            RTS
517    
518                                 ; Come to here on a 'STP' command so 'DON' can be sent
519                                 STOP_IDLE_CLOCKING
520       P:00017B P:00017B 305800            MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
521       P:00017C P:00017C 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
522       P:00017D P:00017D 0A0002            BCLR    #IDLMODE,X:<STATUS                ; Don't idle after readout
523       P:00017E P:00017E 0C008D            JMP     <FINISH
524    
525                                 ; Routines executed after the DSP boots and initializes
526       P:00017F P:00017F 305800  STARTUP   MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
527       P:000180 P:000180 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
528       P:000181 P:000181 44F400            MOVE              #50000,X0               ; Delay by 500 milliseconds
                            00C350
529       P:000183 P:000183 06C400            DO      X0,L_DELAY
                            000186
530       P:000185 P:000185 06E8A3            REP     #1000
531       P:000186 P:000186 000000            NOP
532                                 L_DELAY
533       P:000187 P:000187 57F400            MOVE              #$020002,B              ; Normal reply after booting is 'SYR'
                            020002
534       P:000189 P:000189 0D00E9            JSR     <XMT_WRD
535       P:00018A P:00018A 57F400            MOVE              #'SYR',B
                            535952
536       P:00018C P:00018C 0D00E9            JSR     <XMT_WRD
537    
538       P:00018D P:00018D 0C0054            JMP     <START                            ; Start normal command processing
539    
540                                 ; *******************  DSP  INITIALIZATION  CODE  **********************
541                                 ; This code initializes the DSP right after booting, and is overwritten
542                                 ;   by application code
543       P:00018E P:00018E 08F4BD  INIT      MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL to 100 MHz
                            050003
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 11



544       P:000190 P:000190 000000            NOP
545    
546                                 ; Set operation mode register OMR to normal expanded
547       P:000191 P:000191 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
548       P:000192 P:000192 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
549    
550                                 ; Program the AA = address attribute pins
551       P:000193 P:000193 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts commands
                            FFFC21
552       P:000195 P:000195 08F4B8            MOVEP             #$008909,X:AAR1         ; P = $008000 to $00FFFF accesses the EEPROM
                            008909
553       P:000197 P:000197 08F4B7            MOVEP             #$010C11,X:AAR2         ; X = $010000 to $010FFF reads A/D values
                            010C11
554       P:000199 P:000199 08F4B6            MOVEP             #$080621,X:AAR3         ; Y = $080000 to $0BFFFF R/W from SRAM
                            080621
555    
556                                 ; Program the DRAM memory access and addressing
557       P:00019B P:00019B 08F4BB            MOVEP             #$028FE1,X:BCR          ; Bus Control Register
                            028FE1
558    
559                                 ; Program the Host port B for parallel I/O
560       P:00019D P:00019D 08F484            MOVEP             #>1,X:HPCR              ; All pins enabled as GPIO
                            000001
561       P:00019F P:00019F 08F489            MOVEP             #$810C,X:HDR
                            00810C
562       P:0001A1 P:0001A1 08F488            MOVEP             #$B10E,X:HDDR           ; Data Direction Register
                            00B10E
563                                                                                     ;  (1 for Output, 0 for Input)
564    
565                                 ; Port B conversion from software bits to schematic labels
566                                 ;       PB0 = PWROK             PB08 = PRSFIFO*
567                                 ;       PB1 = LED1              PB09 = EF*
568                                 ;       PB2 = LVEN              PB10 = EXT-IN0
569                                 ;       PB3 = HVEN              PB11 = EXT-IN1
570                                 ;       PB4 = STATUS0           PB12 = EXT-OUT0
571                                 ;       PB5 = STATUS1           PB13 = EXT-OUT1
572                                 ;       PB6 = STATUS2           PB14 = SSFHF*
573                                 ;       PB7 = STATUS3           PB15 = SELSCI
574    
575                                 ; Program the serial port ESSI0 = Port C for serial communication with
576                                 ;   the utility board
577       P:0001A3 P:0001A3 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
578       P:0001A5 P:0001A5 07F435            MOVEP             #$180809,X:CRA0         ; Divide 100 MHz by 20 to get 5.0 MHz
                            180809
579                                                                                     ; DC[4:0] = 0 for non-network operation
580                                                                                     ; WL0-WL2 = 3 for 24-bit data words
581                                                                                     ; SSC1 = 0 for SC1 not used
582       P:0001A7 P:0001A7 07F436            MOVEP             #$020020,X:CRB0         ; SCKD = 1 for internally generated clock
                            020020
583                                                                                     ; SCD2 = 0 so frame sync SC2 is an output
584                                                                                     ; SHFD = 0 for MSB shifted first
585                                                                                     ; FSL = 0, frame sync length not used
586                                                                                     ; CKP = 0 for rising clock edge transitions
587                                                                                     ; SYN = 0 for asynchronous
588                                                                                     ; TE0 = 1 to enable transmitter #0
589                                                                                     ; MOD = 0 for normal, non-networked mode
590                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
591                                                                                     ; RE = 1 to enable receiver
592       P:0001A9 P:0001A9 07F43F            MOVEP             #%111001,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000039
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 12



593       P:0001AB P:0001AB 07F43E            MOVEP             #%000110,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            000006
594       P:0001AD P:0001AD 07F43D            MOVEP             #%000100,X:PDRC         ; Data Register - WR_ENA* = 1
                            000004
595    
596                                 ; Port C version = Analog boards
597                                 ;       MOVEP   #$000809,X:CRA0 ; Divide 100 MHz by 20 to get 5.0 MHz
598                                 ;       MOVEP   #$000030,X:CRB0 ; SCKD = 1 for internally generated clock
599                                 ;       MOVEP   #%100000,X:PCRC ; Control Register (0 for GPIO, 1 for ESSI)
600                                 ;       MOVEP   #%000100,X:PRRC ; Data Direction Register (0 for In, 1 for Out)
601                                 ;       MOVEP   #%000000,X:PDRC ; Data Register: 'not used' = 0 outputs
602    
603       P:0001AF P:0001AF 07F43C            MOVEP             #0,X:TX00               ; Initialize the transmitter to zero
                            000000
604       P:0001B1 P:0001B1 000000            NOP
605       P:0001B2 P:0001B2 000000            NOP
606       P:0001B3 P:0001B3 013630            BSET    #TE,X:CRB0                        ; Enable the SSI transmitter
607    
608                                 ; Conversion from software bits to schematic labels for Port C
609                                 ;       PC0 = SC00 = UTL-T-SCK
610                                 ;       PC1 = SC01 = 2_XMT = SYNC on prototype
611                                 ;       PC2 = SC02 = WR_ENA*
612                                 ;       PC3 = SCK0 = TIM-U-SCK
613                                 ;       PC4 = SRD0 = UTL-T-STD
614                                 ;       PC5 = STD0 = TIM-U-STD
615    
616                                 ; Program the serial port ESSI1 = Port D for serial transmission to
617                                 ;   the analog boards and two parallel I/O input pins
618       P:0001B4 P:0001B4 07F42F            MOVEP             #>0,X:PCRD              ; Software reset of ESSI0
                            000000
619       P:0001B6 P:0001B6 07F425            MOVEP             #$000809,X:CRA1         ; Divide 100 MHz by 20 to get 5.0 MHz
                            000809
620                                                                                     ; DC[4:0] = 0
621                                                                                     ; WL[2:0] = ALC = 0 for 8-bit data words
622                                                                                     ; SSC1 = 0 for SC1 not used
623       P:0001B8 P:0001B8 07F426            MOVEP             #$000030,X:CRB1         ; SCKD = 1 for internally generated clock
                            000030
624                                                                                     ; SCD2 = 1 so frame sync SC2 is an output
625                                                                                     ; SHFD = 0 for MSB shifted first
626                                                                                     ; CKP = 0 for rising clock edge transitions
627                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
628                                                                                     ; MOD = 0 so its not networked mode
629       P:0001BA P:0001BA 07F42F            MOVEP             #%100000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000020
630                                                                                     ; PD3 = SCK1, PD5 = STD1 for ESSI
631       P:0001BC P:0001BC 07F42E            MOVEP             #%000100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            000004
632       P:0001BE P:0001BE 07F42D            MOVEP             #%000100,X:PDRD         ; Data Register: 'not used' = 0 outputs
                            000004
633       P:0001C0 P:0001C0 07F42C            MOVEP             #0,X:TX10               ; Initialize the transmitter to zero
                            000000
634       P:0001C2 P:0001C2 000000            NOP
635       P:0001C3 P:0001C3 000000            NOP
636       P:0001C4 P:0001C4 012630            BSET    #TE,X:CRB1                        ; Enable the SSI transmitter
637    
638                                 ; Conversion from software bits to schematic labels for Port D
639                                 ; PD0 = SC10 = 2_XMT_? input
640                                 ; PD1 = SC11 = SSFEF* input
641                                 ; PD2 = SC12 = PWR_EN
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 13



642                                 ; PD3 = SCK1 = TIM-A-SCK
643                                 ; PD4 = SRD1 = PWRRST
644                                 ; PD5 = STD1 = TIM-A-STD
645    
646                                 ; Program the SCI port to communicate with the utility board
647       P:0001C5 P:0001C5 07F41C            MOVEP             #$0B04,X:SCR            ; SCI programming: 11-bit asynchronous
                            000B04
648                                                                                     ;   protocol (1 start, 8 data, 1 even parity
,
649                                                                                     ;   1 stop); LSB before MSB; enable receiver
650                                                                                     ;   and its interrupts; transmitter interrup
ts
651                                                                                     ;   disabled.
652       P:0001C7 P:0001C7 07F41B            MOVEP             #$0003,X:SCCR           ; SCI clock: utility board data rate =
                            000003
653                                                                                     ;   (390,625 kbits/sec); internal clock.
654       P:0001C9 P:0001C9 07F41F            MOVEP             #%011,X:PCRE            ; Port Control Register = RXD, TXD enabled
                            000003
655       P:0001CB P:0001CB 07F41E            MOVEP             #%000,X:PRRE            ; Port Direction Register (0 = Input)
                            000000
656    
657                                 ;       PE0 = RXD
658                                 ;       PE1 = TXD
659                                 ;       PE2 = SCLK
660    
661                                 ; Program one of the three timers as an exposure timer
662       P:0001CD P:0001CD 07F403            MOVEP             #$C34F,X:TPLR           ; Prescaler to generate millisecond timer,
                            00C34F
663                                                                                     ;  counting from the system clock / 2 = 50 M
Hz
664       P:0001CF P:0001CF 07F40F            MOVEP             #$208200,X:TCSR0        ; Clear timer complete bit and enable presca
ler
                            208200
665       P:0001D1 P:0001D1 07F40E            MOVEP             #0,X:TLR0               ; Timer load register
                            000000
666    
667                                 ; Enable interrupts for the SCI port only
668       P:0001D3 P:0001D3 08F4BF            MOVEP             #$000000,X:IPRC         ; No interrupts allowed
                            000000
669       P:0001D5 P:0001D5 08F4BE            MOVEP             #>$80,X:IPRP            ; Enable SCI interrupt only, IPR = 1
                            000080
670       P:0001D7 P:0001D7 00FCB8            ANDI    #$FC,MR                           ; Unmask all interrupt levels
671    
672                                 ; Initialize the fiber optic serial receiver circuitry
673       P:0001D8 P:0001D8 061480            DO      #20,L_FO_INIT
                            0001DD
674       P:0001DA P:0001DA 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
675       P:0001DC P:0001DC 0605A0            REP     #5
676       P:0001DD P:0001DD 000000            NOP
677                                 L_FO_INIT
678    
679                                 ; Pulse PRSFIFO* low to revive the CMDRST* instruction and reset the FIFO
680       P:0001DE P:0001DE 44F400            MOVE              #1000000,X0             ; Delay by 10 milliseconds
                            0F4240
681       P:0001E0 P:0001E0 06C400            DO      X0,*+3
                            0001E2
682       P:0001E2 P:0001E2 000000            NOP
683       P:0001E3 P:0001E3 0A8908            BCLR    #8,X:HDR
684       P:0001E4 P:0001E4 0614A0            REP     #20
685       P:0001E5 P:0001E5 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 14



686       P:0001E6 P:0001E6 0A8928            BSET    #8,X:HDR
687    
688                                 ; Reset the utility board
689       P:0001E7 P:0001E7 0A0F05            BCLR    #5,X:<LATCH
690       P:0001E8 P:0001E8 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
691       P:0001EA P:0001EA 06C8A0            REP     #200                              ; Delay by RESET* low time
692       P:0001EB P:0001EB 000000            NOP
693       P:0001EC P:0001EC 0A0F25            BSET    #5,X:<LATCH
694       P:0001ED P:0001ED 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
695       P:0001EF P:0001EF 56F400            MOVE              #200000,A               ; Delay 2 msec for utility boot
                            030D40
696       P:0001F1 P:0001F1 06CE00            DO      A,*+3
                            0001F3
697       P:0001F3 P:0001F3 000000            NOP
698    
699                                 ; Put all the analog switch inputs to low so they draw minimum current
700       P:0001F4 P:0001F4 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
701       P:0001F5 P:0001F5 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
702       P:0001F7 P:0001F7 20001B            CLR     B
703       P:0001F8 P:0001F8 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
704       P:0001F9 P:0001F9 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
705       P:0001FB P:0001FB 060F80            DO      #15,L_ANALOG                      ; Fifteen video processor boards maximum
                            000203
706       P:0001FD P:0001FD 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
707       P:0001FE P:0001FE 200040            ADD     X0,A
708       P:0001FF P:0001FF 5F7000            MOVE                          B,Y:WRSS    ; This is for the fast analog switches
                            FFFFF3
709       P:000201 P:000201 0620A3            REP     #800                              ; Delay for the serial data transmission
710       P:000202 P:000202 000000            NOP
711       P:000203 P:000203 200068            ADD     X1,B                              ; Increment the video and clock driver numbe
rs
712                                 L_ANALOG
713       P:000204 P:000204 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Enable clearing of DACs
714       P:000205 P:000205 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable clock and DAC output switches
715       P:000206 P:000206 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Execute these two operations
                            00000F
716       P:000208 P:000208 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
717       P:000209 P:000209 0C021E            JMP     <SKIP
718    
719                                 ; Transmit contents of accumulator A1 over the synchronous serial transmitter
720                                 XMIT_A_WORD
721       P:00020A P:00020A 547000            MOVE              A1,X:SV_A1
                            00000E
722       P:00020C P:00020C 01A786            JCLR    #TDE,X:SSISR1,*                   ; Start bit
                            00020C
723       P:00020E P:00020E 07F42C            MOVEP             #$010000,X:TX10
                            010000
724       P:000210 P:000210 060380            DO      #3,L_XMIT
                            000216
725       P:000212 P:000212 01A786            JCLR    #TDE,X:SSISR1,*                   ; Three data bytes
                            000212
726       P:000214 P:000214 04CCCC            MOVEP             A1,X:TX10
727       P:000215 P:000215 0C1E90            LSL     #8,A
728       P:000216 P:000216 000000            NOP
729                                 L_XMIT
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 15



730       P:000217 P:000217 01A786            JCLR    #TDE,X:SSISR1,*                   ; Zeroes to bring transmitter low
                            000217
731       P:000219 P:000219 07F42C            MOVEP             #0,X:TX10
                            000000
732       P:00021B P:00021B 54F000            MOVE              X:SV_A1,A1
                            00000E
733       P:00021D P:00021D 00000C            RTS
734    
735                                 SKIP
736    
737                                 ; Set up the circular SCI buffer, 32 words in size
738       P:00021E P:00021E 64F400            MOVE              #SCI_TABLE,R4
                            000400
739       P:000220 P:000220 051FA4            MOVE              #31,M4
740       P:000221 P:000221 647000            MOVE              R4,X:(SCI_TABLE+33)
                            000421
741    
742                                           IF      @SCP("HOST","ROM")
750                                           ENDIF
751    
752       P:000223 P:000223 44F400            MOVE              #>$AC,X0
                            0000AC
753       P:000225 P:000225 440100            MOVE              X0,X:<FO_HDR
754    
755       P:000226 P:000226 0C017F            JMP     <STARTUP
756    
757                                 ;  ****************  X: Memory tables  ********************
758    
759                                 ; Define the address in P: space where the table of constants begins
760    
761                                  X_BOOT_START
762       000225                              EQU     @LCV(L)-2
763    
764                                           IF      @SCP("HOST","ROM")
766                                           ENDIF
767                                           IF      @SCP("HOST","HOST")
768       X:000000 X:000000                   ORG     X:0,X:0
769                                           ENDIF
770    
771                                 ; Special storage area - initialization constants and scratch space
772                                 ;STATUS DC      $1064                   ; Controller status bits
773       X:000000 X:000000         STATUS    DC      $64                               ; Controller status bits, ST_DITH OFF
774    
775       000001                    FO_HDR    EQU     STATUS+1                          ; Fiber optic write bytes
776       000005                    HEADER    EQU     FO_HDR+4                          ; Command header
777       000006                    NWORDS    EQU     HEADER+1                          ; Number of words in the command
778       000007                    COM_BUF   EQU     NWORDS+1                          ; Command buffer
779       00000E                    SV_A1     EQU     COM_BUF+7                         ; Save accumulator A1
780    
781                                           IF      @SCP("HOST","ROM")
786                                           ENDIF
787    
788                                           IF      @SCP("HOST","HOST")
789       X:00000F X:00000F                   ORG     X:$F,X:$F
790                                           ENDIF
791    
792                                 ; Parameter table in P: space to be copied into X: space during
793                                 ;   initialization, and is copied from ROM by the DSP boot
794       X:00000F X:00000F         LATCH     DC      $7A                               ; Starting value in latch chip U25
795                                  EXPOSURE_TIME
796       X:000010 X:000010                   DC      0                                 ; Exposure time in milliseconds
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\ARC22_boot.asm  Page 16



797                                  ELAPSED_TIME
798       X:000011 X:000011                   DC      0                                 ; Time elapsed so far in the exposure
799       X:000012 X:000012         ONE       DC      1                                 ; One
800       X:000013 X:000013         TWO       DC      2                                 ; Two
801       X:000014 X:000014         THREE     DC      3                                 ; Three
802       X:000015 X:000015         SEVEN     DC      7                                 ; Seven
803       X:000016 X:000016         MASK1     DC      $FCFCF8                           ; Mask for checking header
804       X:000017 X:000017         MASK2     DC      $030300                           ; Mask for checking header
805       X:000018 X:000018         DONE      DC      'DON'                             ; Standard reply
806       X:000019 X:000019         SBRD      DC      $020000                           ; Source Identification number
807       X:00001A X:00001A         TIM_DRB   DC      $000200                           ; Destination = timing board number
808       X:00001B X:00001B         DMASK     DC      $00FF00                           ; Mask to get destination board number
809       X:00001C X:00001C         SMASK     DC      $FF0000                           ; Mask to get source board number
810       X:00001D X:00001D         ERR       DC      'ERR'                             ; An error occurred
811       X:00001E X:00001E         C100K     DC      100000                            ; Delay for WRROM = 1 millisec
812       X:00001F X:00001F         IDL_ADR   DC      TST_RCV                           ; Address of idling routine
813       X:000020 X:000020         EXP_ADR   DC      0                                 ; Jump to this address during exposures
814    
815                                 ; Places for saving register values
816       X:000021 X:000021         SAVE_SR   DC      0                                 ; Status Register
817       X:000022 X:000022         SAVE_X1   DC      0
818       X:000023 X:000023         SAVE_A1   DC      0
819       X:000024 X:000024         SAVE_R0   DC      0
820       X:000025 X:000025         RCV_ERR   DC      0
821       X:000026 X:000026         SCI_A1    DC      0                                 ; Contents of accumulator A1 in RCV ISR
822       X:000027 X:000027         SCI_R0    DC      SRXL
823    
824                                 ; Command table
825       000028                    COM_TBL_R EQU     @LCV(R)
826       X:000028 X:000028         COM_TBL   DC      'TDL',TDL                         ; Test Data Link
827       X:00002A X:00002A                   DC      'RDM',RDMEM                       ; Read from DSP or EEPROM memory
828       X:00002C X:00002C                   DC      'WRM',WRMEM                       ; Write to DSP memory
829       X:00002E X:00002E                   DC      'LDA',LDAPPL                      ; Load application from EEPROM to DSP
830       X:000030 X:000030                   DC      'STP',STOP_IDLE_CLOCKING
831       X:000032 X:000032                   DC      'DON',START                       ; Nothing special
832       X:000034 X:000034                   DC      'ERR',START                       ; Nothing special
833    
834                                  END_COMMAND_TABLE
835       000036                              EQU     @LCV(R)
836    
837                                 ; The table at SCI_TABLE is for words received from the utility board, written by
838                                 ;   the interrupt service routine SCI_RCV. Note that it is 32 words long,
839                                 ;   hard coded, and the 33rd location contains the pointer to words that have
840                                 ;   been processed by moving them from the SCI_TABLE to the COM_BUF.
841    
842                                           IF      @SCP("HOST","ROM")
844                                           ENDIF
845    
846       000036                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
847    
848                                           INCLUDE "SystemConfig.asm"
849                                 ; SystemConfig.asm - defines the system configurations for an ARC controller
850                                 ; Use 'null.asm' for boards which are not installed
851    
852                                           DEFINE  TIMBRD    'tim3.asm'              ; timing board (not used yet)  'ARC22.asm'
853    
854                                           DEFINE  VIDDEFS   'GEN2VIDEO_defs.asm'    ; video board defs
855                                           DEFINE  VIDBRD0   'GEN2VIDEO_dacs_brd0.asm' ; video board 0
856                                           DEFINE  VIDBRD1   'null.asm'              ; video board 1
857                                           DEFINE  VIDBRD2   'null.asm'              ; video board 2
858                                           DEFINE  VIDBRD3   'null.asm'              ; video board 3
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\SystemConfig.asm  Page 17



859    
860                                           DEFINE  CLKBRD0   'Mont4kClock_dacs.asm'  ; clock board 0
861                                           DEFINE  CLKBRD1   'null.asm'              ; clock board 1
862    
863                                           DEFINE  SBNCODE   'GEN2VIDEO_GEN2CLK_sbn.asm' ; video&clock SBN command
864    
865                                           DEFINE  CLKPINOUT 'Mont4kClockPins.asm'   ; clock board pinout
866    
867                                           DEFINE  POWERCODE 'GEN2VIDEO_power.asm'   ; power related code
868    
869                                           DEFINE  UTILBRD   'null.asm'              ; utility board
870    
871    
872       P:000227 P:000227                   ORG     P:,P:
873    
874                                 ; Put number of words of application in P: for loading application from EEPROM
875       P:000227 P:000227                   DC      TIMBOOT_X_MEMORY-@LCV(L)-1
876    
877                                 ; *******************************************************************
878                                 ; Shift and read CCD
879                                 RDCCD
880       P:000228 P:000228 0A0024            BSET    #ST_RDC,X:<STATUS                 ; Set status to reading out
881       P:000229 P:000229 0D03EC            JSR     <PCI_READ_IMAGE                   ; Get the PCI board reading the image
882    
883       P:00022A P:00022A 0A00AA            JSET    #TST_IMG,X:STATUS,SYNTHETIC_IMAGE ; jump for fake image
                            0003B9
884    
885       P:00022C P:00022C 68A500            MOVE                          Y:<AFPXFER0,R0 ; frame transfer
886       P:00022D P:00022D 0D03FC            JSR     <CLOCK
887       P:00022E P:00022E 301500            MOVE              #<FRAMET,R0
888       P:00022F P:00022F 0D0285            JSR     <PQSKIP
889       P:000230 P:000230 0E8054            JCS     <START
890    
891       P:000231 P:000231 300E00            MOVE              #<NPPRESKIP,R0          ; skip to underscan
892       P:000232 P:000232 0D0279            JSR     <PSKIP
893       P:000233 P:000233 0E8054            JCS     <START
894       P:000234 P:000234 68A600            MOVE                          Y:<AFPXFER2,R0
895       P:000235 P:000235 0D03FC            JSR     <CLOCK
896       P:000236 P:000236 300700            MOVE              #<NSCLEAR,R0
897       P:000237 P:000237 0D029D            JSR     <FSSKIP
898    
899       P:000238 P:000238 300F00            MOVE              #<NPUNDERSCAN,R0        ; read underscan
900       P:000239 P:000239 0D0252            JSR     <PDATA
901       P:00023A P:00023A 0E8054            JCS     <START
902    
903       P:00023B P:00023B 68A500            MOVE                          Y:<AFPXFER0,R0 ; skip to ROI
904       P:00023C P:00023C 0D03FC            JSR     <CLOCK
905       P:00023D P:00023D 301000            MOVE              #<NPSKIP,R0
906       P:00023E P:00023E 0D0279            JSR     <PSKIP
907       P:00023F P:00023F 0E8054            JCS     <START
908       P:000240 P:000240 68A600            MOVE                          Y:<AFPXFER2,R0
909       P:000241 P:000241 0D03FC            JSR     <CLOCK
910       P:000242 P:000242 300700            MOVE              #<NSCLEAR,R0
911       P:000243 P:000243 0D029D            JSR     <FSSKIP
912    
913       P:000244 P:000244 300200            MOVE              #<NPDATA,R0             ; read ROI
914       P:000245 P:000245 0D0252            JSR     <PDATA
915       P:000246 P:000246 0E8054            JCS     <START
916    
917                                 ;       MOVE  #<NPOVERSCAN,A            ; test parallel overscan
918                                 ;       TST     A
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 18



919                                 ;       JLE     <RDC_END
920    
921                                 ;       MOVE    Y:<AFPXFER0,R0          ; skip to overscan
922                                 ;       JSR     <CLOCK
923                                 ;       MOVE  #<NPPOSTSKIP,R0
924                                 ;       JSR   <PSKIP
925                                 ;       JCS     <START
926                                 ;       MOVE    Y:<AFPXFER2,R0
927                                 ;       JSR     <CLOCK
928                                 ;       MOVE  #<NSCLEAR,R0
929                                 ;       JSR     <FSSKIP
930    
931                                 ;       MOVE  #<NPOVERSCAN,R0           ; read parallel overscan
932                                 ;       JSR   <PDATA
933                                 ;       JCS     <START
934    
935                                 RDC_END
936       P:000247 P:000247 0A0082            JCLR    #IDLMODE,X:<STATUS,NO_IDL         ; Don't idle after readout
                            00024D
937       P:000249 P:000249 60F400            MOVE              #IDLE,R0
                            0002F7
938       P:00024B P:00024B 601F00            MOVE              R0,X:<IDL_ADR
939       P:00024C P:00024C 0C024F            JMP     <RDC_E
940                                 NO_IDL
941       P:00024D P:00024D 305800            MOVE              #<TST_RCV,R0
942       P:00024E P:00024E 601F00            MOVE              R0,X:<IDL_ADR
943                                 RDC_E
944       P:00024F P:00024F 0D03F9            JSR     <WAIT_TO_FINISH_CLOCKING
945       P:000250 P:000250 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
946    
947       P:000251 P:000251 0C0054            JMP     <START                            ; DONE flag set by PCI when finished
948    
949                                 ; *******************************************************************
950                                 PDATA
951       P:000252 P:000252 0D02C8            JSR     <CNPAMPS                          ; compensate for split register
952       P:000253 P:000253 0EF26B            JLE     <PDATA0
953       P:000254 P:000254 06CE00            DO      A,PDATA0                          ; loop through # of binned rows into each se
rial register
                            00026A
954       P:000256 P:000256 300400            MOVE              #<NPBIN,R0              ; shift NPBIN rows into serial register
955       P:000257 P:000257 0D026C            JSR     <PDSKIP
956       P:000258 P:000258 0E025B            JCC     <PDATA1
957       P:000259 P:000259 00008C            ENDDO
958       P:00025A P:00025A 0C026B            JMP     <PDATA0
959                                 PDATA1
960       P:00025B P:00025B 300900            MOVE              #<NSPRESKIP,R0          ; skip to serial underscan
961       P:00025C P:00025C 0D02A5            JSR     <SSKIP
962       P:00025D P:00025D 300A00            MOVE              #<NSUNDERSCAN,R0        ; read underscan
963       P:00025E P:00025E 0D02AF            JSR     <SDATA
964       P:00025F P:00025F 300B00            MOVE              #<NSSKIP,R0             ; skip to ROI
965       P:000260 P:000260 0D02A5            JSR     <SSKIP
966       P:000261 P:000261 300100            MOVE              #<NSDATA,R0             ; read ROI
967       P:000262 P:000262 0D02AF            JSR     <SDATA
968       P:000263 P:000263 300C00            MOVE              #<NSPOSTSKIP,R0         ; skip to serial overscan
969       P:000264 P:000264 0D02A5            JSR     <SSKIP
970       P:000265 P:000265 300D00            MOVE              #<NSOVERSCAN,R0         ; read overscan
971       P:000266 P:000266 0D02AF            JSR     <SDATA
972       P:000267 P:000267 0AF940            BCLR    #0,SR                             ; set CC
973       P:000268 P:000268 000000            NOP
974       P:000269 P:000269 000000            NOP
975       P:00026A P:00026A 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 19



976                                 PDATA0
977       P:00026B P:00026B 00000C            RTS
978    
979                                 ; *******************************************************************
980                                 PDSKIP
981       P:00026C P:00026C 5EE000            MOVE                          Y:(R0),A    ; shift data lines into serial reg
982       P:00026D P:00026D 200003            TST     A
983       P:00026E P:00026E 0EF278            JLE     <PDSKIP0
984       P:00026F P:00026F 066040            DO      Y:(R0),PDSKIP0
                            000277
985       P:000271 P:000271 68A800            MOVE                          Y:<APDXFER,R0
986       P:000272 P:000272 0D02D2            JSR     <PCLOCK
987       P:000273 P:000273 0D00A3            JSR     <GET_RCV
988       P:000274 P:000274 0E0277            JCC     <PDSKIP1
989       P:000275 P:000275 00008C            ENDDO
990       P:000276 P:000276 000000            NOP
991                                 PDSKIP1
992       P:000277 P:000277 000000            NOP
993                                 PDSKIP0
994       P:000278 P:000278 00000C            RTS
995    
996                                 ; *******************************************************************
997                                 PSKIP
998       P:000279 P:000279 0D02C8            JSR     <CNPAMPS
999       P:00027A P:00027A 0EF284            JLE     <PSKIP0
1000      P:00027B P:00027B 06CE00            DO      A,PSKIP0
                            000283
1001      P:00027D P:00027D 68A700            MOVE                          Y:<APXFER,R0
1002      P:00027E P:00027E 0D02D2            JSR     <PCLOCK
1003      P:00027F P:00027F 0D00A3            JSR     <GET_RCV
1004      P:000280 P:000280 0E0283            JCC     <PSKIP1
1005      P:000281 P:000281 00008C            ENDDO
1006      P:000282 P:000282 000000            NOP
1007                                PSKIP1
1008      P:000283 P:000283 000000            NOP
1009                                PSKIP0
1010      P:000284 P:000284 00000C            RTS
1011   
1012                                ; *******************************************************************
1013                                PQSKIP
1014      P:000285 P:000285 0D02C8            JSR     <CNPAMPS
1015      P:000286 P:000286 0EF290            JLE     <PQSKIP0
1016      P:000287 P:000287 06CE00            DO      A,PQSKIP0
                            00028F
1017      P:000289 P:000289 68A900            MOVE                          Y:<APQXFER,R0
1018      P:00028A P:00028A 0D02D2            JSR     <PCLOCK
1019      P:00028B P:00028B 0D00A3            JSR     <GET_RCV
1020      P:00028C P:00028C 0E028F            JCC     <PQSKIP1
1021      P:00028D P:00028D 00008C            ENDDO
1022      P:00028E P:00028E 000000            NOP
1023                                PQSKIP1
1024      P:00028F P:00028F 000000            NOP
1025                                PQSKIP0
1026      P:000290 P:000290 00000C            RTS
1027   
1028                                ; *******************************************************************
1029                                RSKIP
1030      P:000291 P:000291 0D02C8            JSR     <CNPAMPS
1031      P:000292 P:000292 0EF29C            JLE     <RSKIP0
1032      P:000293 P:000293 06CE00            DO      A,RSKIP0
                            00029B
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 20



1033      P:000295 P:000295 68AA00            MOVE                          Y:<ARXFER,R0
1034      P:000296 P:000296 0D02D2            JSR     <PCLOCK
1035      P:000297 P:000297 0D00A3            JSR     <GET_RCV
1036      P:000298 P:000298 0E029B            JCC     <RSKIP1
1037      P:000299 P:000299 00008C            ENDDO
1038      P:00029A P:00029A 000000            NOP
1039                                RSKIP1
1040      P:00029B P:00029B 000000            NOP
1041                                RSKIP0
1042      P:00029C P:00029C 00000C            RTS
1043   
1044                                ; *******************************************************************
1045                                FSSKIP
1046      P:00029D P:00029D 0D02C2            JSR     <CNSAMPS
1047      P:00029E P:00029E 0EF2A4            JLE     <FSSKIP0
1048      P:00029F P:00029F 06CE00            DO      A,FSSKIP0
                            0002A3
1049      P:0002A1 P:0002A1 68AB00            MOVE                          Y:<AFSXFER,R0
1050      P:0002A2 P:0002A2 0D03FC            JSR     <CLOCK
1051      P:0002A3 P:0002A3 000000            NOP
1052                                FSSKIP0
1053      P:0002A4 P:0002A4 00000C            RTS
1054   
1055                                ; *******************************************************************
1056                                SSKIP
1057      P:0002A5 P:0002A5 0D02C2            JSR     <CNSAMPS
1058      P:0002A6 P:0002A6 0EF2AE            JLE     <SSKIP0
1059      P:0002A7 P:0002A7 06CE00            DO      A,SSKIP0
                            0002AD
1060      P:0002A9 P:0002A9 68AC00            MOVE                          Y:<ASXFER0,R0
1061      P:0002AA P:0002AA 0D03FC            JSR     <CLOCK
1062      P:0002AB P:0002AB 68AE00            MOVE                          Y:<ASXFER2,R0
1063      P:0002AC P:0002AC 0D03FC            JSR     <CLOCK
1064      P:0002AD P:0002AD 000000            NOP
1065                                SSKIP0
1066      P:0002AE P:0002AE 00000C            RTS
1067   
1068                                ; *******************************************************************
1069                                SDATA
1070      P:0002AF P:0002AF 0D02C2            JSR     <CNSAMPS
1071      P:0002B0 P:0002B0 0EF2C1            JLE     <SDATA0
1072      P:0002B1 P:0002B1 06CE00            DO      A,SDATA0
                            0002C0
1073      P:0002B3 P:0002B3 68AC00            MOVE                          Y:<ASXFER0,R0
1074      P:0002B4 P:0002B4 0D03FC            JSR     <CLOCK
1075      P:0002B5 P:0002B5 449200            MOVE              X:<ONE,X0               ; Get bin-1
1076      P:0002B6 P:0002B6 5E8300            MOVE                          Y:<NSBIN,A
1077      P:0002B7 P:0002B7 200044            SUB     X0,A
1078      P:0002B8 P:0002B8 0EF2BE            JLE     <SDATA1
1079      P:0002B9 P:0002B9 06CE00            DO      A,SDATA1
                            0002BD
1080      P:0002BB P:0002BB 68AD00            MOVE                          Y:<ASXFER1,R0
1081      P:0002BC P:0002BC 0D03FC            JSR     <CLOCK
1082      P:0002BD P:0002BD 000000            NOP
1083                                SDATA1
1084      P:0002BE P:0002BE 68AF00            MOVE                          Y:<ASXFER2D,R0
1085      P:0002BF P:0002BF 0D03FC            JSR     <CLOCK
1086                                SDATA0T
1087      P:0002C0 P:0002C0 000000            NOP
1088                                SDATA0
1089      P:0002C1 P:0002C1 00000C            RTS
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 21



1090   
1091                                ; *******************************************************************
1092                                ; Compensate count for split serial
1093      P:0002C2 P:0002C2 5EE000  CNSAMPS   MOVE                          Y:(R0),A    ; get num pixels to read
1094      P:0002C3 P:0002C3 0A05C0            JCLR    #0,Y:<NSAMPS,CNSSHIFTLL           ; split register?
                            0002C6
1095      P:0002C5 P:0002C5 200022            ASR     A                                 ; yes, divide by 2
1096      P:0002C6 P:0002C6 200003  CNSSHIFTLL TST    A
1097      P:0002C7 P:0002C7 00000C            RTS
1098   
1099                                ; *******************************************************************
1100                                ; Compensate count for split parallel
1101      P:0002C8 P:0002C8 5EE000  CNPAMPS   MOVE                          Y:(R0),A    ; get num rows to shift
1102      P:0002C9 P:0002C9 0A06C0            JCLR    #0,Y:<NPAMPS,CNPSHIFTLL           ; split parallels?
                            0002CC
1103      P:0002CB P:0002CB 200022            ASR     A                                 ; yes, divide by 2
1104      P:0002CC P:0002CC 200003  CNPSHIFTLL TST    A
1105      P:0002CD P:0002CD 000000            NOP                                       ; MPL for Gen3
1106      P:0002CE P:0002CE 000000            NOP                                       ; MPL for Gen3
1107      P:0002CF P:0002CF 0AF940            BCLR    #0,SR                             ; clear carry
1108      P:0002D0 P:0002D0 000000            NOP                                       ; MPL for Gen3
1109      P:0002D1 P:0002D1 00000C            RTS
1110   
1111                                ; *******************************************************************
1112                                ; slow clock for parallel shifts - Gen3 version
1113                                PCLOCK
1114      P:0002D2 P:0002D2 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
                            0002D2
1115      P:0002D4 P:0002D4 000000            NOP
1116      P:0002D5 P:0002D5 0A898E            JCLR    #SSFHF,X:HDR,PCLOCK               ; Guard against metastability
                            0002D2
1117      P:0002D7 P:0002D7 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1118      P:0002D8 P:0002D8 06C400            DO      X0,PCLK1                          ; Repeat X0 times
                            0002DE
1119      P:0002DA P:0002DA 5ED800            MOVE                          Y:(R0)+,A   ; get waveform
1120      P:0002DB P:0002DB 062040            DO      Y:<PMULT,PCLK2
                            0002DD
1121      P:0002DD P:0002DD 09CE33            MOVEP             A,Y:WRSS                ; 30 nsec write the waveform to the SS
1122      P:0002DE P:0002DE 000000  PCLK2     NOP
1123      P:0002DF P:0002DF 000000  PCLK1     NOP
1124      P:0002E0 P:0002E0 00000C            RTS                                       ; Return from subroutine
1125   
1126                                ; *******************************************************************
1127      P:0002E1 P:0002E1 0D02E3  CLEAR     JSR     <CLR_CCD                          ; clear CCD, executed as a command
1128      P:0002E2 P:0002E2 0C008D            JMP     <FINISH
1129   
1130                                ; *******************************************************************
1131                                CLR_CCD
1132      P:0002E3 P:0002E3 68A500            MOVE                          Y:<AFPXFER0,R0 ; prep for fast flush
1133      P:0002E4 P:0002E4 0D03FC            JSR     <CLOCK
1134      P:0002E5 P:0002E5 300800            MOVE              #<NPCLEAR,R0            ; shift all rows
1135      P:0002E6 P:0002E6 0D0285            JSR     <PQSKIP
1136      P:0002E7 P:0002E7 68A600            MOVE                          Y:<AFPXFER2,R0 ; set clocks on clear exit
1137      P:0002E8 P:0002E8 0D03FC            JSR     <CLOCK
1138      P:0002E9 P:0002E9 300700            MOVE              #<NSCLEAR,R0            ; flush serial register
1139      P:0002EA P:0002EA 0D029D            JSR     <FSSKIP
1140      P:0002EB P:0002EB 00000C            RTS
1141   
1142                                ; *******************************************************************
1143                                FOR_PSHIFT
1144      P:0002EC P:0002EC 301300            MOVE              #<NPXSHIFT,R0           ; forward shift rows
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 22



1145      P:0002ED P:0002ED 0D0279            JSR     <PSKIP
1146      P:0002EE P:0002EE 0C008D            JMP     <FINISH
1147   
1148                                ; *******************************************************************
1149                                REV_PSHIFT
1150      P:0002EF P:0002EF 301300            MOVE              #<NPXSHIFT,R0           ; reverse shift rows
1151      P:0002F0 P:0002F0 0D0291            JSR     <RSKIP
1152      P:0002F1 P:0002F1 0C008D            JMP     <FINISH
1153   
1154                                ; *******************************************************************
1155                                ; Set software to IDLE mode
1156                                START_IDLE_CLOCKING
1157      P:0002F2 P:0002F2 60F400            MOVE              #IDLE,R0                ; Exercise clocks when idling
                            0002F7
1158      P:0002F4 P:0002F4 601F00            MOVE              R0,X:<IDL_ADR
1159      P:0002F5 P:0002F5 0A0022            BSET    #IDLMODE,X:<STATUS                ; Idle after readout
1160      P:0002F6 P:0002F6 0C008D            JMP     <FINISH                           ; Need to send header and 'DON'
1161   
1162                                ; Keep the CCD idling when not reading out - MPL modified for AzCam
1163      P:0002F7 P:0002F7 060740  IDLE      DO      Y:<NSCLEAR,IDL1                   ; Loop over number of pixels per line
                            000300
1164      P:0002F9 P:0002F9 68AB00            MOVE                          Y:<AFSXFER,R0 ; Serial transfer on pixel
1165      P:0002FA P:0002FA 0D03FC            JSR     <CLOCK                            ; Go to it
1166      P:0002FB P:0002FB 330700            MOVE              #COM_BUF,R3
1167      P:0002FC P:0002FC 0D00A3            JSR     <GET_RCV                          ; Check for FO or SSI commands
1168      P:0002FD P:0002FD 0E0300            JCC     <NO_COM                           ; Continue IDLE if no commands received
1169      P:0002FE P:0002FE 00008C            ENDDO
1170      P:0002FF P:0002FF 0C005B            JMP     <PRC_RCV                          ; Go process header and command
1171      P:000300 P:000300 000000  NO_COM    NOP
1172                                IDL1
1173      P:000301 P:000301 68A900            MOVE                          Y:<APQXFER,R0 ; Address of parallel clocking waveform
1174      P:000302 P:000302 0D03FC            JSR     <CLOCK                            ; Go clock out the CCD charge
1175                                ;       JSR     <PCLOCK                 ; Go clock out the CCD charge
1176      P:000303 P:000303 0C02F7            JMP     <IDLE
1177   
1178                                ; *******************************************************************
1179   
1180                                ; Misc routines
1181   
1182                                ; POWER_OFF
1183                                ; POWER_ON
1184                                ; SET_BIASES
1185                                ; CLR_SWS
1186                                ; CLEAR_SWITCHES_AND_DACS
1187                                ; OPEN_SHUTTER
1188                                ; CLOSE_SHUTTER
1189                                ; OSHUT
1190                                ; CSHUT
1191                                ; EXPOSE
1192                                ; START_EXPOSURE
1193                                ; SET_EXPOSURE_TIME
1194                                ; READ_EXPOSURE_TIME
1195                                ; PAUSE_EXPOSURE
1196                                ; RESUME_EXPOSURE
1197                                ; ABORT_ALL
1198                                ; SYNTHETIC_IMAGE
1199                                ; XMT_PIX
1200                                ; READ_AD
1201                                ; PCI_READ_IMAGE
1202                                ; WAIT_TO_FINISH_CLOCKING
1203                                ; CLOCK
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 23



1204                                ; PAL_DLY
1205                                ; READ_CONTROLLER_CONFIGURATION
1206                                ; ST_GAIN
1207                                ; SET_DC
1208                                ; SET_BIAS_NUMBER
1209                                ;
1210   
1211                                          INCLUDE "GEN2VIDEO_power.asm"
1212                                ; GEN2VIDEO_power.asm
1213                                ; Power related code
1214   
1215                                ; *******************************************************************
1216                                POWER_OFF
1217      P:000304 P:000304 0D033A            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1218      P:000305 P:000305 0A8922            BSET    #LVEN,X:HDR
1219      P:000306 P:000306 0A8923            BSET    #HVEN,X:HDR
1220      P:000307 P:000307 0C008D            JMP     <FINISH
1221   
1222                                ; *******************************************************************
1223                                ; Execute the power-on cycle, as a command
1224                                POWER_ON
1225      P:000308 P:000308 0D033A            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1226   
1227                                ; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and delay
1228      P:000309 P:000309 0A8902            BCLR    #LVEN,X:HDR                       ; Set these signals to DSP outputs
1229      P:00030A P:00030A 44F400            MOVE              #2000000,X0
                            1E8480
1230      P:00030C P:00030C 06C400            DO      X0,*+3                            ; Wait 20 millisec for settling
                            00030E
1231      P:00030E P:00030E 000000            NOP
1232   
1233                                ; Turn on the high +36 volt power line and delay
1234      P:00030F P:00030F 0A8903            BCLR    #HVEN,X:HDR                       ; HVEN = Low => Turn on +36V
1235      P:000310 P:000310 44F400            MOVE              #2000000,X0
                            1E8480
1236      P:000312 P:000312 06C400            DO      X0,*+3                            ; Wait 20 millisec for settling
                            000314
1237      P:000314 P:000314 000000            NOP
1238   
1239      P:000315 P:000315 0A8980            JCLR    #PWROK,X:HDR,PWR_ERR              ; Test if the power turned on properly
                            00031C
1240      P:000317 P:000317 0D0321            JSR     <SET_BIASES                       ; Turn on the DC bias supplies
1241      P:000318 P:000318 60F400            MOVE              #IDLE,R0                ; Put controller in IDLE state
                            0002F7
1242      P:00031A P:00031A 601F00            MOVE              R0,X:<IDL_ADR
1243      P:00031B P:00031B 0C008D            JMP     <FINISH
1244   
1245                                ; The power failed to turn on because of an error on the power control board
1246      P:00031C P:00031C 0A8922  PWR_ERR   BSET    #LVEN,X:HDR                       ; Turn off the low voltage emable line
1247      P:00031D P:00031D 0A8923            BSET    #HVEN,X:HDR                       ; Turn off the high voltage emable line
1248      P:00031E P:00031E 0C008B            JMP     <ERROR
1249   
1250                                ; *******************************************************************
1251                                SET_BIAS_VOLTAGES
1252      P:00031F P:00031F 0D0321            JSR     <SET_BIASES
1253      P:000320 P:000320 0C008D            JMP     <FINISH
1254   
1255                                ; Set all the DC bias voltages and video processor offset values, reading
1256                                ;   them from the 'DACS' table
1257                                SET_BIASES
1258      P:000321 P:000321 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\GEN2VIDEO_power.asm  Page 24



1259      P:000322 P:000322 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1260      P:000323 P:000323 0A0F20            BSET    #CDAC,X:<LATCH                    ; Disable clearing of DACs
1261      P:000324 P:000324 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable clock and DAC output switches
1262      P:000325 P:000325 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1263      P:000327 P:000327 0D0407            JSR     <PAL_DLY                          ; Delay for all this to happen
1264   
1265                                ; Read DAC values from a table, and write them to the DACs
1266                                ;       MOVE    #DACS,R0                ; Get starting address of DAC values
1267      P:000328 P:000328 68B000            MOVE                          Y:<ADACS,R0 ; MPL
1268      P:000329 P:000329 000000            NOP
1269      P:00032A P:00032A 000000            NOP
1270      P:00032B P:00032B 000000            NOP
1271      P:00032C P:00032C 065840            DO      Y:(R0)+,L_DAC                     ; Repeat Y:(R0)+ times
                            000330
1272      P:00032E P:00032E 5ED800            MOVE                          Y:(R0)+,A   ; Read the table entry
1273      P:00032F P:00032F 0D020A            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1274      P:000330 P:000330 000000            NOP
1275                                L_DAC
1276   
1277                                ; Let the DAC voltages all ramp up before exiting
1278      P:000331 P:000331 44F400            MOVE              #400000,X0
                            061A80
1279      P:000333 P:000333 06C400            DO      X0,*+3                            ; 4 millisec delay
                            000335
1280      P:000335 P:000335 000000            NOP
1281      P:000336 P:000336 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1282      P:000337 P:000337 00000C            RTS
1283   
1284                                ; *******************************************************************
1285      P:000338 P:000338 0D033A  CLR_SWS   JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1286      P:000339 P:000339 0C008D            JMP     <FINISH
1287   
1288                                CLEAR_SWITCHES_AND_DACS
1289      P:00033A P:00033A 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Clear all the DACs
1290      P:00033B P:00033B 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable all the output switches
1291      P:00033C P:00033C 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1292      P:00033E P:00033E 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1293      P:00033F P:00033F 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
1294      P:000341 P:000341 20001B            CLR     B
1295      P:000342 P:000342 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
1296      P:000343 P:000343 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
1297      P:000345 P:000345 060F80            DO      #15,L_VIDEO                       ; Fifteen video processor boards maximum
                            00034C
1298      P:000347 P:000347 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1299      P:000348 P:000348 200040            ADD     X0,A
1300      P:000349 P:000349 5F7000            MOVE                          B,Y:WRSS
                            FFFFF3
1301      P:00034B P:00034B 0D0407            JSR     <PAL_DLY                          ; Delay for the serial data transmission
1302      P:00034C P:00034C 200068            ADD     X1,B
1303                                L_VIDEO
1304      P:00034D P:00034D 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1305      P:00034E P:00034E 00000C            RTS
1306   
1307                                ; *******************************************************************
1308                                ; Open the shutter by setting the backplane bit TIM-LATCH0
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 25



1309                                ; reversed for ITL prober
1310      P:00034F P:00034F 0A0023  OSHUT     BSET    #ST_SHUT,X:<STATUS                ; Set status bit to mean shutter open
1311      P:000350 P:000350 0A0F24            BSET    #SHUTTER,X:<LATCH                 ; Clear hardware shutter bit to open
1312      P:000351 P:000351 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1313      P:000353 P:000353 00000C            RTS
1314   
1315                                ; *******************************************************************
1316                                ; Close the shutter by clearing the backplane bit TIM-LATCH0
1317                                ; reversed for ITL prober
1318      P:000354 P:000354 0A0003  CSHUT     BCLR    #ST_SHUT,X:<STATUS                ; Clear status to mean shutter closed
1319      P:000355 P:000355 0A0F04            BCLR    #SHUTTER,X:<LATCH                 ; Set hardware shutter bit to close
1320      P:000356 P:000356 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1321      P:000358 P:000358 00000C            RTS
1322   
1323                                ; *******************************************************************
1324                                ; Open the shutter from the timing board, executed as a command
1325                                OPEN_SHUTTER
1326      P:000359 P:000359 0D034F            JSR     <OSHUT
1327      P:00035A P:00035A 0C008D            JMP     <FINISH
1328   
1329                                ; *******************************************************************
1330                                ; Close the shutter from the timing board, executed as a command
1331                                CLOSE_SHUTTER
1332      P:00035B P:00035B 0D0354            JSR     <CSHUT
1333      P:00035C P:00035C 0C008D            JMP     <FINISH
1334   
1335                                ; *******************************************************************
1336                                ; Start the exposure timer and monitor its progress
1337      P:00035D P:00035D 579000  EXPOSE    MOVE              X:<EXPOSURE_TIME,B
1338      P:00035E P:00035E 20000B            TST     B                                 ; Special test for zero exposure time
1339      P:00035F P:00035F 0EA375            JEQ     <END_EXP                          ; Don't even start an exposure
1340      P:000360 P:000360 01418C            SUB     #1,B                              ; Timer counts from X:TCPR0+1 to zero
1341      P:000361 P:000361 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer #0
1342      P:000362 P:000362 577000            MOVE              B,X:TCPR0
                            FFFF8D
1343   
1344                                ; special check for short shutter time MPL
1345                                CHK_RCV
1346      P:000364 P:000364 569000            MOVE              X:<EXPOSURE_TIME,A
1347      P:000365 P:000365 0140C4            SUB     #200,A
                            0000C8
1348      P:000367 P:000367 200003            TST     A
1349      P:000368 P:000368 0AF0AF            JLE     CHK_TIM
                            000373
1350   
1351                                ;CHK_RCV
1352      P:00036A P:00036A 330700            MOVE              #COM_BUF,R3             ; The beginning of the command buffer
1353      P:00036B P:00036B 0A8989            JCLR    #EF,X:HDR,EXP1                    ; Simple test for fast execution
                            00036F
1354      P:00036D P:00036D 0D00A3            JSR     <GET_RCV                          ; Check for an incoming command
1355      P:00036E P:00036E 0E805B            JCS     <PRC_RCV                          ; If command is received, go check it
1356      P:00036F P:00036F 0A008C  EXP1      JCLR    #ST_DITH,X:STATUS,CHK_TIM
                            000373
1357      P:000371 P:000371 68AB00            MOVE                          Y:<AFSXFER,R0
1358      P:000372 P:000372 0D03FC            JSR     <CLOCK
1359      P:000373 P:000373 018F95  CHK_TIM   JCLR    #TCF,X:TCSR0,CHK_RCV              ; Wait for timer to equal compare value
                            000364
1360      P:000375 P:000375 010F00  END_EXP   BCLR    #TIM_BIT,X:TCSR0                  ; Disable the timer
1361      P:000376 P:000376 0AE780            JMP     (R7)                              ; This contains the return address
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 26



1362   
1363                                ; *******************************************************************
1364                                ; Start the exposure, operate the shutter, and initiate CCD readout
1365                                START_EXPOSURE
1366      P:000377 P:000377 57F400            MOVE              #$020102,B
                            020102
1367      P:000379 P:000379 0D00E9            JSR     <XMT_WRD
1368      P:00037A P:00037A 57F400            MOVE              #'IIA',B                ; responds to host with DON
                            494941
1369      P:00037C P:00037C 0D00E9            JSR     <XMT_WRD                          ;  indicating exposure started
1370   
1371      P:00037D P:00037D 305800            MOVE              #<TST_RCV,R0            ; Process commands, don't idle,
1372      P:00037E P:00037E 601F00            MOVE              R0,X:<IDL_ADR           ;  during the exposure
1373      P:00037F P:00037F 0A008B            JCLR    #SHUT,X:STATUS,L_SEX0
                            000382
1374      P:000381 P:000381 0D034F            JSR     <OSHUT                            ; Open the shutter if needed
1375      P:000382 P:000382 67F400  L_SEX0    MOVE              #L_SEX1,R7              ; Return address at end of exposure
                            000385
1376      P:000384 P:000384 0C035D            JMP     <EXPOSE                           ; Delay for specified exposure time
1377                                L_SEX1
1378      P:000385 P:000385 0A008B            JCLR    #SHUT,X:STATUS,S_DEL0
                            000392
1379      P:000387 P:000387 0D0354            JSR     <CSHUT                            ; Close the shutter if necessary
1380   
1381                                ; shutter delay
1382      P:000388 P:000388 5E9900            MOVE                          Y:<SH_DEL,A
1383      P:000389 P:000389 200003            TST     A
1384      P:00038A P:00038A 0EF392            JLE     <S_DEL0
1385      P:00038B P:00038B 449E00            MOVE              X:<C100K,X0             ; assume 100 MHz DSP
1386      P:00038C P:00038C 06CE00            DO      A,S_DEL0                          ; Delay by Y:SH_DEL milliseconds
                            000391
1387      P:00038E P:00038E 06C400            DO      X0,S_DEL1
                            000390
1388      P:000390 P:000390 000000            NOP
1389      P:000391 P:000391 000000  S_DEL1    NOP
1390      P:000392 P:000392 000000  S_DEL0    NOP
1391   
1392      P:000393 P:000393 0C0054            JMP     <START                            ; finish
1393   
1394                                ; *******************************************************************
1395                                ; Set the desired exposure time
1396                                SET_EXPOSURE_TIME
1397      P:000394 P:000394 46DB00            MOVE              X:(R3)+,Y0
1398      P:000395 P:000395 461000            MOVE              Y0,X:EXPOSURE_TIME
1399      P:000396 P:000396 07F00D            MOVEP             X:EXPOSURE_TIME,X:TCPR0
                            000010
1400      P:000398 P:000398 0C008D            JMP     <FINISH
1401   
1402                                ; *******************************************************************
1403                                ; Read the time remaining until the exposure ends
1404                                READ_EXPOSURE_TIME
1405      P:000399 P:000399 47F000            MOVE              X:TCR0,Y1               ; Read elapsed exposure time
                            FFFF8C
1406      P:00039B P:00039B 0C008E            JMP     <FINISH1
1407   
1408                                ; *******************************************************************
1409                                ; Pause the exposure - close the shutter, and stop the timer
1410                                PAUSE_EXPOSURE
1411      P:00039C P:00039C 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1412      P:00039D P:00039D 0D0354            JSR     <CSHUT                            ; Close the shutter
1413      P:00039E P:00039E 0C008D            JMP     <FINISH
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 27



1414   
1415                                ; *******************************************************************
1416                                ; Resume the exposure - open the shutter if needed and restart the timer
1417                                RESUME_EXPOSURE
1418      P:00039F P:00039F 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Re-enable the DSP exposure timer
1419      P:0003A0 P:0003A0 0A008B            JCLR    #SHUT,X:STATUS,L_RES
                            0003A3
1420      P:0003A2 P:0003A2 0D034F            JSR     <OSHUT                            ; Open the shutter ir necessary
1421      P:0003A3 P:0003A3 0C008D  L_RES     JMP     <FINISH
1422   
1423                                ; *******************************************************************
1424                                ; Special ending after abort command to send a 'DON' to the host computer
1425                                ABORT_ALL
1426      P:0003A4 P:0003A4 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1427      P:0003A5 P:0003A5 0D0354            JSR     <CSHUT                            ; Close the shutter
1428      P:0003A6 P:0003A6 44F400            MOVE              #100000,X0
                            0186A0
1429      P:0003A8 P:0003A8 06C400            DO      X0,L_WAIT0                        ; Wait one millisecond to delimit
                            0003AA
1430      P:0003AA P:0003AA 000000            NOP                                       ;   image data and the 'DON' reply
1431                                L_WAIT0
1432      P:0003AB P:0003AB 0A0082            JCLR    #IDLMODE,X:<STATUS,NO_IDL2        ; Don't idle after readout
                            0003B1
1433      P:0003AD P:0003AD 60F400            MOVE              #IDLE,R0
                            0002F7
1434      P:0003AF P:0003AF 601F00            MOVE              R0,X:<IDL_ADR
1435      P:0003B0 P:0003B0 0C03B3            JMP     <RDC_E2
1436      P:0003B1 P:0003B1 305800  NO_IDL2   MOVE              #<TST_RCV,R0
1437      P:0003B2 P:0003B2 601F00            MOVE              R0,X:<IDL_ADR
1438      P:0003B3 P:0003B3 0D03F9  RDC_E2    JSR     <WAIT_TO_FINISH_CLOCKING
1439      P:0003B4 P:0003B4 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1440   
1441      P:0003B5 P:0003B5 44F400            MOVE              #$000202,X0             ; Send 'DON' to the host computer
                            000202
1442      P:0003B7 P:0003B7 440500            MOVE              X0,X:<HEADER
1443      P:0003B8 P:0003B8 0C008D            JMP     <FINISH
1444   
1445                                ; *******************************************************************
1446                                ; Generate a synthetic image by simply incrementing the pixel counts
1447                                SYNTHETIC_IMAGE
1448      P:0003B9 P:0003B9 200013            CLR     A
1449                                ;       DO      Y:<NPR,LPR_TST          ; Loop over each line readout
1450                                ;       DO      Y:<NSR,LSR_TST          ; Loop over number of pixels per line
1451      P:0003BA P:0003BA 061C40            DO      Y:<NPIMAGE,LPR_TST                ; Loop over each line readout
                            0003C5
1452      P:0003BC P:0003BC 061B40            DO      Y:<NSIMAGE,LSR_TST                ; Loop over number of pixels per line
                            0003C4
1453      P:0003BE P:0003BE 0614A0            REP     #20                               ; #20 => 1.0 microsec per pixel
1454      P:0003BF P:0003BF 000000            NOP
1455      P:0003C0 P:0003C0 014180            ADD     #1,A                              ; Pixel data = Pixel data + 1
1456      P:0003C1 P:0003C1 000000            NOP
1457      P:0003C2 P:0003C2 21CF00            MOVE              A,B
1458      P:0003C3 P:0003C3 0D03C7            JSR     <XMT_PIX                          ;  transmit them
1459      P:0003C4 P:0003C4 000000            NOP
1460                                LSR_TST
1461      P:0003C5 P:0003C5 000000            NOP
1462                                LPR_TST
1463      P:0003C6 P:0003C6 0C0247            JMP     <RDC_END                          ; Normal exit
1464   
1465                                ; *******************************************************************
1466                                ; Transmit the 16-bit pixel datum in B1 to the host computer
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 28



1467      P:0003C7 P:0003C7 0C1DA1  XMT_PIX   ASL     #16,B,B
1468      P:0003C8 P:0003C8 000000            NOP
1469      P:0003C9 P:0003C9 216500            MOVE              B2,X1
1470      P:0003CA P:0003CA 0C1D91            ASL     #8,B,B
1471      P:0003CB P:0003CB 000000            NOP
1472      P:0003CC P:0003CC 216400            MOVE              B2,X0
1473      P:0003CD P:0003CD 000000            NOP
1474      P:0003CE P:0003CE 09C532            MOVEP             X1,Y:WRFO
1475      P:0003CF P:0003CF 09C432            MOVEP             X0,Y:WRFO
1476      P:0003D0 P:0003D0 00000C            RTS
1477   
1478                                ; *******************************************************************
1479                                ; Test the hardware to read A/D values directly into the DSP instead
1480                                ;   of using the SXMIT option, A/Ds #2 and 3.
1481      P:0003D1 P:0003D1 57F000  READ_AD   MOVE              X:(RDAD+2),B
                            010002
1482      P:0003D3 P:0003D3 0C1DA1            ASL     #16,B,B
1483      P:0003D4 P:0003D4 000000            NOP
1484      P:0003D5 P:0003D5 216500            MOVE              B2,X1
1485      P:0003D6 P:0003D6 0C1D91            ASL     #8,B,B
1486      P:0003D7 P:0003D7 000000            NOP
1487      P:0003D8 P:0003D8 216400            MOVE              B2,X0
1488      P:0003D9 P:0003D9 000000            NOP
1489      P:0003DA P:0003DA 09C532            MOVEP             X1,Y:WRFO
1490      P:0003DB P:0003DB 09C432            MOVEP             X0,Y:WRFO
1491      P:0003DC P:0003DC 060AA0            REP     #10
1492      P:0003DD P:0003DD 000000            NOP
1493      P:0003DE P:0003DE 57F000            MOVE              X:(RDAD+3),B
                            010003
1494      P:0003E0 P:0003E0 0C1DA1            ASL     #16,B,B
1495      P:0003E1 P:0003E1 000000            NOP
1496      P:0003E2 P:0003E2 216500            MOVE              B2,X1
1497      P:0003E3 P:0003E3 0C1D91            ASL     #8,B,B
1498      P:0003E4 P:0003E4 000000            NOP
1499      P:0003E5 P:0003E5 216400            MOVE              B2,X0
1500      P:0003E6 P:0003E6 000000            NOP
1501      P:0003E7 P:0003E7 09C532            MOVEP             X1,Y:WRFO
1502      P:0003E8 P:0003E8 09C432            MOVEP             X0,Y:WRFO
1503      P:0003E9 P:0003E9 060AA0            REP     #10
1504      P:0003EA P:0003EA 000000            NOP
1505      P:0003EB P:0003EB 00000C            RTS
1506   
1507                                ; *******************************************************************
1508                                ; Alert the PCI interface board that images are coming soon
1509                                PCI_READ_IMAGE
1510      P:0003EC P:0003EC 57F400            MOVE              #$020104,B              ; Send header word to the FO transmitter
                            020104
1511      P:0003EE P:0003EE 0D00E9            JSR     <XMT_WRD
1512      P:0003EF P:0003EF 57F400            MOVE              #'RDA',B
                            524441
1513      P:0003F1 P:0003F1 0D00E9            JSR     <XMT_WRD
1514                                ;       MOVE    Y:NSR,B                 ; Number of columns to read
1515      P:0003F2 P:0003F2 5FF000            MOVE                          Y:NSIMAGE,B ; Number of columns to read
                            00001B
1516      P:0003F4 P:0003F4 0D00E9            JSR     <XMT_WRD
1517                                ;       MOVE    Y:NPR,B                 ; Number of rows to read
1518      P:0003F5 P:0003F5 5FF000            MOVE                          Y:NPIMAGE,B ; Number of columns to read
                            00001C
1519      P:0003F7 P:0003F7 0D00E9            JSR     <XMT_WRD
1520      P:0003F8 P:0003F8 00000C            RTS
1521   
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 29



1522                                ; *******************************************************************
1523                                ; Wait for the clocking to be complete before proceeding
1524                                WAIT_TO_FINISH_CLOCKING
1525      P:0003F9 P:0003F9 01ADA1            JSET    #SSFEF,X:PDRD,*                   ; Wait for the SS FIFO to be empty
                            0003F9
1526      P:0003FB P:0003FB 00000C            RTS
1527   
1528                                ; *******************************************************************
1529                                ; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
1530                                ;   and 10 nanosec for the wait state that is required for SRAM writes and
1531                                ;   FIFO setup times. It looks reliable, so will be used for now.
1532   
1533                                ; Core subroutine for clocking out CCD charge
1534                                CLOCK
1535      P:0003FC P:0003FC 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
                            0003FC
1536      P:0003FE P:0003FE 000000            NOP
1537      P:0003FF P:0003FF 0A898E            JCLR    #SSFHF,X:HDR,CLOCK                ; Guard against metastability
                            0003FC
1538      P:000401 P:000401 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1539      P:000402 P:000402 06C400            DO      X0,CLK1                           ; Repeat X0 times
                            000404
1540      P:000404 P:000404 09D8F3            MOVEP             Y:(R0)+,Y:WRSS          ; 30 nsec Write the waveform to the SS
1541                                CLK1
1542      P:000405 P:000405 000000            NOP
1543      P:000406 P:000406 00000C            RTS                                       ; Return from subroutine
1544   
1545                                ; *******************************************************************
1546                                ; Work on later !!!
1547                                ; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec
1548                                ;   the one wait state that is required for SRAM writes and FIFO setup times.
1549                                ;   However, the assembler gives a WARNING about pipeline problems if its
1550                                ;   put in a DO loop. This problem needs to be resolved later, and in the
1551                                ;   meantime I'll be using the MOVEP instruction.
1552   
1553                                ;       MOVE    #$FFFF03,R6             ; Write switch states, X:(R6)
1554                                ;       MOVE    Y:(R0)+,A  A,X:(R6)
1555   
1556                                ; Delay for serial writes to the PALs and DACs by 8 microsec
1557      P:000407 P:000407 062083  PAL_DLY   DO      #800,DLY                          ; Wait 8 usec for serial data transmission
                            000409
1558      P:000409 P:000409 000000            NOP
1559      P:00040A P:00040A 000000  DLY       NOP
1560      P:00040B P:00040B 00000C            RTS
1561   
1562                                ; *******************************************************************
1563                                ; Let the host computer read the controller configuration
1564                                READ_CONTROLLER_CONFIGURATION
1565      P:00040C P:00040C 4F9A00            MOVE                          Y:<CONFIG,Y1 ; Just transmit the configuration
1566      P:00040D P:00040D 0C008E            JMP     <FINISH1
1567   
1568                                ; *******************************************************************
1569                                ; Set the video processor boards in DC-coupled diagnostic mode or not
1570                                ; Command syntax is  SDC #      # = 0 for normal operation
1571                                ;                               # = 1 for DC coupled diagnostic mode
1572      P:00040E P:00040E 012F23  SET_DC    BSET    #3,X:PCRD                         ; Turn the serial clock on
1573      P:00040F P:00040F 44DB00            MOVE              X:(R3)+,X0
1574      P:000410 P:000410 0AC420            JSET    #0,X0,SDC_1
                            000415
1575      P:000412 P:000412 0A174A            BCLR    #10,Y:<GAIN
1576      P:000413 P:000413 0A174B            BCLR    #11,Y:<GAIN
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 30



1577      P:000414 P:000414 0C0417            JMP     <SDC_A
1578      P:000415 P:000415 0A176A  SDC_1     BSET    #10,Y:<GAIN
1579      P:000416 P:000416 0A176B            BSET    #11,Y:<GAIN
1580      P:000417 P:000417 241000  SDC_A     MOVE              #$100000,X0             ; Increment value
1581      P:000418 P:000418 060F80            DO      #15,SDC_LOOP
                            00041D
1582      P:00041A P:00041A 5E9700            MOVE                          Y:<GAIN,A
1583      P:00041B P:00041B 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1584      P:00041C P:00041C 0D0407            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1585      P:00041D P:00041D 200048            ADD     X0,B                              ; Increment the video processor board number
1586                                SDC_LOOP
1587      P:00041E P:00041E 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1588      P:00041F P:00041F 0C008D            JMP     <FINISH
1589   
1590                                ; include SBN command
1591                                          INCLUDE "GEN2VIDEO_GEN2CLK_sbn.asm"
1592                                ; ARC45_GEN2CLK_SBN.asm
1593   
1594                                ; This is code for the SDSU2 clock driver and SDSU2 CCD video processor.
1595                                ; SET_MUX and ST_GAIN also included.
1596   
1597                                ; 22Jul11 last change MPL
1598   
1599                                ; *******************************************************************
1600                                ; Set a particular DAC numbers, for setting DC bias voltages, clock driver
1601                                ;   voltages and video processor offset
1602                                ;
1603                                ; SBN  #BOARD  #DAC  ['CLK' or 'VID']  voltage
1604                                ;
1605                                ;                               #BOARD is from 0 to 15
1606                                ;                               #DAC number
1607                                ;                               #voltage is from 0 to 4095
1608   
1609                                SET_BIAS_NUMBER                                     ; Set bias number
1610      P:000420 P:000420 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1611      P:000421 P:000421 56DB00            MOVE              X:(R3)+,A               ; First argument is board number, 0 to 15
1612      P:000422 P:000422 0614A0            REP     #20
1613      P:000423 P:000423 200033            LSL     A
1614      P:000424 P:000424 000000            NOP
1615      P:000425 P:000425 21C400            MOVE              A,X0
1616      P:000426 P:000426 56DB00            MOVE              X:(R3)+,A               ; Second argument is DAC number
1617      P:000427 P:000427 060EA0            REP     #14
1618      P:000428 P:000428 200033            LSL     A
1619      P:000429 P:000429 200042            OR      X0,A
1620      P:00042A P:00042A 57DB00            MOVE              X:(R3)+,B               ; Third argument is 'VID' or 'CLK' string
1621      P:00042B P:00042B 44F400            MOVE              #'VID',X0
                            564944
1622      P:00042D P:00042D 20004D            CMP     X0,B
1623      P:00042E P:00042E 0E2433            JNE     <CLK_DRV
1624      P:00042F P:00042F 0ACC73            BSET    #19,A1                            ; Set bits to mean video processor DAC
1625      P:000430 P:000430 000000            NOP
1626      P:000431 P:000431 0ACC72            BSET    #18,A1
1627      P:000432 P:000432 0C0437            JMP     <VID_BRD
1628      P:000433 P:000433 44F400  CLK_DRV   MOVE              #'CLK',X0
                            434C4B
1629      P:000435 P:000435 20004D            CMP     X0,B
1630      P:000436 P:000436 0E2441            JNE     <ERR_SBN
1631      P:000437 P:000437 21C400  VID_BRD   MOVE              A,X0
1632      P:000438 P:000438 56DB00            MOVE              X:(R3)+,A               ; Fourth argument is voltage value, 0 to $ff
f
1633      P:000439 P:000439 46F400            MOVE              #$000FFF,Y0             ; Mask off just 12 bits to be sure
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\GEN2VIDEO_GEN2CLK_sbn.asm  Page 31



                            000FFF
1634      P:00043B P:00043B 200056            AND     Y0,A
1635      P:00043C P:00043C 200042            OR      X0,A
1636      P:00043D P:00043D 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1637      P:00043E P:00043E 0D0407            JSR     <PAL_DLY                          ; Wait for the number to be sent
1638      P:00043F P:00043F 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1639      P:000440 P:000440 0C008D            JMP     <FINISH
1640      P:000441 P:000441 56DB00  ERR_SBN   MOVE              X:(R3)+,A               ; Read and discard the fourth argument
1641      P:000442 P:000442 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1642      P:000443 P:000443 0C008B            JMP     <ERROR
1643   
1644                                ; *******************************************************************
1645                                ; Set the video processor gain and integrator speed for all video boards
1646                                ;  Command syntax is  SGN  #GAIN #SPEED,        #GAIN = 1, 2, 5 or 10
1647                                ;                                               #SPEED = 0 for slow, 1 for fast
1648                                ST_GAIN
1649      P:000444 P:000444 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1650      P:000445 P:000445 56DB00            MOVE              X:(R3)+,A               ; Gain value (1,2,5 or 10)
1651      P:000446 P:000446 44F400            MOVE              #>1,X0
                            000001
1652      P:000448 P:000448 200045            CMP     X0,A                              ; Check for gain = x1
1653      P:000449 P:000449 0E244D            JNE     <STG2
1654      P:00044A P:00044A 57F400            MOVE              #>$77,B
                            000077
1655      P:00044C P:00044C 0C0461            JMP     <STG_A
1656      P:00044D P:00044D 44F400  STG2      MOVE              #>2,X0                  ; Check for gain = x2
                            000002
1657      P:00044F P:00044F 200045            CMP     X0,A
1658      P:000450 P:000450 0E2454            JNE     <STG5
1659      P:000451 P:000451 57F400            MOVE              #>$BB,B
                            0000BB
1660      P:000453 P:000453 0C0461            JMP     <STG_A
1661      P:000454 P:000454 44F400  STG5      MOVE              #>5,X0                  ; Check for gain = x5
                            000005
1662      P:000456 P:000456 200045            CMP     X0,A
1663      P:000457 P:000457 0E245B            JNE     <STG10
1664      P:000458 P:000458 57F400            MOVE              #>$DD,B
                            0000DD
1665      P:00045A P:00045A 0C0461            JMP     <STG_A
1666      P:00045B P:00045B 44F400  STG10     MOVE              #>10,X0                 ; Check for gain = x10
                            00000A
1667      P:00045D P:00045D 200045            CMP     X0,A
1668      P:00045E P:00045E 0E208B            JNE     <ERROR
1669      P:00045F P:00045F 57F400            MOVE              #>$EE,B
                            0000EE
1670   
1671      P:000461 P:000461 56DB00  STG_A     MOVE              X:(R3)+,A               ; Integrator Speed (0 for slow, 1 for fast)
1672      P:000462 P:000462 000000            NOP
1673      P:000463 P:000463 0ACC00            JCLR    #0,A1,STG_B
                            000468
1674      P:000465 P:000465 0ACD68            BSET    #8,B1
1675      P:000466 P:000466 000000            NOP
1676      P:000467 P:000467 0ACD69            BSET    #9,B1
1677      P:000468 P:000468 44F400  STG_B     MOVE              #$0C3C00,X0
                            0C3C00
1678      P:00046A P:00046A 20004A            OR      X0,B
1679      P:00046B P:00046B 000000            NOP
1680      P:00046C P:00046C 5F1700            MOVE                          B,Y:<GAIN   ; Store the GAIN value for later use
1681   
1682                                ; Send this same value to 15 video processor boards whether they exist or not
1683                                ; fix from Leach 27Jan05
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\GEN2VIDEO_GEN2CLK_sbn.asm  Page 32



1684      P:00046D P:00046D 241000            MOVE              #$100000,X0             ; Increment value
1685      P:00046E P:00046E 060F80            DO      #15,STG_LOOP
                            000474
1686      P:000470 P:000470 21AC00            MOVE              B1,A1
1687      P:000471 P:000471 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1688      P:000472 P:000472 0D0407            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1689      P:000473 P:000473 200048            ADD     X0,B                              ; Increment the video processor board number
1690      P:000474 P:000474 000000            NOP
1691                                STG_LOOP
1692      P:000475 P:000475 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1693      P:000476 P:000476 0C008D            JMP     <FINISH
1694      P:000477 P:000477 56DB00  ERR_SGN   MOVE              X:(R3)+,A
1695      P:000478 P:000478 0C008B            JMP     <ERROR
1696   
1697                                ; *******************************************************************
1698                                ; Specify the MUX value to be output on the clock driver board
1699                                ; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
1700                                ;                               #clock_driver_board from 0 to 15
1701                                ;                               #MUX1, #MUX2 from 0 to 23
1702      P:000479 P:000479 012F23  SET_MUX   BSET    #3,X:PCRD                         ; Turn on the serial clock
1703      P:00047A P:00047A 56DB00            MOVE              X:(R3)+,A               ; Clock driver board number
1704      P:00047B P:00047B 0614A0            REP     #20
1705      P:00047C P:00047C 200033            LSL     A
1706      P:00047D P:00047D 44F400            MOVE              #$003000,X0
                            003000
1707      P:00047F P:00047F 200042            OR      X0,A
1708      P:000480 P:000480 000000            NOP
1709      P:000481 P:000481 21C500            MOVE              A,X1                    ; Move here for storage
1710   
1711                                ; Get the first MUX number
1712      P:000482 P:000482 56DB00            MOVE              X:(R3)+,A               ; Get the first MUX number
1713      P:000483 P:000483 0AF0A9            JLT     ERR_SM1
                            0004C7
1714      P:000485 P:000485 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1715      P:000487 P:000487 200045            CMP     X0,A
1716      P:000488 P:000488 0AF0A1            JGE     ERR_SM1
                            0004C7
1717      P:00048A P:00048A 21CF00            MOVE              A,B
1718      P:00048B P:00048B 44F400            MOVE              #>7,X0
                            000007
1719      P:00048D P:00048D 20004E            AND     X0,B
1720      P:00048E P:00048E 44F400            MOVE              #>$18,X0
                            000018
1721      P:000490 P:000490 200046            AND     X0,A
1722      P:000491 P:000491 0E2494            JNE     <SMX_1                            ; Test for 0 <= MUX number <= 7
1723      P:000492 P:000492 0ACD63            BSET    #3,B1
1724      P:000493 P:000493 0C049F            JMP     <SMX_A
1725      P:000494 P:000494 44F400  SMX_1     MOVE              #>$08,X0
                            000008
1726      P:000496 P:000496 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1727      P:000497 P:000497 0E249A            JNE     <SMX_2
1728      P:000498 P:000498 0ACD64            BSET    #4,B1
1729      P:000499 P:000499 0C049F            JMP     <SMX_A
1730      P:00049A P:00049A 44F400  SMX_2     MOVE              #>$10,X0
                            000010
1731      P:00049C P:00049C 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1732      P:00049D P:00049D 0E24C7            JNE     <ERR_SM1
1733      P:00049E P:00049E 0ACD65            BSET    #5,B1
1734      P:00049F P:00049F 20006A  SMX_A     OR      X1,B1                             ; Add prefix to MUX numbers
1735      P:0004A0 P:0004A0 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\GEN2VIDEO_GEN2CLK_sbn.asm  Page 33



1736      P:0004A1 P:0004A1 21A700            MOVE              B1,Y1
1737   
1738                                ; Add on the second MUX number
1739      P:0004A2 P:0004A2 56DB00            MOVE              X:(R3)+,A               ; Get the next MUX number
1740      P:0004A3 P:0004A3 0E908B            JLT     <ERROR
1741      P:0004A4 P:0004A4 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1742      P:0004A6 P:0004A6 200045            CMP     X0,A
1743      P:0004A7 P:0004A7 0E108B            JGE     <ERROR
1744      P:0004A8 P:0004A8 0606A0            REP     #6
1745      P:0004A9 P:0004A9 200033            LSL     A
1746      P:0004AA P:0004AA 000000            NOP
1747      P:0004AB P:0004AB 21CF00            MOVE              A,B
1748      P:0004AC P:0004AC 44F400            MOVE              #$1C0,X0
                            0001C0
1749      P:0004AE P:0004AE 20004E            AND     X0,B
1750      P:0004AF P:0004AF 44F400            MOVE              #>$600,X0
                            000600
1751      P:0004B1 P:0004B1 200046            AND     X0,A
1752      P:0004B2 P:0004B2 0E24B5            JNE     <SMX_3                            ; Test for 0 <= MUX number <= 7
1753      P:0004B3 P:0004B3 0ACD69            BSET    #9,B1
1754      P:0004B4 P:0004B4 0C04C0            JMP     <SMX_B
1755      P:0004B5 P:0004B5 44F400  SMX_3     MOVE              #>$200,X0
                            000200
1756      P:0004B7 P:0004B7 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1757      P:0004B8 P:0004B8 0E24BB            JNE     <SMX_4
1758      P:0004B9 P:0004B9 0ACD6A            BSET    #10,B1
1759      P:0004BA P:0004BA 0C04C0            JMP     <SMX_B
1760      P:0004BB P:0004BB 44F400  SMX_4     MOVE              #>$400,X0
                            000400
1761      P:0004BD P:0004BD 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1762      P:0004BE P:0004BE 0E208B            JNE     <ERROR
1763      P:0004BF P:0004BF 0ACD6B            BSET    #11,B1
1764      P:0004C0 P:0004C0 200078  SMX_B     ADD     Y1,B                              ; Add prefix to MUX numbers
1765      P:0004C1 P:0004C1 000000            NOP
1766      P:0004C2 P:0004C2 21AE00            MOVE              B1,A
1767      P:0004C3 P:0004C3 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1768      P:0004C4 P:0004C4 0D0407            JSR     <PAL_DLY                          ; Delay for all this to happen
1769      P:0004C5 P:0004C5 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1770      P:0004C6 P:0004C6 0C008D            JMP     <FINISH
1771      P:0004C7 P:0004C7 56DB00  ERR_SM1   MOVE              X:(R3)+,A
1772      P:0004C8 P:0004C8 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1773      P:0004C9 P:0004C9 0C008B            JMP     <ERROR
1774   
1775                                 TIMBOOT_X_MEMORY
1776      0004CA                              EQU     @LCV(L)
1777   
1778                                ;  ****************  Setup memory tables in X: space ********************
1779   
1780                                ; Define the address in P: space where the table of constants begins
1781   
1782                                          IF      @SCP("HOST","HOST")
1783      X:000036 X:000036                   ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
1784                                          ENDIF
1785   
1786                                          IF      @SCP("HOST","ROM")
1788                                          ENDIF
1789   
1790                                ; Application commands
1791      X:000036 X:000036                   DC      'PON',POWER_ON
1792      X:000038 X:000038                   DC      'POF',POWER_OFF
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 34



1793      X:00003A X:00003A                   DC      'SBV',SET_BIAS_VOLTAGES
1794      X:00003C X:00003C                   DC      'IDL',START_IDLE_CLOCKING
1795      X:00003E X:00003E                   DC      'OSH',OPEN_SHUTTER
1796      X:000040 X:000040                   DC      'CSH',CLOSE_SHUTTER
1797      X:000042 X:000042                   DC      'RDC',RDCCD
1798      X:000044 X:000044                   DC      'CLR',CLEAR
1799   
1800                                ; Exposure and readout control routines
1801      X:000046 X:000046                   DC      'SET',SET_EXPOSURE_TIME
1802      X:000048 X:000048                   DC      'RET',READ_EXPOSURE_TIME
1803      X:00004A X:00004A                   DC      'SEX',START_EXPOSURE
1804      X:00004C X:00004C                   DC      'PEX',PAUSE_EXPOSURE
1805      X:00004E X:00004E                   DC      'REX',RESUME_EXPOSURE
1806      X:000050 X:000050                   DC      'AEX',ABORT_ALL
1807      X:000052 X:000052                   DC      'ABR',ABORT_ALL                   ; MPL temporary
1808      X:000054 X:000054                   DC      'FPX',FOR_PSHIFT
1809      X:000056 X:000056                   DC      'RPX',REV_PSHIFT
1810   
1811                                ; Support routines
1812      X:000058 X:000058                   DC      'SGN',ST_GAIN
1813      X:00005A X:00005A                   DC      'SDC',SET_DC
1814      X:00005C X:00005C                   DC      'SBN',SET_BIAS_NUMBER
1815      X:00005E X:00005E                   DC      'SMX',SET_MUX
1816      X:000060 X:000060                   DC      'CSW',CLR_SWS
1817      X:000062 X:000062                   DC      'RCC',READ_CONTROLLER_CONFIGURATION
1818   
1819                                 END_APPLICATON_COMMAND_TABLE
1820      000064                              EQU     @LCV(L)
1821   
1822                                          IF      @SCP("HOST","HOST")
1823      00001E                    NUM_COM   EQU     (@LCV(R)-COM_TBL_R)/2             ; Number of boot + application commands
1824      000373                    EXPOSING  EQU     CHK_TIM                           ; Address if exposing
1825                                          ENDIF
1826   
1827                                          IF      @SCP("HOST","ROM")
1829                                          ENDIF
1830   
1831                                ; Now let's go for the timing waveform tables
1832                                          IF      @SCP("HOST","HOST")
1833      Y:000000 Y:000000                   ORG     Y:0,Y:0
1834                                          ENDIF
1835   
1836                                ; *** include waveform header info ***
1837      000001                    GENCNT    EQU     1                                 ; clock tables index
1838      000000                    VIDEO     EQU     $000000                           ; Video processor board (all are addressed t
ogether)
1839      002000                    CLK2      EQU     $002000                           ; Clock driver board select = board 2 low ba
nk
1840      003000                    CLK3      EQU     $003000                           ; Clock driver board select = board 2 high b
ank
1841      200000                    CLKV      EQU     $200000                           ; Clock driver board DAC voltage selection a
ddress (ARC32)
1842   
1843                                ; for ARC-48
1844                                 VIDEO_CONFIG
1845      0C000C                              EQU     $0C000C                           ; WARP = DAC_OUT = ON; H16B, Reset FIFOs
1846      000000                    VID0      EQU     $000000                           ; Address of the first ARC-48 video board
1847      100000                    VID1      EQU     $100000                           ; Address of the second ARC-48 video board
1848      0E0000                    DAC_ADDR  EQU     $0E0000                           ; DAC Channel Address
1849      0F4000                    DAC_RegM  EQU     $0F4000                           ; DAC m Register
1850      0F8000                    DAC_RegC  EQU     $0F8000                           ; DAC c Register
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 35



1851      0FC000                    DAC_RegD  EQU     $0FC000                           ; DAC X1 Register
1852      000000                    VIDEO_DACS EQU    $000000                           ; Address of DACs on the video board
1853      000800                    CLK_ZERO  EQU     $000800                           ; Zero volts on clock driver line
1854   
1855                                ; *** include waveform table ***
1856                                          INCLUDE "mont4k.asm"
1857                                ; Mont4k - spare controller
1858                                ; 23Jul14 last change - MPL
1859   
1860                                ; *** timing (40 - 5080 ns) ***
1861      000078                    SERDEL    EQU     120                               ; S clock delay      120
1862      000078                    RSTDEL    EQU     120                               ; RG clock delay
1863      000078                    VIDDEL    EQU     120                               ; Video clock delay
1864      001388                    PARDEL    EQU     5000                              ; P clock delay 5000
1865      000019                    PARMULT   EQU     25                                ; PARDEL multiplier
1866      00044C                    SAMPLE    EQU     1100                              ; sample time 2000
1867   
1868                                ; gain  3.0 e/DN, VG=2, VS=2, OD=23
1869   
1870                                ; *** video offsets ***
1871                                ; value for 5x gain, slow, 2 usec dwell
1872      000708                    OFFSET    EQU     1800                              ; global offset
1873      00008E                    OFFSETA   EQU     142                               ; offset 0    ;  ds9 left side
1874      000005                    OFFSETB   EQU     5                                 ; offset 1    ;  ds9 right side
1875   
1876                                ; *** bias voltages ***
1877      2.400000E+001             VOD       EQU     +24.0                             ; Output Drain 23
1878      1.450000E+001             VRD       EQU     +14.5                             ; Reset Drain  14.5
1879      -1.000000E+000            VOG       EQU     -1.0                              ; Output Gate  -1
1880   
1881                                ; *** clock voltages ***
1882      6.000000E+000             RG_HI     EQU     +6.0                              ; Reset Gate
1883      -0.000000E+000            RG_LO     EQU     -0.0                              ;
1884      5.000000E+000             S_HI      EQU     +5.0                              ; Serial clocks
1885      -5.000000E+000            S_LO      EQU     -5.0                              ;
1886      5.000000E+000             SW_HI     EQU     +5.0                              ; Summing Well
1887      -4.000000E+000            SW_LO     EQU     -4.0                              ;
1888   
1889      2.000000E+000             P_HI      EQU     +2.0                              ; +1
1890      -8.000000E+000            P_LO      EQU     -8.0                              ;
1891   
1892      3.500000E+000             MPP_HI    EQU     +3.5                              ;
1893      -6.000000E+000            MPP_LO    EQU     -6.0                              ;
1894   
1895      3.500000E+000             TG_HI     EQU     +3.5                              ; transfer gate
1896      -6.000000E+000            TG_LO     EQU     -6.0                              ;
1897   
1898                                ; *** misc ***
1899      2.400000E+001             VODA      EQU     VOD
1900      2.400000E+001             VODB      EQU     VOD
1901      -1.000000E+000            VOGA      EQU     VOG
1902      -1.000000E+000            VOGB      EQU     VOG
1903   
1904      5.000000E+000             S1R_HI    EQU     S_HI
1905      -5.000000E+000            S1R_LO    EQU     S_LO
1906      5.000000E+000             S2R_HI    EQU     S_HI
1907      -5.000000E+000            S2R_LO    EQU     S_LO
1908      5.000000E+000             S3_HI     EQU     S_HI
1909      -5.000000E+000            S3_LO     EQU     S_LO
1910      5.000000E+000             S1L_HI    EQU     S_HI
1911      -5.000000E+000            S1L_LO    EQU     S_LO
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  mont4k.asm  Page 36



1912      5.000000E+000             S2L_HI    EQU     S_HI
1913      -5.000000E+000            S2L_LO    EQU     S_LO
1914      2.000000E+000             P1_HI     EQU     P_HI
1915      -8.000000E+000            P1_LO     EQU     P_LO
1916      2.000000E+000             P2_HI     EQU     P_HI
1917      -8.000000E+000            P2_LO     EQU     P_LO
1918      2.000000E+000             P3_HI     EQU     P_HI
1919      -8.000000E+000            P3_LO     EQU     P_LO
1920   
1921      0.000000E+000             S3L_HI    EQU     0.0                               ; not used
1922      0.000000E+000             S3L_LO    EQU     0.0                               ; not used
1923   
1924      5.000000E+000             VB5       EQU     5.0                               ; not used
1925      7.500000E+000             VB6       EQU     +7.5                              ; Bias 6 (+7.5 - +30)
1926      0.000000E+000             VB7       EQU     0.0                               ; not used
1927   
1928   
1929                                ; *** configurations ****
1930   
1931                                          DEFINE  CHANNELS  '01'
1932   
1933                                          DEFINE  PDIR      'FORWARD'
1934                                          DEFINE  MODE      'MPP'
1935                                          DEFINE  CLOCKING  'clocking.asm'
1936   
1937                                ; *** DSP Y memory parameter table ***
1938                                ; Values in this block start at Y:0 and are overwritten by AzCam
1939                                ; All values are unbinned pixels unless noted.
1940   
1941      Y:000000 Y:000000         CAMSTAT   DC      0                                 ; not used
1942      Y:000001 Y:000001         NSDATA    DC      1                                 ; number BINNED serial columns in ROI
1943      Y:000002 Y:000002         NPDATA    DC      1                                 ; number of BINNED parallel rows in ROI
1944      Y:000003 Y:000003         NSBIN     DC      1                                 ; Serial binning parameter (>= 1)
1945      Y:000004 Y:000004         NPBIN     DC      1                                 ; Parallel binning parameter (>= 1)
1946   
1947      Y:000005 Y:000005         NSAMPS    DC      0                                 ; 0 => 1 amp, 1 => split serials
1948      Y:000006 Y:000006         NPAMPS    DC      0                                 ; 0 => 1 amp, 1 => split parallels
1949      Y:000007 Y:000007         NSCLEAR   DC      1                                 ; number of columns to clear during flush
1950      Y:000008 Y:000008         NPCLEAR   DC      1                                 ; number of rows to clear during flush
1951   
1952      Y:000009 Y:000009         NSPRESKIP DC      0                                 ; number of cols to skip before underscan
1953                                 NSUNDERSCAN
1954      Y:00000A Y:00000A                   DC      0                                 ; number of BINNED columns in underscan
1955      Y:00000B Y:00000B         NSSKIP    DC      0                                 ; number of cols to skip between underscan a
nd data
1956      Y:00000C Y:00000C         NSPOSTSKIP DC     0                                 ; number of cols to skip between data and ov
erscan
1957      Y:00000D Y:00000D         NSOVERSCAN DC     0                                 ; number of BINNED columns in overscan
1958   
1959      Y:00000E Y:00000E         NPPRESKIP DC      0                                 ; number of rows to skip before underscan
1960                                 NPUNDERSCAN
1961      Y:00000F Y:00000F                   DC      0                                 ; number of BINNED rows in underscan
1962      Y:000010 Y:000010         NPSKIP    DC      0                                 ; number of rows to skip between underscan a
nd data
1963      Y:000011 Y:000011         NPPOSTSKIP DC     0                                 ; number of rows to skip between data and ov
erscan
1964      Y:000012 Y:000012         NPOVERSCAN DC     0                                 ; number of BINNED rows in overscan
1965   
1966      Y:000013 Y:000013         NPXSHIFT  DC      0                                 ; number of rows to parallel shift
1967      Y:000014 Y:000014         TESTDATA  DC      0                                 ; 0 => normal, 1 => send incremented fake da
ta
1968      Y:000015 Y:000015         FRAMET    DC      0                                 ; number of storage rows for frame transfer 
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\TIM3.asm  Page 37



shift
1969      Y:000016 Y:000016         PREFLASH  DC      0                                 ; not used
1970      Y:000017 Y:000017         GAIN      DC      0                                 ; Video proc gain and integrator speed store
d here
1971      Y:000018 Y:000018         TST_DAT   DC      0                                 ; Place for synthetic test image pixel data
1972      Y:000019 Y:000019         SH_DEL    DC      100                               ; Delay (msecs) between shutter closing and 
image readout
1973      Y:00001A Y:00001A         CONFIG    DC      0                                 ; Controller configuration - was CC
1974      Y:00001B Y:00001B         NSIMAGE   DC      1                                 ; total number of columns in image
1975      Y:00001C Y:00001C         NPIMAGE   DC      1                                 ; total number of rows in image
1976      Y:00001D Y:00001D         PAD3      DC      0                                 ; unused
1977      Y:00001E Y:00001E         PAD4      DC      0                                 ; unused
1978      Y:00001F Y:00001F         IDLEONE   DC      2                                 ; lines to shift in IDLE (really 1)
1979   
1980                                ; Values in this block start at Y:20 and are overwritten if waveform table
1981                                ; is downloaded
1982      Y:000020 Y:000020         PMULT     DC      PARMULT                           ; parallel clock multiplier
1983      Y:000021 Y:000021         ACLEAR0   DC      TNOP                              ; Clear prologue - NOT USED
1984      Y:000022 Y:000022         ACLEAR2   DC      TNOP                              ; Clear epilogue - NOT USED
1985      Y:000023 Y:000023         AREAD0    DC      TNOP                              ; Read prologue - NOT USED
1986      Y:000024 Y:000024         AREAD8    DC      TNOP                              ; Read epilogue - NOT USED
1987      Y:000025 Y:000025         AFPXFER0  DC      FPXFER0                           ; Fast parallel transfer prologue
1988      Y:000026 Y:000026         AFPXFER2  DC      FPXFER2                           ; Fast parallel transfer epilogue
1989      Y:000027 Y:000027         APXFER    DC      PXFER                             ; Parallel transfer - storage only
1990      Y:000028 Y:000028         APDXFER   DC      PXFER                             ; Parallel transfer (data) - storage only
1991      Y:000029 Y:000029         APQXFER   DC      PQXFER                            ; Parallel transfer - storage and image
1992      Y:00002A Y:00002A         ARXFER    DC      RXFER                             ; Reverse parallel transfer (for focus)
1993      Y:00002B Y:00002B         AFSXFER   DC      FSXFER                            ; Fast serial transfer
1994      Y:00002C Y:00002C         ASXFER0   DC      SXFER0                            ; Serial transfer prologue
1995      Y:00002D Y:00002D         ASXFER1   DC      SXFER1                            ; Serial transfer ( * colbin-1 )
1996      Y:00002E Y:00002E         ASXFER2   DC      SXFER2                            ; Serial transfer epilogue - no data
1997      Y:00002F Y:00002F         ASXFER2D  DC      SXFER2D                           ; Serial transfer epilogue - data
1998      Y:000030 Y:000030         ADACS     DC      DACS
1999   
2000                                ; *** clock boards pins and states***
2001                                          INCLUDE "Mont4kClockPins.asm"
2002                                ; Switch state bits for clocks
2003                                ; mont4k pinout with split serials
2004   
2005                                ; low bank (usually CLK2)
2006      000000                    RGL       EQU     0                                 ;       CLK0    Pin 1
2007      000001                    RGH       EQU     1                                 ;       CLK0
2008      000000                    P1L       EQU     0                                 ;       CLK1    Pin 2
2009      000002                    P1H       EQU     2                                 ;       CLK1
2010      000000                    P2L       EQU     0                                 ;       CLK2    Pin 3
2011      000004                    P2H       EQU     4                                 ;       CLK2
2012      000000                    P3L       EQU     0                                 ;       CLK3    Pin 4
2013      000008                    P3H       EQU     8                                 ;       CLK3
2014      000000                    S1RL      EQU     0                                 ;       CLK4    Pin 5
2015      000010                    S1RH      EQU     $10                               ;       CLK4
2016      000000                    S3L       EQU     0                                 ;       CLK5    Pin 6
2017      000020                    S3H       EQU     $20                               ;       CLK5
2018      000000                    S2RL      EQU     0                                 ;       CLK6    Pin 7
2019      000040                    S2RH      EQU     $40                               ;       CLK6
2020      000000                    S3LL      EQU     0                                 ;       CLK7    Pin 8
2021      000080                    S3LH      EQU     $80                               ;       CLK7
2022      000000                    S2LL      EQU     0                                 ;       CLK8    Pin 9
2023      000100                    S2LH      EQU     $100                              ;       CLK8
2024      000000                    S1LL      EQU     0                                 ;       CLK9    Pin 10
2025      000200                    S1LH      EQU     $200                              ;       CLK9
2026      000000                    SWL       EQU     0                                 ;       CLK10   Pin 11
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\Mont4kClockPins.asm  Page 38



2027      000400                    SWH       EQU     $400                              ;       CLK10
2028      000000                    TGL       EQU     0                                 ;       CLK11   Pin 12
2029      000800                    TGH       EQU     $800                              ;       CLK11
2030   
2031                                ; high bank (usually CLK3) - not used
2032      000000                    Z1L       EQU     0                                 ;       CLK12   Pin 13
2033      001000                    Z1H       EQU     $1000                             ;       CLK12
2034      000000                    Z2L       EQU     0                                 ;       CLK13   Pin 14
2035      002000                    Z2H       EQU     $2000                             ;       CLK13
2036      000000                    Z3L       EQU     0                                 ;       CLK14   Pin 15
2037      004000                    Z3H       EQU     $4000                             ;       CLK14
2038      000000                    Z4L       EQU     0                                 ;       CLK15   Pin 16
2039      008000                    Z4H       EQU     $8000                             ;       CLK15
2040      000000                    Z5L       EQU     0                                 ;       CLK16   Pin 17
2041      010000                    Z5H       EQU     $10000                            ;       CLK16
2042      000000                    Z6L       EQU     0                                 ;       CLK17   Pin 18
2043      020000                    Z6H       EQU     $20000                            ;       CLK17
2044      000000                    Z7L       EQU     0                                 ;       CLK18   Pin 19
2045      040000                    Z7H       EQU     $40000                            ;       CLK18
2046      000000                    Z8L       EQU     0                                 ;       CLK19   Pin 33
2047      080000                    Z8H       EQU     $80000                            ;       CLK19
2048      000000                    Z9L       EQU     0                                 ;       CLK20   Pin 34
2049      100000                    Z9H       EQU     $100000                           ;       CLK20
2050      000000                    Z10L      EQU     0                                 ;       CLK21   Pin 35
2051      200000                    Z10H      EQU     $200000                           ;       CLK21
2052      000000                    Z11L      EQU     0                                 ;       CLK22   Pin 36
2053      400000                    Z11H      EQU     $400000                           ;       CLK22
2054      000000                    Z12L      EQU     0                                 ;       CLK23   Pin 37
2055      800000                    Z12H      EQU     $800000                           ;       CLK23
2056   
2057                                ; *** video definitions ***
2058                                          INCLUDE "GEN2VIDEO_defs.asm"
2059                                ; video definitions
2060   
2061                                ; *** define SXMIT based on selected channels ***
2062                                          IF      @SCP("01","0")
2064                                          ENDIF
2065                                          IF      @SCP("01","1")
2067                                          ENDIF
2068                                          IF      @SCP("01","2")
2070                                          ENDIF
2071                                          IF      @SCP("01","3")
2073                                          ENDIF
2074                                          IF      @SCP("01","01")
2075      00F040                    SXMIT     EQU     $00F040                           ; Transmit A/Ds = 0 to 1
2076                                          ENDIF
2077                                          IF      @SCP("01","23")
2079                                          ENDIF
2080                                          IF      @SCP("01","0123")
2082                                          ENDIF
2083   
2084                                ; *** shorthand for waveforms ***
2085      020000                    S_DELAY   EQU     @CVI((SERDEL-40)/40)<<16
2086      020000                    R_DELAY   EQU     @CVI((RSTDEL-40)/40)<<16
2087      020000                    V_DELAY   EQU     @CVI((VIDDEL-40)/40)<<16
2088      7C0000                    P_DELAY   EQU     @CVI((PARDEL-40)/40)<<16
2089      1A0000                    DWELL     EQU     @CVI((SAMPLE-40)/40)<<16
2090   
2091      020000                    VIDS      EQU     VIDEO+V_DELAY
2092   
2093                                INTNOISE  MACRO
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\GEN2VIDEO_defs.asm  Page 39



2094 m                              ; CDS integrate on noise
2095 m                                        DC      VIDS+%1110111                     ; Stop resetting integrator (video delay)
2096 m                                        DC      VIDEO+DWELL+%0000111              ; Integrate noise
2097 m                                        DC      VIDS+%0011011                     ; Stop Integrate, switch POL
2098 m                                        ENDM
2099   
2100                                INTSIGNAL MACRO
2101 m                              ; CDS integrate on signal
2102 m                                        DC      VIDS+%0011011                     ; Delay for Pgnal to settle
2103 m                                        DC      VIDEO+DWELL+%0001011              ; Integrate signal
2104 m                                        DC      VIDS+%0011011                     ; Stop integrate, clamp, reset, A/D is sampl
ing
2105 m                                        ENDM
2106   
2107                                LATCH     MACRO
2108 m                                        DC      VIDEO+%1110100
2109 m                                        ENDM
2110   
2111                                ; *** DACS table for video and clock boards ***
2112      Y:000031 Y:000031         DACS      DC      EDACS-DACS-1
2113                                          INCLUDE "GEN2VIDEO_dacs_brd0.asm"
2114                                ; GEN2VIDEO_dacs_brd0.asm
2115                                ; First Gen2 dual channel video board DACS table for video board addressed as board 0
2116                                ; 06Aug13 last change MPL
2117   
2118                                ; Set gain and integrator speed [$board-c3-speed-gain]
2119                                ;  speed: f => fast, c => slow
2120                                ;  gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
2121      Y:000032 Y:000032                   DC      $0c3cee                           ; x10 Gain, slow integrate, board #0
2122   
2123                                ; Output offset voltages
2124      Y:000033 Y:000033                   DC      $0c4000+OFFSETA+OFFSET            ; Output video offset, Output #A
2125      Y:000034 Y:000034                   DC      $0cc000+OFFSETB+OFFSET            ; Output video offset, Output #B
2126   
2127                                ; DC bias voltages
2128   
2129      Y:000035 Y:000035                   DC      $0d0000+@CVI((VODA-7.5)/22.5*4095) ; pin #1 (7.5-30)
2130      Y:000036 Y:000036                   DC      $0d4000+@CVI((VODB-7.5)/22.5*4095) ; pin #2 (7.5-30)
2131      Y:000037 Y:000037                   DC      $0d8000+@CVI((VRD-5.0)/15.0*4095) ; pin #3 (5-20)
2132      Y:000038 Y:000038                   DC      $0e0000+@CVI((5.0-5.0)/15.0*4095) ; pin #5 (5-20)   B5
2133      Y:000039 Y:000039                   DC      $0f0000+@CVI((5.0+5.0)/10.0*4095) ; pin #9 (-5-+5)  B7
2134      Y:00003A Y:00003A                   DC      $0f8000+@CVI((VOGA+10.0)/20.0*4095) ; pin #11 (-10-+10)
2135      Y:00003B Y:00003B                   DC      $0fc000+@CVI((VOGB+10.0)/20.0*4095) ; pin #12 (-10-+10)
2136   
2137                                ; end of GEN2VIDEO_dacs_brd0.asm
2138                                          INCLUDE "null.asm"
2139                                          INCLUDE "null.asm"
2140                                          INCLUDE "null.asm"
2141                                          INCLUDE "Mont4kClock_dacs.asm"
2142                                ; SDSU2 clock board DACS table
2143                                ; 06AUg13 last change MPL
2144                                ; This table is sent by the SETBIAS command to update clock board values.
2145                                ; The format is BBBB DDDD DDMM VVVV VVVV VVVV (board, DAC, Mode, Value)
2146   
2147                                ; modified for Mont4k clock names
2148   
2149      Y:00003C Y:00003C                   DC      (CLK2<<8)+(0<<14)+@CVI((RG_HI+10.0)/20.0*4095) ; RG High Pin 1
2150      Y:00003D Y:00003D                   DC      (CLK2<<8)+(1<<14)+@CVI((RG_LO+10.0)/20.0*4095) ; RG Low
2151      Y:00003E Y:00003E                   DC      (CLK2<<8)+(2<<14)+@CVI((P1_HI+10.0)/20.0*4095) ; P1 High Pin 2
2152      Y:00003F Y:00003F                   DC      (CLK2<<8)+(3<<14)+@CVI((P1_LO+10.0)/20.0*4095) ; P1 Low
2153      Y:000040 Y:000040                   DC      (CLK2<<8)+(4<<14)+@CVI((P2_HI+10.0)/20.0*4095) ; P2 High Pin 3
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  
C:\azcam\azcam-mont4k\azcam_mont4k\dspcode\dsptiming_spare\arc22timing\Mont4kClock_dacs.asm  Page 40



2154      Y:000041 Y:000041                   DC      (CLK2<<8)+(5<<14)+@CVI((P2_LO+10.0)/20.0*4095) ; P2 Low
2155   
2156      Y:000042 Y:000042                   DC      (CLK2<<8)+(6<<14)+@CVI((MPP_HI+10.0)/20.0*4095) ; P3 High Pin 4
2157      Y:000043 Y:000043                   DC      (CLK2<<8)+(7<<14)+@CVI((MPP_LO+10.0)/20.0*4095) ; P3 Low
2158   
2159      Y:000044 Y:000044                   DC      (CLK2<<8)+(8<<14)+@CVI((S1R_HI+10.0)/20.0*4095) ; S1R High  Pin 5
2160      Y:000045 Y:000045                   DC      (CLK2<<8)+(9<<14)+@CVI((S1R_LO+10.0)/20.0*4095) ; S1R Low
2161      Y:000046 Y:000046                   DC      (CLK2<<8)+(10<<14)+@CVI((S3_HI+10.0)/20.0*4095) ; S3 High   Pin 6
2162      Y:000047 Y:000047                   DC      (CLK2<<8)+(11<<14)+@CVI((S3_LO+10.0)/20.0*4095) ; S3 Low
2163      Y:000048 Y:000048                   DC      (CLK2<<8)+(12<<14)+@CVI((S2R_HI+10.0)/20.0*4095) ; S2R High  Pin 7
2164      Y:000049 Y:000049                   DC      (CLK2<<8)+(13<<14)+@CVI((S2R_LO+10.0)/20.0*4095) ; S2R Low
2165      Y:00004A Y:00004A                   DC      (CLK2<<8)+(14<<14)+@CVI((S3L_HI+10.0)/20.0*4095) ; S3L High  Pin 8
2166      Y:00004B Y:00004B                   DC      (CLK2<<8)+(15<<14)+@CVI((S3L_LO+10.0)/20.0*4095) ; S3L Low
2167      Y:00004C Y:00004C                   DC      (CLK2<<8)+(16<<14)+@CVI((S2L_HI+10.0)/20.0*4095) ; S2L High  Pin 9
2168      Y:00004D Y:00004D                   DC      (CLK2<<8)+(17<<14)+@CVI((S2L_LO+10.0)/20.0*4095) ; S2L Low
2169      Y:00004E Y:00004E                   DC      (CLK2<<8)+(18<<14)+@CVI((S1L_HI+10.0)/20.0*4095) ; S1L High  Pin 10
2170      Y:00004F Y:00004F                   DC      (CLK2<<8)+(19<<14)+@CVI((S1L_LO+10.0)/20.0*4095) ; S1L Low
2171      Y:000050 Y:000050                   DC      (CLK2<<8)+(20<<14)+@CVI((SW_HI+10.0)/20.0*4095) ; SW High   Pin 11
2172      Y:000051 Y:000051                   DC      (CLK2<<8)+(21<<14)+@CVI((SW_LO+10.0)/20.0*4095) ; SW Low
2173      Y:000052 Y:000052                   DC      (CLK2<<8)+(22<<14)+@CVI((TG_HI+10.0)/20.0*4095) ; TG High   Pin 12
2174      Y:000053 Y:000053                   DC      (CLK2<<8)+(23<<14)+@CVI((TG_LO+10.0)/20.0*4095) ; TG Low
2175                                          INCLUDE "null.asm"
2176                                EDACS
2177   
2178                                ; *** Timing NOP statement ***
2179      Y:000054 Y:000054         TNOP      DC      ETNOP-TNOP-GENCNT
2180      Y:000055 Y:000055                   DC      $00E000
2181      Y:000056 Y:000056                   DC      $00E000
2182                                ETNOP
2183   
2184                                ; *** waveforms ***
2185                                          INCLUDE "clocking.asm"
2186                                ; Mont4k clocking routines for Mont4k dewar
2187                                ; ARC22 clock board, SDSU clock and video boards
2188                                ; 08Aug13 last change MPL
2189   
2190                                ; ***********************************************
2191                                ;                  Definitions
2192                                ; ***********************************************
2193   
2194                                ; dump pars into S2
2195                                ; integrate normal mode under pars 1+2
2196   
2197                                ; ser_OSA.asm for mont4k at Mt. Bigelow - single output OSA
2198                                ; dump pars into S2
2199                                ; right is 231w, left is 132w
2200                                ; OSA is right side, OSB is left side
2201   
2202                                ; ser_OSB.asm for mont4k at Mt. Bigelow - single output OSB
2203                                ; dump pars into s1
2204   
2205                                ; ser_split.asm for mont4k at Mt. Bigelow - split readout
2206                                ; dump pars into S1L and S2R
2207   
2208                                          DEFINE  SDEF      'S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL'
2209   
2210                                          IF      @SCP("MPP","MPP")
2211                                          DEFINE  PDEF      'P1L+P2L+P3L+TGL'
2212                                          ENDIF
2213   
2214                                          IF      @SCP("MPP","NORMAL")
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  clocking.asm  Page 41



2216                                          ENDIF
2217   
2218                                ; ***********************************************
2219                                ;                  Parallel
2220                                ; ***********************************************
2221   
2222                                ; P shift, par_12_321t, reverse direction to amps
2223      Y:000057 Y:000057         PFOR      DC      EPFOR-PFOR-1
2224      Y:000058 Y:000058                   DC      VIDEO+%00110000
2225   
2226                                          IF      @SCP("MPP","MPP")
2227      Y:000059 Y:000059                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2L+P3L+TGL
2228      Y:00005A Y:00005A                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2L+P3H+TGH
2229      Y:00005B Y:00005B                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2L+P3H+TGH
2230      Y:00005C Y:00005C                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2H+P3H+TGH
2231      Y:00005D Y:00005D                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2H+P3L+TGL
2232      Y:00005E Y:00005E                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2H+P3L+TGL
2233      Y:00005F Y:00005F                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2L+P3L+TGL
2234                                          ENDIF
2235   
2236                                          IF      @SCP("MPP","NORMAL")
2243                                          ENDIF
2244                                EPFOR
2245   
2246                                ; P shift, par_12_123t, forward direction away from amps
2247      Y:000060 Y:000060         PREV      DC      EREV-PREV-1
2248      Y:000061 Y:000061                   DC      VIDEO+%00110000
2249   
2250                                          IF      @SCP("MPP","MPP")
2251      Y:000062 Y:000062                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2H+P3L+TGL
2252      Y:000063 Y:000063                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2H+P3H+TGH
2253      Y:000064 Y:000064                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2L+P3H+TGH
2254      Y:000065 Y:000065                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2L+P3H+TGH
2255      Y:000066 Y:000066                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2L+P3L+TGL
2256      Y:000067 Y:000067                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1H+P2H+P3L+TGL
2257      Y:000068 Y:000068                   DC      CLK2+P_DELAY+S1RL+S2RH+S3L+S1LH+S2LL+RGL+SWL+P1L+P2L+P3L+TGL
2258                                          ENDIF
2259   
2260                                          IF      @SCP("MPP","NORMAL")
2267                                          ENDIF
2268                                EREV
2269   
2270                                          IF      @SCP("FORWARD","FORWARD")
2271      000057                    PXFER     EQU     PFOR
2272      000060                    RXFER     EQU     PREV
2273                                          ENDIF
2274   
2275                                          IF      @SCP("FORWARD","REVERSE")
2278                                          ENDIF
2279   
2280      000057                    PQXFER    EQU     PXFER
2281   
2282                                ; ***********************************************
2283                                ;                 Serial
2284                                ; ***********************************************
2285                                ; dump pars into S2
2286                                ; right is 231w, left is 132w
2287                                ; OSA is right side, OSB is left side
2288   
2289      022000                    PARS      EQU     CLK2+P1L+P2L+P3L+TGL+S_DELAY
2290      022000                    PARR      EQU     CLK2+P1L+P2L+P3L+TGL+R_DELAY
2291   
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  clocking.asm  Page 42



2292      Y:000069 Y:000069         FPXFER0   DC      EFPXFER0-FPXFER0-GENCNT
2293      Y:00006A Y:00006A                   DC      PARS+RGH+S1RH+S2RH+S3H+S1LH+S2LH+SWH
2294      Y:00006B Y:00006B                   DC      PARS+RGH+S1RH+S2RH+S3H+S1LH+S2LH+SWH
2295                                EFPXFER0
2296   
2297                                ; end fast flush
2298      Y:00006C Y:00006C         FPXFER2   DC      EFPXFER2-FPXFER2-GENCNT
2299      Y:00006D Y:00006D                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
2300      Y:00006E Y:00006E                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
2301                                EFPXFER2
2302   
2303                                ; fast serial shift
2304      Y:00006F Y:00006F         FSXFER    DC      EFSXFER-FSXFER-GENCNT
2305      Y:000070 Y:000070                   DC      PARR+RGH+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2306      Y:000071 Y:000071                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2307      Y:000072 Y:000072                   DC      PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
2308      Y:000073 Y:000073                   DC      PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
2309      Y:000074 Y:000074                   DC      PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
2310      Y:000075 Y:000075                   DC      PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
2311      Y:000076 Y:000076                   DC      PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
2312      Y:000077 Y:000077                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
2313                                EFSXFER
2314   
2315      Y:000078 Y:000078         SXFER0    DC      ESXFER0-SXFER0-GENCNT
2316      Y:000079 Y:000079                   DC      PARR+RGH+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2317      Y:00007A Y:00007A                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2318      Y:00007B Y:00007B                   DC      VIDS+%1110100
2319      Y:00007C Y:00007C                   DC      PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
2320      Y:00007D Y:00007D                   DC      PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
2321      Y:00007E Y:00007E                   DC      PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
2322      Y:00007F Y:00007F                   DC      PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
2323      Y:000080 Y:000080                   DC      PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
2324      Y:000081 Y:000081                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2325                                ESXFER0
2326   
2327      Y:000082 Y:000082         SXFER1    DC      ESXFER1-SXFER1-GENCNT             ; (bin-1) times
2328      Y:000083 Y:000083                   DC      PARS+RGL+S1RL+S2RH+S3H+S1LH+S2LL+SWH
2329      Y:000084 Y:000084                   DC      PARS+RGL+S1RL+S2RL+S3H+S1LL+S2LL+SWH
2330      Y:000085 Y:000085                   DC      PARS+RGL+S1RH+S2RL+S3H+S1LL+S2LH+SWH
2331      Y:000086 Y:000086                   DC      PARS+RGL+S1RH+S2RL+S3L+S1LL+S2LH+SWH
2332      Y:000087 Y:000087                   DC      PARS+RGL+S1RH+S2RH+S3L+S1LH+S2LH+SWH
2333      Y:000088 Y:000088                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWH
2334                                ESXFER1
2335   
2336      Y:000089 Y:000089         SXFER2    DC      ESXFER2-SXFER2-GENCNT
2337   
2338                                ; CDS integrate on noise
2339      Y:00008A Y:00008A                   DC      VIDS+%1110111                     ; Stop resetting integrator
2340      Y:00008B Y:00008B                   DC      VIDEO+DWELL+%0000111              ; Integrate noise
2341      Y:00008C Y:00008C                   DC      VIDEO+%0011011                    ; Stop Integrate, switch POL
2342   
2343      Y:00008D Y:00008D                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
2344   
2345                                ; CDS integrate on signal
2346      Y:00008E Y:00008E                   DC      VIDS+%0011011                     ; Delay for Pgnal to settle
2347      Y:00008F Y:00008F                   DC      VIDEO+DWELL+%0001011              ; Integrate signal
2348      Y:000090 Y:000090                   DC      VIDEO+%0011011                    ; Stop integrate, clamp, reset, A/D sampling
2349                                ESXFER2
2350   
2351      Y:000091 Y:000091         SXFER2D   DC      ESXFER2D-SXFER2D-GENCNT
2352      Y:000092 Y:000092                   DC      SXMIT                             ; Transmit A/D data to host
2353   
Motorola DSP56300 Assembler  Version 6.3.4   22-03-07  09:23:44  clocking.asm  Page 43



2354                                ; CDS integrate on noise
2355      Y:000093 Y:000093                   DC      VIDS+%1110111                     ; Stop resetting integrator
2356      Y:000094 Y:000094                   DC      VIDEO+DWELL+%0000111              ; Integrate noise
2357      Y:000095 Y:000095                   DC      VIDEO+%0011011                    ; Stop Integrate, switch POL
2358   
2359      Y:000096 Y:000096                   DC      PARS+RGL+S1RL+S2RH+S3L+S1LH+S2LL+SWL
2360   
2361                                ; CDS integrate on signal
2362      Y:000097 Y:000097                   DC      VIDS+%0011011                     ; Delay for Pgnal to settle
2363      Y:000098 Y:000098                   DC      VIDEO+DWELL+%0001011              ; Integrate signal
2364      Y:000099 Y:000099                   DC      VIDEO+%0011011                    ; Stop integrate, clamp, reset, A/D sampling
2365                                ESXFER2D
2366   
2367   
2368                                 END_APPLICATON_Y_MEMORY
2369      00009A                              EQU     @LCV(L)
2370   
2371                                          END

0    Errors
0    Warnings


