Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 1



1                               COMMENT *
2      
3                        This file is used to generate boot DSP code for the utility board.
4                        This software is for use with the timIII = 250 MHz board.
5      
6                                *
7                                  PAGE    132                               ; Printronix page width - 132 columns
8      
9                        ; Define some useful DSP register locations
10        000000         RST_ISR   EQU     $00                               ; Hardware reset interrupt
11        000006         ROM_ID    EQU     $06                               ; Location of ROM Identification words = SWI interrupt
12        000008         IRQA_ISR  EQU     $08                               ; Address of ISRA for 1 kHz timer interrupts
13        000014         SCI_ISR   EQU     $14                               ; SCI Receive data interrupt address
14        000016         SCI_ERR   EQU     $16                               ; SCI Receive with exception address
15        00000A         START     EQU     $0A                               ; Address for beginning of code
16        000018         CONTINUE  EQU     $18                               ; Address for beginning of code
17        000080         BUF_STR   EQU     $80                               ; Starting address of buffers in X:
18        000020         BUF_LEN   EQU     $20                               ; Length of each buffer
19        000080         SCI_BUF   EQU     BUF_STR                           ; Starting address of SCI buffer in X:
20        0000A0         COM_BUF   EQU     SCI_BUF+BUF_LEN                   ; Starting address of command buffer in X:
21        0000C0         COM_TBL   EQU     COM_BUF+BUF_LEN                   ; Starting address of command table in X:
22        000018         NUM_COM   EQU     24                                ; Number of entries in the command table
23        000682         TIMEOUT   EQU     1666                              ; Timeout for receiving complete command = 1 millisec
24        000090         APL_ADR   EQU     $90                               ; Starting address of application program
25        001EE0         APL_XY    EQU     $1EE0                             ; Start of application data tables
26        006000         RST_OFF   EQU     $6000                             ; Reset code offset in EEPROM
27        006040         P_OFF     EQU     $6040                             ; P: memory offset into EEPROM
28        006100         X_OFF     EQU     $6100                             ; X: memory offset into EEPROM
29        006200         ROM_EXE   EQU     $6200                             ; P: start address for routines that execute from EEPRO
M
30        000046         DLY_MUX   EQU     70                                ; Number of DSP cycles to delay for MUX settling
31        000064         DLY_AD    EQU     100                               ; Number of DSP cycles to delay for A/D settling
32     
33                       ; Now assign a bunch of addresses to on-chip functions
34        00FFFE         BCR       EQU     $FFFE                             ; Bus (=Port A) Control Register -> Wait States
35        00FFE1         PCC       EQU     $FFE1                             ; Port C Control Register
36        00FFE0         PBC       EQU     $FFE0                             ; Port B Control Register
37        00FFE2         PBDDR     EQU     $FFE2                             ; Port B Data Direction Register
38        00FFE4         PBD       EQU     $FFE4                             ; Port B Data Register
39        00FFF0         SCR       EQU     $FFF0                             ; SCI Control Register
40        00FFF1         SSR       EQU     $FFF1                             ; SCI Status Register
41        00FFF2         SCCR      EQU     $FFF2                             ; SCI Clock Control Register
42        00FFF4         SRX       EQU     $FFF4                             ; SCI Receiver low address byte
43        00FFFF         IPR       EQU     $FFFF                             ; Interrupt Priority Register
44     
45                       ; Addresses of memory mapped components in Y: data memory space
46                       ;  Write addresses first
47        00FFF0         WR_DIG    EQU     $FFF0                             ; Write Digital output values D00-D15
48        00FFF1         WR_MUX    EQU     $FFF1                             ; Select MUX connected to A/D input - one of 16
49        00FFF2         EN_DIG    EQU     $FFF2                             ; Enable digital outputs
50        00FFF7         WR_DAC3   EQU     $FFF7                             ; Write to DAC#3 D00-D11
51        00FFF6         WR_DAC2   EQU     $FFF6                             ; Write to DAC#2 D00-D11
52        00FFF5         WR_DAC1   EQU     $FFF5                             ; Write to DAC#1 D00-D11
53        00FFF4         WR_DAC0   EQU     $FFF4                             ; Write to DAC#0 D00-D11
54     
55                       ; Read addresses next
56        00FFF0         RD_DIG    EQU     $FFF0                             ; Read Digital input values D00-D15
57        00FFF1         STR_ADC   EQU     $FFF1                             ; Start A/D conversion, ignore data
58        00FFF2         RD_ADC    EQU     $FFF2                             ; Read A/D converter value D00-D11
59        00FFF7         WATCH     EQU     $FFF7                             ; Watch dog timer - tell it that DSP is alive
60     
61                       ; Bit definitions of STATUS word
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 2



