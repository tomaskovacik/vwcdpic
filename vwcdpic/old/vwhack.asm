;; Volkswagen CD Changer Emulator
;; For use on PIC16F84 at 4MHz running off 4 AA batteries (5VDC)
;;
;; Copyright (c) 2002, Edward Schlunder <zilym@yahoo.com>

; Note:	4MHz / 4 = 1MHz. 1/1MHz = 1us.
;       So each PIC instruction takes one microsecond long.
	
	LIST P=16F84, R=DEC
	__CONFIG _WDT_OFF & _PWRTE_ON & _CP_OFF & _XT_OSC

#include <p16f84.inc>

;--------------------------------------------------------------------------
; Connections
;--------------------------------------------------------------------------
; PIC16F84 Pin 1 RA2 -> VW Pin 2 SCLK to Head Unit
; PIC16F84 Pin 2 RA3 -> VW Pin 1 STX  to Head Unit
; 
; Make sure PIC and VW Head Unit have common GND.
;--------------------------------------------------------------------------
SCLK		EQU	2
STX		EQU	3

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------
ScratchPadRam   EQU     0x20
txreg		EQU	ScratchPadRam+0

;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
	ORG	0
	goto	Start

;--------------------------------------------------------------------------
; Interrupt Service Routine
;--------------------------------------------------------------------------
	ORG	4
	retfie

;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
Start
	clrf	INTCON		; Disable all interrupts 

	clrf	STATUS		; Force data bank 0
	clrf	PORTA		; initialize port a to 0
	clrf	PORTB		; initialize port b to 0
;	movlw	0x07		; turn comparators off so port a
;	movwf	CMCON		; can be used for i/o
	bsf	STATUS, RP0	; select data bank 1
	clrf	TRISA		; Set port a as outputs
	clrf	TRISB		; Set port b as outputs
	clrf	OPTION_REG	; PORTB pull-ups enable
	bcf	STATUS, RP0	; go back to data bank 0

	;bsf	INTCON, GIE	; Global Interrupt Enable
IdleLoop
	call	SendPacket

	call	msecWait	; wait 10ms between display packets
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait
	call	msecWait

	goto	IdleLoop

;--------------------------------------------------------------------------
; msecWait - delays approximately one millisecond
;--------------------------------------------------------------------------
msecWait
	movlw	-249
msecWaitLoop
	addlw	1
	btfss	STATUS, Z
	goto	msecWaitLoop
	return

;--------------------------------------------------------------------------
; SendPacket - sends a display update packet to the head unit
;              currently hard coded to display "CD 1 Tr 1" on head unit
;--------------------------------------------------------------------------
SendPacket
	movlw	0x74
	call	SendByte
	movlw	0xBE		; disc
	call	SendByte
	movlw	0xFE		; track
	call	SendByte
	movlw	0xFF		; ??
	call	SendByte
	movlw	0xFF
	call	SendByte
	movlw	0xFF		; mode (scan/mix)
	call	SendByte
	movlw	0x8F
	call	SendByte
	movlw	0x7C
	call	SendByte
	return

;--------------------------------------------------------------------------
; SendByte - sends a byte to head unit.
;            load byte to send to head unit into W register before 
calling
;--------------------------------------------------------------------------
SendByte
	movwf	txreg
	movlw	-8
	bcf	INTCON, GIE	; disable interrupts, timing critical

BitLoop
	rlf	txreg, 1	; load the next bit into the carry flag
	bsf	PORTA, SCLK	; SCLK high

	bcf	PORTA, STX	; load the next bit onto STX
	btfsc	STATUS, C
	bsf	PORTA, STX

	bcf	PORTA, SCLK	; SCLK low
	addlw	1		; 
	btfss	STATUS, Z
	goto	BitLoop

	bsf	INTCON, GIE	; re-enable interrupts
	
	movlw	-84		; wait 335us for head unit to store sent byte
DelayLoop				
	addlw	1
	btfss	STATUS, Z
	goto	DelayLoop

	return

	END

