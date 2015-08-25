;; Volkswagen CD Changer Capturer
;; For use on PIC16F627 at 20MHz/5VDC
;;
;; Copyright (c) 2002-2003, Edward Schlunder <zilym@NOSPAM.k9spud.com>
;;
;; $Log: vwcdcap.asm,v $
;; Revision 1.1  2003/06/10 06:40:49  edwards
;; working capture firmware
;;
;; Revision 1.2  2003/03/18 04:18:06  edwards
;; Works, but not fast enough.
;;
;; Revision 1.1.1.1  2003/03/13 03:33:36  edwards
;;
;;

		
	LIST P=16F627, R=DEC
	__CONFIG _BODEN_ON & _DATA_CP_OFF & _LVP_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _HS_OSC

#include <p16f627.inc>

;--------------------------------------------------------------------------
; Connections
;--------------------------------------------------------------------------
; RA0	   - J2.8 (2.67K & 47pF current limit)
; RA1	   - J2.10 (2.67K & 47pF current limit)
; RA2	   - J2.9 (nc)
; RA3	   - J2.7 (nc)
; RA4	   - J2.5 (nc)
; RA5/MCLR - J2.3/ICSP (100K pull up)
; RB0/INT  - J2.1 (nc)
; RB1/RX   - PC Serial TX
; RB2/TX   - PC Serial RX
; RB3      - J2.2 (nc)
; RB4      - J3.2 (100K pull down)
; RB5      - J3.1 (nc)
; RB6      - ICSP (nc)
; RB7      - ICSP (nc)
;--------------------------------------------------------------------------
; PIC RB0 <- VW CD Changer Pin 2 Clock  to Head Unit
; PIC RA5 <- VW CD Changer Pin 2 Data   to Head Unit
; Make sure PIC and VW CD Changer have common GND.
;--------------------------------------------------------------------------
SCLK		EQU	0
SDATA		EQU	4

SerialTX	EQU	2
SerialRX	EQU	1

VER_MAJOR	EQU	'1'
VER_MINOR	EQU	'0'

REFRESH_PERIOD	EQU	55	; refresh head unit every 55ms

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------
GPRAM		EQU     0x20
sendreg		EQU	GPRAM+0	; for sendserial
sendhexreg	EQU	GPRAM+1
sendbitcount    EQU	GPRAM+2

intw		EQU	GPRAM+3	; for interrupt service routine
intstatus	EQU	GPRAM+4
intfsr		EQU	GPRAM+5
	
sendptr		EQU	GPRAM+6	; next byte to read & send from capture buffer
sendcount	EQU	GPRAM+7

pflags		EQU	GPRAM+8 ; program flags
capdone		EQU	0
			
capptr		EQU	GPRAM+30
capbit		EQU	GPRAM+31	
capbuf		EQU	0xA0	; GPRAM+32
capbufend	EQU	0xFF
	
;--------------------------------------------------------------------------
; Note:	20MHz / 4 = 5MHz. 1/5MHz = 0.2us.
;       So each PIC instruction takes 0.2 microsecond long.
;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
	ORG	0
	goto	Start

;--------------------------------------------------------------------------
; Interrupt Service Routine
; 
; Interrupt Sources:
;	RB0/INT Used for recieving head unit button commands
;--------------------------------------------------------------------------
	ORG	4

InterruptServiceRoutine
	movwf   intw		; preserve w register
        swapf   STATUS, w       ; preserve status register
        movwf   intstatus
	movf    FSR, w          ; preserve FSR register
        movwf   intfsr