62        000000         ST_SRVC   EQU     0                                 ; Set if SERVICE routine needs executing
63        000001         ST_EX     EQU     1                                 ; Set if timed exposure is in progress
64        000002         ST_SH     EQU     2                                 ; Set if shutter is open
65        000003         ST_READ   EQU     3                                 ; Set if a readout needs to be initiated
66     
67                       ; Bit definitions of software OPTIONS word
68        000000         OPT_SH    EQU     0                                 ; Set to open and close shutter
69     
70                       ; Bit definitions of Port B = Host Processor Interface
71        000000         HVEN      EQU     0                                 ; Enable high voltage PS (+36V nominal) - Output
72        000001         LVEN      EQU     1                                 ; Enable low voltage PS (+/-15 volt nominal) - Output
73        000002         PWRST     EQU     2                                 ; Reset power conditioner counter - Output
74        000003         SHUTTER   EQU     3                                 ; Control shutter - Output
75        000004         IRQ_T     EQU     4                                 ; Request interrupt service from timing board - Output
76        000005         SYS_RST   EQU     5                                 ; Reset entire system - Output
77        000008         WATCH_T   EQU     8                                 ; Processed watchdog signal from timing board - Input
78        000009         PWREN     EQU     9                                 ; Enable power conditioner board - Output
79     
80                       ;**************************************************************************
81                       ;                                                                         *
82                       ;    Register assignments                                                 *
83                       ;        R1 - Address of SCI receiver contents                            *
84                       ;        R2 - Address of processed SCI receiver contents                  *
85                       ;        R3 - Pointer to current top of command buffer                    *
86                       ;        R4 - Pointer to processed contents of command buffer             *
87                       ;        N4 - Address for internal jumps after receiving 'DON' replies    *
88                       ;        R0, R5, R6, A, X0, X1 - Freely available for program use         *
89                       ;        R7 - For use by SCI ISR only                                     *
90                       ;        B, Y0 and Y1 - For use by timer ISR only                         *
91                       ;                                                                         *
92                       ;**************************************************************************
93     
94                       ; Initialize the DSP. Because this is executed only on DSP boot from ROM
95                       ;  it is not incorporated into any download code.
96     
97        P:6000 P:6000                   ORG     P:RST_OFF,P:RST_OFF
98     
99        P:6000 P:6000 0502BA            MOVEC             #$02,OMR                ; Normal expanded mode
100       P:6001 P:6001 000000            NOP                                       ; Allow time for the remapping to occur
101       P:6002 P:6002 0AF080            JMP     INIT                              ; DSP resets to $E000, but we load program
                        006004
102                                                                                 ;   to EEPROM starting at RST_OFF = $6000
103    
104       P:6004 P:6004 08F4A4  INIT      MOVEP             #$0238,X:PBD            ; Power enables off, shutter high
                        000238
105                                                                                 ;  (closed), IRQA, SYSRST
106                                                                                 ;  LVEN = HVEN = 1 => all power off
107    
108       P:6006 P:6006 08F4A2            MOVEP             #$0238,X:PBDDR          ; H2 - H5, H9 Outputs, H0 - H2, H6 - H8 Inputs
                        000238
109    
110       P:6008 P:6008 0003F8            ORI     #$03,MR                           ; Temporarily mask interrupts
111    
112       P:6009 P:6009 08F4B0            MOVEP             #$0B04,X:SCR            ; SCI programming: 11-bit asynchronous
                        000B04
113                                                                                 ;   protocol (1 start, 8 data, 1 even parity,
114                                                                                 ;   1 stop); LSB before MSB; enable receiver
115                                                                                 ;   and its interrupt; transmitter interrupts
116                                                                                 ;   disabled.
117    
118       P:600B P:600B 08F4B2            MOVEP             #$0000,X:SCCR           ; SCI clock: maximum asynchronous data
                        000000
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 3



119                                                                                 ;   rate (390,625 kbits/sec); internal clock.
120    
121       P:600D P:600D 08F4A1            MOVEP             #>$03,X:PCC             ; Select Port C pins 1 and 2 for the SCI.
                        000003
122    
123       P:600F P:600F 08F4BE            MOVEP             #$0033,X:BCR            ; Wait states for external memory accesses
                        000033
124                                                                                 ;   3 for PROM = 150 nsec
125                                                                                 ;   3 for A/D, DAC, etc. = 150 nsec
126    
127                             ; Load boot program into P: memory from EEPROM
128       P:6011 P:6011 60F400            MOVE              #P_OFF,R0               ; Starting P: address in EEPROM
                        006040
129       P:6013 P:6013 310000            MOVE              #0,R1                   ; Put values starting at beginning of P:
130       P:6014 P:6014 069280            DO      #APL_ADR+2,P_MOVE                 ; Boot program is APL_ADR words long
                        006017
131                                                                                 ;     +2 is for SERVICE and TIMER stubs
132       P:6016 P:6016 07D88E            MOVE              P:(R0)+,A               ; Get one word from EEPROM
133       P:6017 P:6017 07598E            MOVE              A,P:(R1)+               ; Write it to DSP P: memory
134                             P_MOVE
135    
136                             ; Load X: data memory from EEPROM
137       P:6018 P:6018 60F400            MOVE              #X_OFF,R0               ; Starting X: address in EEPROM
                        006100
138       P:601A P:601A 310000            MOVE              #0,R1                   ; Put values starting at beginning of X:
139       P:601B P:601B 060081            DO      #$100,X_MOVE                      ; Assume 256 = $100 values exist
                        00601E
