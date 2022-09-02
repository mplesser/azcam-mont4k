; Switch state bits for clocks
; mont4k pinout with split serials

; low bank (usually CLK2)
RGL	EQU     0	;	CLK0	Pin 1
RGH	EQU     1	;	CLK0
P1L	EQU     0	;	CLK1	Pin 2
P1H	EQU     2	;	CLK1
P2L	EQU     0	;	CLK2	Pin 3
P2H	EQU     4	;	CLK2
P3L	EQU     0	;	CLK3	Pin 4
P3H	EQU     8	;	CLK3
S1RL	EQU     0	;	CLK4	Pin 5
S1RH	EQU     $10	;	CLK4
S3L	EQU     0	;	CLK5	Pin 6
S3H	EQU     $20	;	CLK5
S2RL	EQU     0	;	CLK6	Pin 7
S2RH	EQU     $40	;	CLK6
S3LL	EQU     0	;	CLK7	Pin 8
S3LH	EQU     $80	;	CLK7
S2LL	EQU     0	;	CLK8	Pin 9
S2LH	EQU     $100	;	CLK8
S1LL	EQU     0	;	CLK9	Pin 10
S1LH	EQU     $200	;	CLK9
SWL	EQU     0	;	CLK10	Pin 11 
SWH	EQU     $400	;	CLK10
TGL	EQU     0	;	CLK11	Pin 12
TGH	EQU     $800	;	CLK11

; high bank (usually CLK3) - not used
Z1L	EQU     0	;	CLK12	Pin 13
Z1H	EQU     $1000	;	CLK12
Z2L	EQU     0	;	CLK13	Pin 14
Z2H	EQU     $2000	;	CLK13
Z3L	EQU     0	;	CLK14	Pin 15
Z3H	EQU     $4000	;	CLK14
Z4L	EQU     0	;	CLK15	Pin 16
Z4H	EQU     $8000	;	CLK15
Z5L	EQU     0	;	CLK16	Pin 17
Z5H	EQU     $10000	;	CLK16
Z6L	EQU     0	;	CLK17	Pin 18
Z6H	EQU     $20000	;	CLK17
Z7L	EQU     0	;	CLK18	Pin 19
Z7H	EQU     $40000	;	CLK18
Z8L	EQU     0	;	CLK19	Pin 33
Z8H	EQU     $80000	;	CLK19
Z9L	EQU     0	;	CLK20	Pin 34
Z9H	EQU     $100000	;	CLK20
Z10L	EQU     0	;	CLK21	Pin 35
Z10H	EQU     $200000	;	CLK21
Z11L	EQU     0	;	CLK22	Pin 36
Z11H	EQU     $400000	;	CLK22
Z12L	EQU     0	;	CLK23	Pin 37
Z12H	EQU     $800000	;	CLK23