RB0ISR
        btfss   INTCON, INTF	; RB0/INT interrupt?
        goto    EndISR
	
	movf	capptr, w	;  load capture pointer into indirect pointer
	movwf	FSR
	
	bcf	STATUS, C	; clear carry bit
	btfsc	PORTA, SDATA	; is the data high?
	bsf	STATUS, C

	rlf	INDF, 1		; save next bit in the capture buffer

	incfsz	capbit, f	; have we captured 8 bits yet?
	goto	CaptureDone

	incf	FSR, f		; increment capture pointer
	movlw	-8		; start capturing another 8 bits
	movwf	capbit
		
	movlw	capbufend	; have we reached the end of the buffer?
	subwf	FSR, w
	btfss	STATUS, Z
	goto	ClearCapByte	; nope, still in the buffer
	
	movlw	capbuf		; yes, roll back to the beginning
	movwf	FSR	

ClearCapByte
	clrf	INDF		; starting a new byte, initialize to 0

	movf	FSR, w		; save capture pointer
	movwf	capptr
		
CaptureDone
        bcf     INTCON, INTF	; clear interrupt flag

;	clrf	TMR0		; restart timer
;	bcf	INTCON, T0IF	
;	bsf	INTCON, T0IE	; enable timer 0 overflow interrupt
	goto	EndISR

TMR0ISR
	btfss	INTCON, T0IE	; is timer 0 overflow interrupt enabled?
	goto	EndISR
	btfss	INTCON, T0IF	; if so, did a timer 0 overflow occur?
	goto	EndISR

	bcf	INTCON, T0IE	; disable further timer 0 interrupts
	bsf	pflags, capdone	; set flag signifying packet capture done

	movlw	-8		; start capturing another 8 bits
	movwf	capbit
	incf	capptr, f	; make sure to include last capture byte
	movlw	capbufend	; have we overflowed the 
	subwf	capptr, w	; capture buffer?
	btfss	STATUS, Z
	goto	ClearCapByte2

	movlw	capbuf		; yes, roll over to beginning
	movwf	capptr

ClearCapByte2
	movf	capptr, w
	movwf	FSR	
	clrf	INDF		; clear capture byte (incomplete captures)

EndISR
        movf    intfsr, w	; restore indirect pointer
        movwf   FSR
        swapf   intstatus, w	; restore STATUS register
        movwf   STATUS
        swapf   intw, f		; restore w register
        swapf   intw, w
	retfie

;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
Start
	clrf	PORTA		; initialize port a data latches
	clrf	PORTB		; initialize port b data latches

	movlw   0x07            ; turn voltage comparators off so PORTA
	movwf   CMCON           ; can be used for regular i/o functions

	bsf	STATUS, RP0	; select data bank 1
	ERRORLEVEL -302
	clrwdt			; clear WDT & prescaler (avoids possible reset)
	movlw	10000011b	; port b pull-ups disabled
	movwf	OPTION_REG	; interrupt on falling edge, timer 0 prescale 1:32

	bsf	TXSTA, TXEN	; enable transmitting
	bsf	TXSTA, BRGH	; high baud rate	
	movlw	10		; 115.2kbps baud rate generation
	movwf	SPBRG
	ERRORLEVEL +302
	bcf	STATUS, RP0	; go back to data bank 0

	bsf	RCSTA, SPEN	; enable serial port

	
	movlw	-8		; initialize capture variables
	movwf	capbit
	movwf	sendcount

	movlw	capbuf
	movwf	capptr
	movwf	FSR
	clrf	INDF		; initialize first capture byte to zero

	clrf	pflags		; initialize program flags
		
	bcf	INTCON, INTF	; clear RB0/INT interrupt flag
	bsf	INTCON, INTE	; enable interrupt on RB0 rising edge
	bsf	INTCON, GIE	; Global Interrupt Enable

	bsf	PIR1, TXIF	; enable transmitting on serial port
	
	call	SendSerialIdentify

	clrf	sendcount
	
IdleLoop
	movf	FSR, w		; have we caught up with the capture?
	subwf	capptr, w
	btfss	STATUS, Z
	goto	SendCapture	; no, send next byte from the capture buffer

;	btfss	pflags, capdone	; have we finished sending a capture line?
; 	goto	IdleLoop