140       P:601D P:601D 07D88E            MOVE              P:(R0)+,A               ; Get one word from EEPROM
141       P:601E P:601E 565900            MOVE              A,X:(R1)+               ; Write it to DSP X: memory
142                             X_MOVE
143    
144                             ; Initialize various registers
145       P:601F P:601F 318000            MOVE              #SCI_BUF,R1
146       P:6020 P:6020 33A000            MOVE              #COM_BUF,R3
147       P:6021 P:6021 223200            MOVE              R1,R2
148       P:6022 P:6022 227400            MOVE              R3,R4
149       P:6023 P:6023 051FA1            MOVE              #31,M1                  ; Create circular buffers, modulo 32
150       P:6024 P:6024 0462A1            MOVE              M1,M2
151       P:6025 P:6025 0463A2            MOVE              M2,M3
152       P:6026 P:6026 0464A3            MOVE              M3,M4
153       P:6027 P:6027 3C0A00            MOVE              #<START,N4
154       P:6028 P:6028 678900            MOVE              X:<SRX_FST,R7           ; Starting address of SCI receiver
155       P:6029 P:6029 200013            CLR     A
156       P:602A P:602A 20001B            CLR     B
157    
158                             ; Set interrupt priorities levels
159       P:602B P:602B 08F4BF            MOVEP             #$8007,X:IPR            ; Enable IRQA = timer
                        008007
160                                                                                 ; Change priorities for operation
161                                                                                 ;   SCI = 1 = link to timing board
162                                                                                 ;   IRQA = 2 = timer
163                                                                                 ;   Host = SSI = IRQB = 0 = disabled
164       P:602D P:602D 00FCB8            ANDI    #$FC,MR                           ; Unmask all interrupt levels
165       P:602E P:602E 0C0040            JMP     <XMT_CHK
166    
167                             ;  *****  Put interrupt service routine vectors in their required places  *****
168                             ; After RESET jump to initialization code
169       P:0000 P:6040                   ORG     P:RST_ISR,P:RST_ISR+P_OFF
170       P:0000 P:6040 0AF080            JMP     INIT                              ; This is the interrupt service for RESET
                        006004
171    
172                             ; The IRQA ISR is a long interrupt keyed to the 1 millisecond timer
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 4



173       P:0008 P:6048                   ORG     P:IRQA_ISR,P:IRQA_ISR+P_OFF
174       P:0008 P:6048 0BF080            JSR     TIMER                             ; Jump to long TIMER routine for service
                        000091
175    
176                             ; The SCI interrupts when it receives data from the timing board.
177       P:0014 P:6054                   ORG     P:SCI_ISR,P:SCI_ISR+P_OFF
178       P:0014 P:6054 0BF080            JSR     SCI_RCV                           ; SCI Receive data interrupt service routine
                        00006A
179    
180                             ; The SCI interrupts to here when there is an error.
181       P:0016 P:6056                   ORG     P:SCI_ERR,P:SCI_ERR+P_OFF
182       P:0016 P:6056 0BF080            JSR     CLR_ERR
                        00007A
183    
184                             ; Put the ID words for this version of the ROM code. It is placed at
185                             ;   the address of the SWI = software interrupt, which we never use.
186       P:0006 P:6046                   ORG     P:ROM_ID,P:ROM_ID+P_OFF
187       P:0006 P:6046                   DC      $000000                           ; Institution
188                                                                                 ; Location
189                                                                                 ; Instrument
190       P:0007 P:6047                   DC      $030003                           ; Version 3.00, Board #3 = Utility
191    
192                             ; Start the command interpreting code
193       P:000A P:604A                   ORG     P:START,P:START+P_OFF
194    
195                             ; Check for TIMER interrupts and go handle them if necessary
196       P:000A P:604A 0B00A0            JSSET   #ST_SRVC,X:STATUS,SERVICE         ; Do all millisecond service tasks
                        000090
197       P:000C P:604C 094E37            MOVEP             Y:WATCH,A               ; Reset watchdog timer
198    
199                             ; Test SCI receiver pointers
200       P:000D P:604D 222E00            MOVE              R1,A                    ; Pointer to current contents of receiver
201       P:000E P:604E 224400            MOVE              R2,X0                   ; Pointer to processed contents
202       P:000F P:604F 45E245            CMP     X0,A      X:(R2),X1               ; Are they equal? Get header
203       P:0010 P:6050 0EA036            JEQ     <TST_COM                          ; Yes, so check the receiver stack
204    
205                             ; Jump over the ISRs
206       P:0011 P:6051 0C0018            JMP     <CONTINUE
207       P:0018 P:6058                   ORG     P:CONTINUE,P:CONTINUE+P_OFF
208    
209                             ; Check candidate header = (S,D,N) for self-consistency
210       P:0018 P:6058 549100            MOVE              X:<MASK1,A1             ; Test for S.LE.3 and D.LE.3 and N.LE.7
211       P:0019 P:6059 200066            AND     X1,A                              ; X1 = header from above
212       P:001A P:605A 0E2021            JNE     <RCV_SKP                          ; Test failed, skip over header
213       P:001B P:605B 549200            MOVE              X:<MASK2,A1             ; Test for S.NE.0 or D.NE.0
214       P:001C P:605C 200066            AND     X1,A
215       P:001D P:605D 0EA021            JEQ     <RCV_SKP                          ; Test failed, skip over header
216       P:001E P:605E 2C0700            MOVE              #7,A1                   ; Test for N.GE.1
217       P:001F P:605F 200066            AND     X1,A                              ; A = NWORDS in command
218       P:0020 P:6060 0E2023            JNE     <RCV_PR                           ; Test suceeded - process command
219       P:0021 P:6061 205A00  RCV_SKP   MOVE              (R2)+                   ; Header is wrong - skip over it
220       P:0022 P:6062 0C000A            JMP     <START                            ; Keep monitoring receiver
221    
222                             ; Get all the words of the command before processing it
223       P:0023 P:6063 21C500  RCV_PR    MOVE              A,X1                    ; Number of words in command header
224       P:0024 P:6064 068286            DO      #<TIMEOUT,TIM_OUT
                        000030
