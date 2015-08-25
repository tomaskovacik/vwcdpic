        include "gp20head.asm"

;; Volkswagen CD Changer Emulator
;; For use on Motorola HC08
;
; Copyright (c) 2003, Esmir Celebic <cele0001@unf.edu>
;
; Based on VWCDPIC source code originally
; Copyright (c) 2002-2003, Edward Schlunder <zilym@k9spud.com>
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
	
;--------------------------------------------------------------------------
; Connections
;--------------------------------------------------------------------------
;  Pin 1 PTE1 -> VW Pin 2 SCLK to Head Unit
;  Pin 2 PTE0 -> VW Pin 1 STX  to Head Unit
;
; Make sure HC08 and VW Head Unit have common GND.
;--------------------------------------------------------------------------
* -------------------------------------------------------------------
* CHANGE THIS TO MATCH OPPORATING FREQUENCY (MHz)
* To allow adaptable delays.
* -------------------------------------------------------------------
SCLK		EQU	1
STX		EQU	0

BUSFREQ		EQU		1
USCOUNT		EQU		$0E
USDELAY		EQU		BUSFREQ*USCOUNT

; Miscellaneous equates
DELAYVAL  	EQU		$50			;Default value for delays


* -------------------------------------------------------------------
* RAM variables
* -------------------------------------------------------------------
	ORG   	RAMSPACE				;Start of RAM
Counter   	RMB		1       		;Counter variable for delay
TempVar		RMB		1			;Temporary 8-bit storage
Count		RMB 	        1			;Counter variable
Counterx        RMB             1                       ;another counter variable

* -------------------------------------------------------------------
* Program code
* -------------------------------------------------------------------
	ORG	FLASHSPACE	;Start of FLASH memory
;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
Start
     SEI        ;               disable all interrupts
     MOV        #$01,CONFIG2;
     NOP
     NOP
     MOV        #$FF,DDRE;        PORTE OUTPUT
     MOV        #$00,PORTC;       SET IT Low
;-----------------------------------------------------------
MainLoop
        MOV #9,Counterx
        LDHX    #Packet;        Load the index with the packet addres
        JSR     SendPacket;     Send the update string
D2      JSR     _1MsDelay;
        DBNZ Counterx,D2 ; do it 10 times
        LDX #$FF      ;need to reset the COP
        STX $FFFF;    Write to the COPCTL
        JMP     MainLoop;       and do it all over again

* --------------------------------------------------------
* SEND PACKET WILL LOAD THE BYTE INTO ACCA AND SEND IT OVER
* TO THE SEND BYTE SUBROUTINE. Addres of the first packet is in the hx
* --------------------------------------------------------
SendPacket

          PSHA;                   save it just in case
SendPacket1
          LDA ,X ;                Load the next byte to send
          TSTA;                    is it the last one 00
          BNE Send;
          PULA;                   clean up after ourselves
          RTS;                     if we are done exit the subroutine
Send      JSR SendByte;
          INCX;                   move the pointer to the next byte
          BRA SendPacket1;

* --------------------------------------------------------
* Send byte is the heart of the whole thing and timing
* is critical so we need to pay attention
* the clock should be 8us period and toggled to clock the data
* in bit by bit. Byte to send is in ACCA
* -----------------------------------------------------------
SendByte
        MOV     #$08,Counter    ;we will do it 8 times
SendByte1       ROLA;
        BSET SCLK,PORTE;        set the clock high
        BCS SetHigh;            is the carry set?
        BCLR STX,PORTE;         if not put 0 on the line
        BRA ClockDown;          and go to the clock pulse
SetHigh
        BSET STX,PORTE;         otherwise put a 1
        NOP;                    timing issues
ClockDown
        BCLR SCLK,PORTE;        clock goes down
        DBNZ Counter,SendByte1;          get another bit
        JSR _335usDelay;         must wait 335us for the data to settle
        RTS;                    and we are done

*==========================================================
* Interrupt routines are here if we need them
*========================================================--
Trap    BRA     *

* -------------------------------------------------------------------
* DELAY ROUTINES
* -------------------------------------------------------------------
* 1ms delay loop, causes _roughly_ 1.3ms delay @ fop = 8MHz
* uses constant for loop control
* cycles = 4 + X(6+7+1275) + 3 + 6
* cycles = 13 + X(1288)
* where X is value loaded into Acc
* Causes 1.3ms delay for BUSFREQ values of (1-8 integer values)
* -------------------------------------------------------------------
_1msDelay:
		PSHA					;2 cycles
		LDA		#BUSFREQ		;2
DLLoop	        DBNZA	        DLSub			;3
		BRA		DLDone			;3
DLSub	        MOV		#$FF,Counter 	        ;4
		DBNZ	        Counter,*		;5
		BRA		DLLoop			;3
DLDone	        PULA					;2
		RTS					;4
* -------------------------------------------------------------------
* 600usec delay routine.
*
* 6+X(3)
* Where X = BUSFREQ*USCOUNT = USDELAY
* Provides _roughly_ 335us delay
* -------------------------------------------------------------------
_335usDelay:
		LDA		#$88                    ;2
		DBNZA	        *			;3
		RTS                                     ;4
* -------------------------------------------------------------------
* Hard coded packet that will be sent every 10ms
* -------------------------------------------------------------------
Packet           FCB    $74,$BC,$96,$FD,$FD,$F1,$CF,$7C,$00
Packet1          FCB    $14,$2E,$99,$FD,$FF,$FF,$FF,$7C,$00

;Packet           FCB    $74,$BC,$96,$FD,$FD,$FF,$8F,$7C,$00
* -------------------------------------------------------------------

* -------------------------------------------------------------------
* VECTOR ASSIGNMENTS
* -------------------------------------------------------------------
* Trap unused vectors to indicate errors
* -------------------------------------------------------------------
	        ORG            TBVEC
	        FDB            Trap
	        ORG            ADCVEC
	        FDB            Trap
	        ORG            KBIVEC
	        FDB            Trap
	        ORG            SCITXVEC
	        FDB            Trap
	        ORG            SCIRXVEC
	        FDB            Trap
	        ORG            SCIERVEC
	        FDB            Trap
	        ORG            SPITXVEC
	        FDB            Trap
	        ORG            SPIRXVEC
	        FDB            Trap
	        ORG            T2OFVEC
	        FDB            Trap
	        ORG            T2CH1VEC
	        FDB            Trap
	        ORG            T2CH0VEC
	        FDB            Trap
	        ORG            T1OFVEC
	        FDB            Trap
	        ORG            T1CH1VEC
	        FDB            Trap
	        ORG            T1CH0VEC
	        FDB            Trap
	        ORG            PLLVEC
	        FDB            Trap
	        ORG            IRQ1VEC
	        FDB            Trap
	        ORG            SWIVEC
	        FDB            Trap
	        ORG            RESETVEC
	        FDB            Start