;	bcf	pflags, capdone	
;       movlw   13
;       call    SendSerial
;       movlw   10
;       call    SendSerial

	incfsz	sendcount, f
 	goto	IdleLoop

	movlw	'.'
	call	SendSerial
 	movlw	0
 	movwf	sendcount

	call	Wait14
	
	goto	IdleLoop
	
SendCapture
	movf	INDF, w		; get a byte from the capture buffer
	call	SendSerialHex	; send it to the host


		
IncPointer	
	incf	FSR, 1
	movlw	capbufend	; have we overflowed the capture buffer?
	subwf	FSR, w
	btfss	STATUS, Z
	goto	IdleLoop	; no, wait for next capture byte

	movlw	capbuf		; yes, roll over back to beginning of buffer
	movwf	FSR

	goto	IdleLoop

SendSerialIdentify
	movlw	'V'
	call	SendSerial
	movlw	'W'
	call	SendSerial
	movlw	'C'
	call	SendSerial
	movlw	'D'
	call	SendSerial
	movlw	'C'
	call	SendSerial
	movlw	'A'
	call	SendSerial
	movlw	'P'
	call	SendSerial
	movlw	VER_MAJOR
	call	SendSerial
	movlw	'.'
	call	SendSerial
	movlw	VER_MINOR
	call	SendSerial
	goto	SendNEWLINE

		
SendNEWLINE
        movlw   13
        call    SendSerial
        movlw   10
        call    SendSerial
        return

;--------------------------------------------------------------------------
; SendSerialHex - Sends byte provided in the W register using SendSerial.
;	The byte is converted to a two byte ASCII hexidecimal string
;--------------------------------------------------------------------------
SendSerialHex
	movwf	sendhexreg
	swapf	sendhexreg, w	; send high nibble first
	andlw	0x0F
	addlw	-10		; less than 10?
	btfsc	STATUS, C
	addlw	'A' - ('0' + 10); no, we're in the range [Ah..Fh]
	addlw	'0' + 10	; yes, range [0..9]
	call	SendSerial

	movf	sendhexreg, w	; now send low nibble
	andlw	0x0F
	addlw	-10
	btfsc	STATUS, C
	addlw	'A' - ('0' + 10)
	addlw	'0' + 10
	goto	SendSerial	; use SendSerial's return to return to caller
	
;--------------------------------------------------------------------------
; SendSerial - Sends 19.2Kbps 8 bit serial data using bit banging.
;	Place byte to transmit into W register before calling.
;	Interrupts will be temporarily disabled by this routine. On return,
;	interrupts will be enabled.
;--------------------------------------------------------------------------
SendSerial
	btfss	PIR1, TXIF
	goto	SendSerial

	bcf	PIR1, TXIF
	movwf	TXREG
	return

;--------------------------------------------------------------------------
; WaitXX - Burns cpu cycles for timing purposes. XX = number of cycles
;--------------------------------------------------------------------------
Wait56
	goto    $+1	; 56
	goto    $+1	; 54
	goto    $+1	; 52
	goto    $+1	; 50
	goto    $+1	; 48
	goto    $+1	; 46
Wait44
	goto    $+1	; 44
Wait42
	goto    $+1	; 42
	goto    $+1	; 40
	goto    $+1	; 38
	goto    $+1	; 36
	goto    $+1	; 34
	goto    $+1	; 32
	goto    $+1	; 30
	goto    $+1	; 28
	goto    $+1	; 26
	goto    $+1	; 24
	goto    $+1	; 22
	goto    $+1	; 20
Wait18	goto    $+1	; 18
Wait16	goto    $+1	; 16
Wait14	goto    $+1	; 14
	goto    $+1	; 12
	goto    $+1	; 10
Wait8	goto    $+1	; 8
Wait6	goto    $+1	; 6
	return		; 4 (initial call used 2)

	END