225       P:0026 P:6066 222E00            MOVE              R1,A
226       P:0027 P:6067 224400            MOVE              R2,X0
227       P:0028 P:6068 200044            SUB     X0,A
228       P:0029 P:6069 0E102C            JGE     <RCV_L1                           ; X1 = Destination mask $00FF00
229       P:002A P:606A 448E00            MOVE              X:<C32,X0               ; Correct for circular buffer
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 5



230       P:002B P:606B 200040            ADD     X0,A                              ; No MOVE here - it isn't always executed
231       P:002C P:606C 450265  RCV_L1    CMP     X1,A      X1,X:<NWORDS
232       P:002D P:606D 0E9030            JLT     <RCV_L2
233       P:002E P:606E 00008C            ENDDO
234       P:002F P:606F 0C0032            JMP     <MV_COM
235       P:0030 P:6070 000000  RCV_L2    NOP
236                             TIM_OUT
237       P:0031 P:6071 0C0021            JMP     <RCV_SKP                          ; Increment R2 and BAD_HDR
238    
239                             ; We've got the complete SCI command, so put it on the COM_BUF stack
240       P:0032 P:6072 060200  MV_COM    DO      X:<NWORDS,SCI_WR
                        000035
241       P:0034 P:6074 56DA00            MOVE              X:(R2)+,A               ; R2 = SCI address
242       P:0035 P:6075 565B00            MOVE              A,X:(R3)+               ; R3 = command buffer address
243                             SCI_WR
244    
245                             ; Test the command stack too
246       P:0036 P:6076 226E00  TST_COM   MOVE              R3,A                    ; Pointer to current contents of receiver
247       P:0037 P:6077 228400            MOVE              R4,X0                   ; Pointer to processed contents
248       P:0038 P:6078 459845            CMP     X0,A      X:<DMASK,X1             ; Are they equal? Get destination mask
249       P:0039 P:6079 0EA00A            JEQ     <START                            ; Go back to the top
250    
251                             ; Process the receiver entry - is its destination number = D_BRD_ID?
252       P:003A P:607A 56E400            MOVE              X:(R4),A                ; Get the header
253       P:003B P:607B 560300            MOVE              A,X:<HDR_ID             ; Store it for later use
254       P:003C P:607C 459766            AND     X1,A      X:<DBRDID,X1            ; Extract destination byte only
255       P:003D P:607D 200065            CMP     X1,A                              ; = destination number?
256       P:003E P:607E 0EA047            JEQ     <COMMAND                          ; It's a command for this board
257       P:003F P:607F 0E7059            JGT     <ERROR                            ; Destination byte > #DBRDID, so error
258    
259                             ; Transmit command over SCI back to the timing board
260       P:0040 P:6080 226E00  XMT_CHK   MOVE              R3,A
261       P:0041 P:6081 228400            MOVE              R4,X0
262       P:0042 P:6082 200045            CMP     X0,A                              ; R4 is incremented by SCI_XMT
263       P:0043 P:6083 0EA00A            JEQ     <START                            ; We're all done, so start processing anew
264       P:0044 P:6084 0BB1A0            JSSET   #0,X:SSR,SCI_XMT                  ; If SCI XMT register is empty, transmit byte
                        00007F
265       P:0046 P:6086 0C0040            JMP     <XMT_CHK                          ; Keep looping
266    
267                             ; Process the command - is it in the command table ?
268       P:0047 P:6087 205C00  COMMAND   MOVE              (R4)+                   ; Increment over the header
269       P:0048 P:6088 56DC00            MOVE              X:(R4)+,A               ; Get the command buffer entry
270       P:0049 P:6089 30C000            MOVE              #<COM_TBL,R0            ; Get command table address
271       P:004A P:608A 061880            DO      #NUM_COM,END_COM                  ; Loop over command table
                        000051
272       P:004C P:608C 44D800            MOVE              X:(R0)+,X0              ; Get the command table entry
273       P:004D P:608D 65E045            CMP     X0,A      X:(R0),R5               ; Are the receiver and table entries the same?
274       P:004E P:608E 0E2051            JNE     <NOT_COM                          ; No, keep looping
275       P:004F P:608F 00008C            ENDDO                                     ; Restore the DO loop system registers
276       P:0050 P:6090 0AE580            JMP     (R5)                              ; Jump execution to the command
277       P:0051 P:6091 205800  NOT_COM   MOVE              (R0)+                   ; Increment the register past the table address
278                             END_COM
279    
280                             ; Step over the remaining words in the command if there's an error
281       P:0052 P:6092 568200            MOVE              X:<NWORDS,A
282       P:0053 P:6093 448D00            MOVE              X:<TWO,X0
283       P:0054 P:6094 200044            SUB     X0,A                              ; Header and command have been processed
284       P:0055 P:6095 0EA059            JEQ     <ERROR
285       P:0056 P:6096 06CE00            DO      A,INCR_R4
                        000058
286       P:0058 P:6098 205C00            MOVE              (R4)+                   ; Increment over unprocessed part of comamnd
287                             INCR_R4
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 6



288    
289       P:0059 P:6099 449E00  ERROR     MOVE              X:<ERR,X0               ; Send the message - there was an error
290       P:005A P:609A 0C005C            JMP     <FINISH1                          ; This protects against unknown commands
291    
292                             ; Command execution is nearly over - generate header and message.
293       P:005B P:609B 449F00  FINISH    MOVE              X:<DON,X0               ; Send a DONE message as a reply
294       P:005C P:609C 568300  FINISH1   MOVE              X:<HDR_ID,A             ; Get header of incoming command
295       P:005D P:609D 459900            MOVE              X:<SMASK,X1             ; This was the source byte, and is to
296       P:005E P:609E 458D66            AND     X1,A      X:<TWO,X1               ;   become the destination byte
297       P:005F P:609F 0608A0            REP     #8                                ; Shift right one byte, add it to the
298       P:0060 P:60A0 450223            LSR     A         X1,X:<NWORDS            ;     header, and put 2 as the number
299       P:0061 P:60A1 459660            ADD     X1,A      X:<SBRDID,X1            ;  of words in the string
300       P:0062 P:60A2 200060            ADD     X1,A
301       P:0063 P:60A3 565B00            MOVE              A,X:(R3)+               ; Put header on the transmitter stack
302       P:0064 P:60A4 445B00            MOVE              X0,X:(R3)+              ; Put value of X0 on the transmitter stack
303       P:0065 P:60A5 0C0040            JMP     <XMT_CHK                          ; Go transmit
304    
305                             ; Delay after EEPROM write in DSP internal memory because code cannot
306                             ;   execute from EEPROM during a write operation
307       P:0066 P:60A6 061500  DLY_ROM   DO      X:<C50000,LP_WRR
                        000068
308       P:0068 P:60A8 094E37            MOVEP             Y:WATCH,A               ; Delay 10 millisec for EEPROM write
309                             LP_WRR
310       P:0069 P:60A9 0C005B            JMP     <FINISH
311    
312                             ; This ISR receives serial words a byte at a time over the asynchronous
313                             ;   serial link (SCI) and squashes them into a single 24-bit word
314       P:006A P:60AA 050439  SCI_RCV   MOVEC             SR,X:<SAVE_SR           ; Save Status Register
315       P:006B P:60AB 540600            MOVE              A1,X:<SAVE_A1           ; Save A1
316       P:006C P:60AC 450500            MOVE              X1,X:<SAVE_X1           ; Save X1
317       P:006D P:60AD 548A00            MOVE              X:<SRX_A1,A1            ; Get SRX value of accumulator contents
318       P:006E P:60AE 45E700            MOVE              X:(R7),X1               ; Get the SCI byte
319       P:006F P:60AF 0AD741            BCLR    #1,R7                             ; Test for the address being $FFF6 = last byte
320       P:0070 P:60B0 205F62            OR      X1,A      (R7)+                   ; Add the byte into the 24-bit word
321       P:0071 P:60B1 0E0075            JCC     <MID_BYT                          ; Not the last byte => only restore registers
322       P:0072 P:60B2 545900  END_BYT   MOVE              A1,X:(R1)+              ; Put the 24-bit word into the SCI buffer
323       P:0073 P:60B3 678900            MOVE              X:<SRX_FST,R7           ; Restablish first address of SCI interface
324       P:0074 P:60B4 2C0000            MOVE              #0,A1                   ; For zeroing out SRX_A1
325       P:0075 P:60B5 540A00  MID_BYT   MOVE              A1,X:<SRX_A1            ; Save A1 for next interrupt
326       P:0076 P:60B6 058439            MOVEC             X:<SAVE_SR,SR           ; Restore Status Register
327       P:0077 P:60B7 548600            MOVE              X:<SAVE_A1,A1           ; Restore A1
328       P:0078 P:60B8 458500            MOVE              X:<SAVE_X1,X1           ; Restore X1
329       P:0079 P:60B9 000004            RTI                                       ; Return from interrupt service
330    
331                             ; Clear error condition and interrupt on SCI receiver
332       P:007A P:60BA 0870B1  CLR_ERR   MOVEP             X:SSR,X:RCV_ERR         ; Read SCI status register
                        000007
333       P:007C P:60BC 0870B4            MOVEP             X:SRX,X:RCV_ERR         ; This clears any error
                        000007
334       P:007E P:60BE 000004            RTI
335    
336                             ; Transmit 24-bit words over the SCI serial link to the timing board
337                             ; Accumulator A does not have to be saved and restored because XMT_CHK
338                             ;   sets it each time it is needed.
339       P:007F P:60BF 608800  SCI_XMT   MOVE              X:<STX_ADR,R0           ; Restore the starting address of the SCI
340       P:0080 P:60C0 56E400            MOVE              X:(R4),A
341       P:0081 P:60C1 566000            MOVE              A,X:(R0)                ; Transmit buffer
342       P:0082 P:60C2 0AD041            BCLR    #1,R0                             ; Test for last SCI address = $FFF6
343       P:0083 P:60C3 0E8087            JCS     <DON_XMT                          ; If address = $FFF6 clean up
344       P:0084 P:60C4 205800            MOVE              (R0)+
345       P:0085 P:60C5 600800            MOVE              R0,X:<STX_ADR           ; Restore the starting address of the SCI
346       P:0086 P:60C6 00000C            RTS
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 7



347    
348                             ; We're done tranmitting the three bytes of each 24-bit DSP word.
349       P:0087 P:60C7 205C00  DON_XMT   MOVE              (R4)+
350       P:0088 P:60C8 600800            MOVE              R0,X:<STX_ADR           ; Restore starting address of SCI = $FFF4
351       P:0089 P:60C9 00000C            RTS
352    
353                             ; Check for overflow
354                                       IF      @CVS(N,*)>APL_ADR
356                                       ENDIF                                     ;  will not be overwritten
357    
358                             ; Specify the memory location where the application program is to be loaded
359       P:0090 P:60D0                   ORG     P:APL_ADR,P:APL_ADR+P_OFF
360    
361                             ; Define TIMER as a simple jump addresses so the "bootrom" program
362                             ;   can work until the application program can be loaded
363       P:0090 P:60D0 00000C  SERVICE   RTS                                       ; Just return from subroutine call
364       P:0091 P:60D1 000004  TIMER     RTI                                       ; Just return from interrupt
365    
366                             ; The following boot routines execute directly from EEPROM, one 24-bit word
367                             ;   at a time. Two reasons for this - to conserve DSP P: space, and to allow
368                             ;   reading or writing to EEPROM space that overlaps with the P: internal
369                             ;   DSP memory space.
370    
371       P:6200 P:6200                   ORG     P:ROM_EXE,P:ROM_EXE
372    
373                             ; Test Data Link - simply return value received after 'TDL'
374       P:6200 P:6200 44DC00  TDL       MOVE              X:(R4)+,X0              ; Get data value
375       P:6201 P:6201 0C005C            JMP     <FINISH1                          ; Return from executing TDL command
376    
377                             ; Its a read from DSP memory - get the data and send it over the link
378       P:6202 P:6202 60E400  RDMEM     MOVE              X:(R4),R0               ; Need the address in an address register
379       P:6203 P:6203 44DC00            MOVE              X:(R4)+,X0              ; Need address also in a 24-bit register
380       P:6204 P:6204 0AC414            JCLR    #20,X0,RDX                        ; Test address bit for Program memory
                        006208
381       P:6206 P:6206 07E084            MOVE              P:(R0),X0               ; Read from Program memory
382       P:6207 P:6207 0C005C            JMP     <FINISH1                          ; Send out a header with the value
383       P:6208 P:6208 0AC415  RDX       JCLR    #21,X0,RDY                        ; Test address bit for X: memory
                        00620C
384       P:620A P:620A 44E000            MOVE              X:(R0),X0               ; Write to X data memory
385       P:620B P:620B 0C005C            JMP     <FINISH1                          ; Send out a header with the value
386       P:620C P:620C 0AC416  RDY       JCLR    #22,X0,RDR                        ; Test address bit for Y: memory
                        006210
387       P:620E P:620E 4CE000            MOVE                          Y:(R0),X0   ; Read from Y data memory
388       P:620F P:620F 0C005C            JMP     <FINISH1                          ; Send out a header with the value
389       P:6210 P:6210 0AC417  RDR       JCLR    #23,X0,ERROR                      ; Test for read of EEPROM memory
                        000059
390       P:6212 P:6212 0503BA            MOVEC             #$03,OMR                ; Development mode - disable internal P: memory
391       P:6213 P:6213 000000            NOP
392       P:6214 P:6214 07E084            MOVE              P:(R0),X0               ; Read from EEPROM
393       P:6215 P:6215 0502BA            MOVEC             #$02,OMR                ; Normal mode - enable internal P: memory
394       P:6216 P:6216 000000            NOP
395       P:6217 P:6217 0C005C            JMP     <FINISH1
396    
397                             ; Program WRMEM - ('WRM' address datum), write to memory.
398       P:6218 P:6218 60E400  WRMEM     MOVE              X:(R4),R0               ; Get the desired address
399       P:6219 P:6219 44DC00            MOVE              X:(R4)+,X0              ; We need a 24-bit version of the address
400       P:621A P:621A 45DC00            MOVE              X:(R4)+,X1              ; Get value into X1 some MOVE works easily
401       P:621B P:621B 0AC414            JCLR    #20,X0,WRX                        ; Test address bit for Program memory
                        006223
402       P:621D P:621D 220400            MOVE              R0,X0                   ; Get 16-bit version of the address
403       P:621E P:621E 568F00            MOVE              X:<C512,A               ; If address >= $200 then its an EEPROM write
404       P:621F P:621F 200045            CMP     X0,A                              ;   and a delay 10 milliseconds is needed
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 8



405       P:6220 P:6220 076085            MOVE              X1,P:(R0)               ; Write to Program memory
406       P:6221 P:6221 0EF066            JLE     <DLY_ROM                          ; Jump to delay routine if needed
407       P:6222 P:6222 0C005B            JMP     <FINISH
408       P:6223 P:6223 0AC415  WRX       JCLR    #21,X0,WRY                        ; Test address bit for X: memory
                        006227
409       P:6225 P:6225 456000            MOVE              X1,X:(R0)               ; Write to X: memory
410       P:6226 P:6226 0C005B            JMP     <FINISH
411       P:6227 P:6227 0AC416  WRY       JCLR    #22,X0,WRR                        ; Test address bit for Y: memory
                        00622B
412       P:6229 P:6229 4D6000            MOVE                          X1,Y:(R0)   ; Write to Y: memory
413       P:622A P:622A 0C005B            JMP     <FINISH
414       P:622B P:622B 0AC417  WRR       JCLR    #23,X0,ERROR                      ; Test address bit for ROM memory
                        000059
415       P:622D P:622D 0503BA            MOVE              #3,OMR                  ; Development mode - disable internal P: memory
416       P:622E P:622E 000000            NOP
417       P:622F P:622F 076085            MOVE              X1,P:(R0)               ; Write to EEPROM
418       P:6230 P:6230 0502BA            MOVE              #2,OMR                  ; Normal mode - enable internal P: memory
419       P:6231 P:6231 000000            NOP
420       P:6232 P:6232 0C0066            JMP     <DLY_ROM                          ; Delay 10 milliseconds for EEPROM write
421    
422                             ; Read EEPROM code into DSP locations starting at P:APL_ADR
423       P:6233 P:6233 0003F8  LDA       ORI     #$03,MR                           ; Temporarily mask interrupts
424       P:6234 P:6234 44DC00            MOVE              X:(R4)+,X0              ; Number of application program
425       P:6235 P:6235 568B00            MOVE              X:<ZERO,A
426       P:6236 P:6236 469445            CMP     X0,A      X:<C300,Y0
427       P:6237 P:6237 0AF0AA            JEQ     LDA_0                             ; Application #0 is a special case
                        006243
428       P:6239 P:6239 458BD0            MPY     X0,Y0,A   X:<ZERO,X1
429       P:623A P:623A 449022            ASR     A         X:<C1D00,X0
430       P:623B P:623B 359020            ADD     X,A       #APL_ADR,R5
431       P:623C P:623C 211000            MOVE              A0,R0                   ; EEPROM address = # x $300 + $1D00
432       P:623D P:623D 067081            DO      #$200-APL_ADR,LD_LA0              ;  Thus  ( 1 <= # <= 10 )
                        006240
433       P:623F P:623F 07D88E            MOVE              P:(R0)+,A               ; Read from EEPROM
434       P:6240 P:6240 075D8E            MOVE              A,P:(R5)+               ; Write to DSP
435                             LD_LA0
436       P:6241 P:6241 0AF080            JMP     LD_X                              ; Keep R0 value
                        00624E
437    
438                             ; Special case - application #0 can spill from internal P: DSP to EEPROM memory
439       P:6243 P:6243 309000  LDA_0     MOVE              #APL_ADR,R0
440       P:6244 P:6244 067081            DO      #$200-APL_ADR,LD_LA1
                        00624B
441       P:6246 P:6246 0503BA            MOVE              #3,OMR                  ; Development mode - disable internal P: memory
442       P:6247 P:6247 000000            NOP
443       P:6248 P:6248 07E08E            MOVE              P:(R0),A                ; Read from EEPROM
444       P:6249 P:6249 0502BA            MOVE              #2,OMR                  ; Normal mode - enable internal P: memory
445       P:624A P:624A 000000            NOP
446       P:624B P:624B 07588E            MOVE              A,P:(R0)+               ; Write to DSP
447                             LD_LA1
448    
449                             ; Load in the application command table into X:CMD_TBL
450       P:624C P:624C 60F400            MOVE              #APL_XY,R0
                        001EE0
451       P:624E P:624E 35C000  LD_X      MOVE              #COM_TBL,R5
452       P:624F P:624F 062080            DO      #32,LD_LA2                        ; 16 application commands
                        006252
453       P:6251 P:6251 07D88E            MOVE              P:(R0)+,A
454       P:6252 P:6252 565D00            MOVE              A,X:(R5)+
455                             LD_LA2
456    
457                             ; Load the Y: data memory contents
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 9



458       P:6253 P:6253 350000            MOVE              #0,R5                   ; Start at bottom of Y: memory
459       P:6254 P:6254 060081            DO      #$100,LD_LA3                      ; Read from EEPROM and write
                        006257
460       P:6256 P:6256 07D88E            MOVE              P:(R0)+,A               ;   them to Y: memory
461       P:6257 P:6257 5E5D00            MOVE                          A,Y:(R5)+
462                             LD_LA3
463       P:6258 P:6258 00FCB8            ANDI    #$FC,MR                           ; Unmask interrupts
464       P:6259 P:6259 0C005B            JMP     <FINISH                           ; Send 'DON' message
465    
466                             ; Parameter definitions in X: memory space
467       X:0000 P:6100                   ORG     X:0,P:X_OFF
468       X:0000 P:6100         STATUS    DC      0                                 ; Status word
469       X:0001 P:6101         OPTIONS   DC      0                                 ; Software options
470       X:0002 P:6102         NWORDS    DC      0                                 ; Number of words in destination command packet
471       X:0003 P:6103         HDR_ID    DC      0                                 ; 24-bit header containing board ID's
472    
473                             ; Places for saving register values
474       X:0004 P:6104         SAVE_SR   DC      0                                 ; Status Register
475       X:0005 P:6105         SAVE_X1   DC      0
476       X:0006 P:6106         SAVE_A1   DC      0
477       X:0007 P:6107         RCV_ERR   DC      0
478       X:0008 P:6108         STX_ADR   DC      $FFF4                             ; Current SCI XMT byte address ($FFF4, 5 or 6)
479       X:0009 P:6109         SRX_FST   DC      $FFF4                             ; Current SCI RCV byte address ($FFF4, 5 or 6)
480       X:000A P:610A         SRX_A1    DC      0                                 ; Contents of accumulator A1 in RCV ISR
481    
482                             ; Constant definitions, useful for saving program memory space
483       X:000B P:610B         ZERO      DC      0
484       X:000C P:610C         ONE       DC      1
485       X:000D P:610D         TWO       DC      2
486       X:000E P:610E         C32       DC      32
487       X:000F P:610F         C512      DC      512                               ; Boundary between DSP and EEPROM P: memory
488       X:0010 P:6110         C1D00     DC      $1D00                             ; Offset for loading application programs
489       X:0011 P:6111         MASK1     DC      $FCFCF8                           ; Mask for checking header
490       X:0012 P:6112         MASK2     DC      $030300                           ; Mask for checking header
491       X:0013 P:6113         CFFF      DC      $FFF                              ; Mask for 12-bit A/D converter
492       X:0014 P:6114         C300      DC      $300                              ; Constant for resetting the DSP
493       X:0015 P:6115         C50000    DC      50000                             ; 5 millisec delay for +/- 15v settling
494       X:0016 P:6116         SBRDID    DC      $030000                           ; Source Identification number
495       X:0017 P:6117         DBRDID    DC      $000300                           ; Destination Identification number
496       X:0018 P:6118         DMASK     DC      $00FF00                           ; Mask to get destination board number out
497       X:0019 P:6119         SMASK     DC      $FF0000                           ; Mask to get source board number out
498       X:001A P:611A         HOST      DC      $030002                           ; Header to host computer
499       X:001B P:611B         VME       DC      $030102                           ; Header to VMEINF board
500       X:001C P:611C         TIMING    DC      $030202                           ; Header to timing board
501       X:001D P:611D         UTIL      DC      $030302                           ; Header to utility board
502       X:001E P:611E         ERR       DC      'ERR'                             ; For sending error messages
503       X:001F P:611F         DON       DC      'DON'                             ; For sending completion messages
504    
505                             ; The last part of the command table is not defined for "bootrom"
506                             ;  The command table is resident in X: data memory; 32 entries maximum
507       X:00C0 P:61C0                   ORG     X:COM_TBL,P:COM_TBL+X_OFF
508       X:00C0 P:61C0                   DC      0,START,0,START,0,START,0,START   ; This is where application
509       X:00C8 P:61C8                   DC      0,START,0,START,0,START,0,START   ;    commands go
510       X:00D0 P:61D0                   DC      0,START,0,START,0,START,0,START
511       X:00D8 P:61D8                   DC      0,START,0,START,0,START,0,START
512       X:00E0 P:61E0                   DC      'TDL',TDL                         ; Test Data Link
513       X:00E2 P:61E2                   DC      'RDM',RDMEM                       ; Read DSP or EEPROM memory
514       X:00E4 P:61E4                   DC      'WRM',WRMEM                       ; Write DSP or EEPROM memory
515       X:00E6 P:61E6                   DC      'LDA',LDA                         ; Load application program from EEPROM
516       X:00E8 P:61E8                   DC      'ERR',START                       ; Do nothing
517       X:00EA P:61EA                   DC      0,START,0,START,0,START
518    
Motorola DSP56000 Assembler  Version 6.3.0   114-07-24  08:31:00  utilboot3.asm  Page 10



519                             ; End of program
520                                       END

0    Errors
0    Warnings


