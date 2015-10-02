; Volkswagen CD Changer Emulator
; For use on PIC12F629 at 4MHz/5VDC
;
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


;; The original author maintains a website at http://www.k9spud.com/ where 
;; you can order a pre-assembled VWCDPIC board that runs this software.
;; Schematics for building your own from scratch are also available.
;;
;; If you sell devices derived from this software, make sure you read
;; and strictly adhere to the provisions set forth in the GNU General Public 
;; License. Specifically, any modifications you make to this source code
;; must be made available to the public under the GNU GPL.
;;
;; Monsoon protocol information contributed by Andy Wilson <awilson@microsoft.com>
;; Monsoon debugged code contributed by Paul Stewart <stewart@parc.com>
;; Monsoon Double DIN improvements contributed by Svetoslav Vassilev
;;
;; $Log: vwcdpic.asm,v $
;; Revision 1.32  2004/01/13 06:41:32  edwards
;; Adding back support for recognizing commands.
;;
;; Revision 1.31  2004/01/13 05:09:04  edwards
;; no message
;;
;; Revision 1.30  2004/01/13 04:48:01  edwards
;; interim improvements to capture code.
;;
;; Revision 1.29  2004/01/12 06:58:26  edwards
;; Starting to work on reverse bit order command capture. This bit ordering
;; will make it more natural to read command bits as they were captured.
;;
;; Revision 1.28  2004/01/12 04:48:59  edwards
;; Filter seems to work, but doesn't solve the problem.
;;
;; Revision 1.27  2004/01/12 01:30:27  edwards
;; second try at improved command noise filtering
;;
;; Revision 1.26  2004/01/12 01:08:09  edwards
;; first try at improved command noise filtering
;;
;; Revision 1.25  2003/10/09 07:29:28  edwards
;; Increased delay between bytes sent to the head unit to 700us per suggestion
;; from Svet. Maybe helps with late 2003 Wolfsburg double din drop out problem.
;;
;; Revision 1.24  2003/09/28 18:55:00  edwards
;; Committed Svet's changes to cvs repository.
;; Fixed a small bug in MK3 button up/dn support.
;; Added EEPROM copyright notice.
;;
;; Revision 1.23  2003/09/17 05:40:22  edwards
;; Changed licensing to GNU GPL. Maybe we can get some more developers
;; playing with this now that it is Open Source proper.
;;
;; Revision 1.22  2003/08/17 08:39:45  edwards
;; Increased default refresh period to 10ms so that seconds can be perfectly timed.
;; Added a Wait30 to the SendByte routine to soften emi noise.
;;
;; Revision 1.21  2003/08/12 04:19:09  edwards
;; Moving VWCDPIC PIC12F629 based firmware into the mainline branch.
;;
;; Revision 1.8  2003/08/01 22:52:37  edwards
;; DumpPacket now calls SendNEWLINE so that commands are properly
;; recognized by the PJRC MP3 Player. Was causing trouble on Monsoon
;; Double DIN head unit.
;;
;; Revision 1.7  2003/08/01 21:58:33  edwards
;; Removed unused serial recieve code.
;; Added support for incrementing the minutes:seconds display on Double DIN
;; head units.
;; Added support for momentarily turning on the "scan mode" display when
;; the scan button is pushed at the head unit.
;;
;; Revision 1.6  2003/07/07 17:32:26  edwards
;; Incremented version number
;;
;; Revision 1.5  2003/07/07 17:29:12  edwards
;; Changed disc load packets from 0x19..0x1F to 0x29..0x2F so that it does 
;; not say "CD-ROM" and beep on Monsoon head units. 
;;
;; Thanks goes to Svetoslav Vassilev for finding the AUDIO CD load packets.
;;
;; Revision 1.4  2003/04/26 03:18:15  edwards
;; Added code to setting the oscillator calibration register.
;;
;; Revision 1.3  2003/04/25 08:04:14  edwards
;; no comment
;;
;; Revision 1.2  2003/04/25 06:50:23  edwards
;; Made space for calibration data at end of memory.
;;
;; Revision 1.1  2003/04/25 06:48:24  edwards
;; First try at VWCDPIC 2.0 firmware.
;;
;; Revision 1.19  2003/03/08 02:34:24  edwards
;; First try at implementing Archos remote control.
;;
;; Revision 1.18  2003/03/03 14:40:58  edwards
;; At power up, we now use DISCSTART to wait before sending CD load
;; packets.
;;
;; Revision 1.17  2003/03/03 06:05:58  howard
;; Incremented version number.
;;
;; Revision 1.16  2003/03/03 06:05:18  howard
;; Now we can wait a variable number of display update packets before
;; sending the disc load packets.
;;
;; Revision 1.15  2003/03/03 05:48:15  howard
;; Going beyond CD6 is no longer allowed (should help compatibility with
;; Monsoon head units).
;;
;; Revision 1.14  2003/03/03 05:26:41  howard
;; Now recognizes MIX6 key code.
;; Recognizes Up/Dn Mk3 key codes as provided by Adam Yellen.
;;
;; Revision 1.13  2003/01/14 06:51:48  edwards
;; Documented Mix6 scan code.
;;
;; Revision 1.12  2002/12/02 00:13:44  edwards
;; Made the powered identify string display much slower now so that it won't
;; be so annoying.
;;
;; Moved the state jump table down to the end of program memory space so
;; that it is guaranteed to be page aligned.
;;
;; SendNEWLINE now sends character 13 followed by character 10 so that
;; Windows Hyperterminal will linefeed properly.
;;
;; Revision 1.11  2002/12/01 21:17:59  edwards
;; Added code to dump unknown command packets to the serial port.
;;
;; Revision 1.10  2002/12/01 20:50:39  edwards
;; My blind attempt at moving Paul Stewart's Monsoon code back into the
;; mainline firmware branch.
;;
;; Revision 1.9  2002/12/01 08:43:36  edwards
;; Formatting changes for MPLAB IDE 6.
;;
;; Revision 1.8  2002/12/01 08:25:53  edwards
;; Added project file for MPLAB IDE 6.
;;
;; v1.2
;; 	added first pass at a Monsoon state implementation, untested.
;;
;; v1.1b 
;; 	fixed SendSerialHex bugs
;;
;; v1.1
;;	removed all instances of ready-modify-write's to PORT regs
;; 	added CD[1..6] button recognition
;;	made display update send identification strings to serial
;;
;; v1.0
;;	initial release
	
	LIST P=12F629, R=DEC
	__CONFIG _BODEN_ON & _CPD_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT

#include <p12f629.inc>

DUMPMODE	EQU 0
;--------------------------------------------------------------------------
; Connections
;--------------------------------------------------------------------------
; PIC GP5 -> VW Pin 2 Clock  to Head Unit
; PIC GP4 -> VW Pin 1 Data   to Head Unit
; PIC GP2 <- VW Pin 4 Data from Head Unit
; Make sure PIC and VW Head Unit have common GND.
; 
; PIC GP0 -> PJRC MP3 Player RX (19.2Kbps serial, working)
; PIC GP1 -> Archos Jukebox RX (9600bps serial, untested)
; Make sure PIC and MP3 Player have common GND.
;--------------------------------------------------------------------------
SCLK		EQU	5
SRX		EQU	4
PWTX		EQU	2

SerialTX	EQU	0
SerialTX9600	EQU	1

STARTTHRESHOLD	EQU	100	; greater than this signifies START bit
HIGHTHRESHOLD	EQU	39	; greater than this signifies 1 bit.
LOWTHRESHOLD	EQU	8	; greater than this signifies 0 bit.

REFRESH_FAST	EQU	55		; do not refresh head unit faster than 5.5ms (currently not implemented)
REFRESH_SLOW	EQU	5240		; 5.24s slow refresh rate when head unit is in FM/AM/Tape mode (not implemented)
REFRESH_PERIOD	EQU	100		; default to refresh head unit every 10.0ms
SECONDWAIT	EQU	-10		; (1sec/0.10sec) = 10
SCANWAIT	EQU	-50		; 10 * 5sec = 50

VER_MAJOR	EQU	'2'
VER_MINOR	EQU	'6'

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------
GPRAM   EQU     0x20
sendreg		EQU	GPRAM+0
sendhexreg	EQU	GPRAM+1
disc		EQU	GPRAM+2
discload	EQU	GPRAM+3	; next disc number to enable head
DISCSTART	EQU	0	; this can be any number less than DISCMIN-1. Difference
				; from DISCMIN is the number of display updates to wait
				; before sending disc loaded packets, minus one.
DISCMIN		EQU	0x29	; 0x19..0x1F: CD-ROM Loaded.
DISCMAX		EQU	0x2F	; 0x79..0x7F: Disc Unloaded.
				; 0x29..0x2F: AUDIO CD Loaded.

track		EQU	GPRAM+4
minute		EQU	GPRAM+5
second		EQU	GPRAM+6

scanptr		EQU	GPRAM+7
scanbyte	EQU	GPRAM+8
buttonbyte1	EQU	GPRAM+9
buttonbyte2	EQU	GPRAM+10

sendbitcount	EQU	GPRAM+11 ; Used in SendByte routine

intwsave	EQU	GPRAM+12
intstatussave	EQU	GPRAM+13
intfsrsave	EQU	GPRAM+14

capbusy		EQU	0
mix			EQU	1
scan		EQU	2
dataerror	EQU 6
IF DUMPMODE == 1
startbit	EQU 7
ENDIF

progflags	EQU	GPRAM+15
captime		EQU	GPRAM+16 ; timer count of low pulse (temp)
capbit		EQU	GPRAM+17 ; bits left to capture for this byte
capbittotal EQU	GPRAM+18 ; bits total captured since start bit
capptr		EQU	GPRAM+19 ; pointer to packet capture buffer loc

BIDIstate	EQU	GPRAM+20
BIDIcount	EQU	GPRAM+21

poweridentcount	EQU	GPRAM+22
secondcount	EQU	GPRAM+23
scancount	EQU	GPRAM+24
capbuffer	EQU	GPRAM+25
capbufferend	EQU	0x60

;--------------------------------------------------------------------------
; Note:	4MHz / 4 = 1MHz. 1/1MHz = 1us.
;       So each PIC instruction takes one microsecond long.
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
;	TMR0	Used for timing head unit button command pulse width
;	RB[4..7] on Change
;		Used for recieving 19.2Kbps serial data from PC/PJRC
;--------------------------------------------------------------------------
	ORG	4
	movwf	intwsave	; preserve w register
	swapf	STATUS, w	; preserve status register
	movwf	intstatussave

	movf	TMR0, w		; save a copy of current TMR0 count
	movwf	captime		; in case PWTXCaptureBit needs it

	movf	FSR, w		; preserve FSR register
	movwf	intfsrsave
	
PWTXCaptureISR
	btfss	INTCON, INTF	; RB0/INT interrupt (PWTX Capture)?
	goto	TMR0ISR

	clrf	TMR0		; restart timer
	bcf		INTCON, INTF	; clear interrupt flag

	btfsc	GPIO, PWTX	
	goto	PWTXCaptureBit

PWTXStartTimer
	;; We have interrupted at beginning of low pulse (falling edge)
	;; Low pulse length must be timed to determine bit value

	bcf	INTCON, T0IF	; clear TMR0 overflow flag
	bsf	INTCON, T0IE	; enable TMR0 interrupt on overflow
	
	bsf	STATUS, RP0		; select data bank 1
	ERRORLEVEL -302
	bsf	OPTION_REG, INTEDG ; set interrupt on rising edge
	ERRORLEVEL +302
	bcf	STATUS, RP0		; go back to data bank 0

	goto	EndInterrupt

PWTXCaptureBit
	;; We have interrupted at beginning of high pulse (rising edge)
	;; High pulse length doesn't matter. We need to check out
	;; captured low pulse width if we are capturing data at the moment

	bsf	STATUS, RP0		; select data bank 1
	ERRORLEVEL -302
	bcf	OPTION_REG, INTEDG ; set interrupt on falling edge
	ERRORLEVEL +302
	bcf	STATUS, RP0		; go back to data bank 0

	btfss	INTCON, T0IE	; are we trying to capture data?
	goto	EndInterrupt

	bsf		progflags, capbusy
	bcf	INTCON, T0IE	; turn off capturing time for high pulse

	movf	capptr, w		; load capture pointer into indirect pointer
	movwf	FSR

	movlw	STARTTHRESHOLD	; is the timer counter larger than the START
	subwf	captime, w	; threshold value?
	btfss	STATUS, C
	goto	FilterNoise	; no, just a regular data bit

IF DUMPMODE == 1
	bsf		progflags, startbit
ENDIF
	;; don't store start bits, just frame around them
	clrf	capbittotal
	goto	StartNewByteIfNecessary

FilterNoise
	movlw	LOWTHRESHOLD	; is the timer count less than the
	subwf	captime, w	; LOWTHRESHOLD?
	btfss	STATUS, C
	goto	EndInterrupt	; yes, data invalid, possibly noise induced

	; no, go ahead and store this data	
SaveBit	
	movlw	HIGHTHRESHOLD	; is the timer count larger than the
	subwf	captime, w		; HIGH bit threshold value?
	rlf		INDF, f			; save captured bit into capture buffer

	incf	capbittotal, f
	incfsz	capbit, f		; have we collected all 8 bits?
	goto	EndInterrupt	; nope
	goto	StartNewByte	; yep, get ready to capture next 8 bits

TMR0ISR
	btfss	INTCON, T0IE	; is timer 0 overflow interrupt enabled?
	goto	EndInterrupt
	btfss	INTCON, T0IF	; if so, did a timer 0 overflow occur?
	goto	EndInterrupt

	bcf	INTCON, T0IE	; disable further timer 0 interrupts
	bcf	progflags, capbusy ; set flag signifying packet capture done

	movf	capptr, w		; load capture pointer into indirect pointer
	movwf	FSR

StartNewByteIfNecessary
	movlw	-8				; are we already capturing on a brand new blank byte?
	subwf	capbit, w
	btfsc	STATUS, Z
	goto	EndInterrupt	; yes, no need to increment to a new byte.

	;; Note: This should never happen on normal head unit sending 32 bit
	;; 		 command strings with error free data.
	;;
	;; if the capture bits were not a complete 8 bits, we need to finish
	;; rotating the bits upward so that the data is nicely formatted
	bsf		progflags, dataerror
RotateLoop
	bcf		STATUS, C		; rotate in 0 bit
	rlf		INDF, f
	incfsz	capbit, f		; have we finished rotating all bits up?
	goto	RotateLoop		; nope

StartNewByte
	movlw	-8				; start capturing 8 bits
	movwf	capbit

	incf	capptr, f		; move to new capture byte

	movlw	capbufferend	; have we gone past the end of the
	subwf	capptr, w		; capture buffer?
	btfss	STATUS, Z
	goto	ClearCapByte

	movlw	capbuffer		; yes, roll over to beginning
	movwf	capptr

ClearCapByte
	movf	capptr, w
	movwf	FSR	
	clrf	INDF			; clear capture byte (for incomplete captures)

EndInterrupt
	movf	intfsrsave, w	; restore indirect pointer
	movwf	FSR
	swapf	intstatussave, w; restore STATUS register
	movwf	STATUS
	swapf	intwsave, f		; restore w register
	swapf	intwsave, w
	retfie

;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
Start
	clrf	GPIO			; initialize port data latches

	movlw	capbuffer		; initialize PWTX capture pointer and
	movwf	capptr			; indirect pointer to capture buffer
	movwf	scanptr

	movwf	FSR
	clrf	INDF			; make first cap byte clear for capturing
	movlw	-8				; read 8 bits of data per byte
	movwf	capbit		
	
	movlw   COUT|CM1	; turn voltage comparators off so PORTA
	movwf   CMCON           ; can be used for regular i/o functions

	bsf	STATUS, RP0		; select data bank 1
	ERRORLEVEL -302
	bcf	TRISIO, SerialTX	; set SerialTX pin as output
	bcf	TRISIO, SerialTX9600
	bcf	TRISIO, SCLK		; set SCLK pin as output
	bcf	TRISIO, SRX		; set SRX pin as output
	clrwdt				; clear WDT & prescaler (avoids possible reset)
	clrf	WPU
	bsf	WPU, PWTX	; enable weak pull-up for PWTX
;	bsf	IOCB, PWTX	; enable interrupt on change for PWTX
;	clrf	ANSEL		; disable analog inputs (only for PIC12F675)
	bcf	OPTION_REG, NOT_GPPU; enable port pull-ups
	bsf	OPTION_REG, INTEDG ; interrupt on rising edge
	bcf	OPTION_REG, T0CS ; TMR0 clock source = internal clock count
	bcf	OPTION_REG, PSA	; assign prescaler to TMR0
	bsf	OPTION_REG, PS2	; prescaler 1:32
	bcf	OPTION_REG, PS1
	bcf	OPTION_REG, PS0

	call	3FFh		; get the calibration value
	movwf	OSCCAL		; set the calibration register
	
	ERRORLEVEL +302
	bcf	STATUS, RP0		; go back to data bank 0

	movlw	DISCSTART		; start with first disc number for head
	movwf	discload		; unit disc button enable packets.
	movlw	0xBE
	movwf	disc
	movlw	0xFE
	movwf	track
	
	movlw	1
	movwf	BIDIstate		; start in protocol state 1

	clrf	progflags
	clrf	poweridentcount

	bcf	INTCON, INTF	; clear RB0/INT interrupt flag
	bsf	INTCON, INTE	; enable interrupt on RB0 rising edge
	bsf	INTCON, GIE	; Global Interrupt Enable


	call	SendSerialIdentify
	call	SendSerialRING
	
	call	ResetTime

	bsf	PIR1, TMR1IF	; force first display update packet

IdleLoop
	btfss	PIR1, TMR1IF	; has REFRESH_PERIOD time passed?
	goto	IdleLoopSkipSend

	call	InitTIMER1	; reinitialize timer so we can send the
				; next packet at the right time

	call	SendPacket
	
	incf	poweridentcount, f	; only send the powered identify string
	btfsc	STATUS, Z		; once in a while
	call	SendSerialIdentify

	incfsz	scancount, f
	goto	SecondWait

	movlw	SCANWAIT
	movwf	scancount
	
	movlw	~(1<<scan)		; turn off scan display
	andwf	progflags, f

SecondWait
	incfsz	secondcount, f
	goto	IdleLoopSkipSend

	movlw	SECONDWAIT
	movwf	secondcount
	
	; increment the time display
SecondIncrement
	decf	second, f

	movlw	0x0F			; skip past hexidecimal codes
	andwf	second, w
	addlw	-0x05
	movlw	-6
	btfsc	STATUS, Z		; are with at xF?
	addwf	second, f		; yes, subtract 6 and we'll be at x0 instead
	
	movlw	0xA6			; have we gone beyond second 59?
	subwf	second, w
	btfsc	STATUS, C
	goto	IdleLoopSkipSend

	movlw	0xFF
	movwf	second			; yes, set back to second 00

MinuteIncrement
	decf	minute, f

	movlw	0x0F			; skip past hexidecimal codes
	andwf	minute, w
	addlw	-0x05
	movlw	-6
	btfsc	STATUS, Z		; are with at xF?
	addwf	minute, f		; yes, subtract 6 and we'll be at x0 instead
	
	movlw	0x66			; have we gone beyond 99?
	subwf	minute, w
	btfsc	STATUS, C
	goto	IdleLoopSkipSend

	movlw	0xFF
	movwf	minute			; yes, set back to 00

IdleLoopSkipSend
	btfss	progflags, dataerror ; has the command receive code detected
	goto	NoDataError	; a framing type data error?

	bcf	progflags, dataerror ; clear error flag
	movlw	'D'
	call	SendSerial
	movlw	'a'
	call	SendSerial
	movlw	't'
	call	SendSerial
	movlw	'a'
	call	SendSerial

	movlw	'E'
	call	SendSerial
	movlw	'r'
	call	SendSerial
	movlw	'r'
	call	SendSerial
	movlw	'o'
	call	SendSerial
	movlw	'r'
	call	SendSerial
	call	SendNEWLINE

NoDataError
IF DUMPMODE == 1
	btfss	progflags, startbit ; have we just recieved a start bit?
	goto	DumpLoop

	bcf		progflags, startbit ; yes, start a new line
	call	SendNEWLINE

DumpLoop
	call	GetCaptureByte	; do we have data to dump?
	btfsc	STATUS, Z
	goto	IdleLoop	; no, exit dump loop
	movf	scanbyte, w	; yes, dump it.
	call	SendSerialHex
	goto	DumpLoop
ELSE
	call	ScanButtons
ENDIF
	goto	IdleLoop

;--------------------------------------------------------------------------
; InitTIMER1 - Reloads the registers associated with TIMER1 so that we
;	will get a flag for the next display update packet send within
;	REFRESH_PERIOD time.
;--------------------------------------------------------------------------
InitTIMER1
	bcf	T1CON, TMR1ON	; turn off timer while reloading wait period
	movlw	high (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
	movwf	TMR1H
	movlw	low (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
	movwf	TMR1L
	bcf	PIR1, TMR1IF	; clear old overflow (if any)
	movlw	00110001b		; 1:8 prescale, internal clock, tmr1 enabled.
	movwf	T1CON
	return

SendSerialIdentify
	movlw	'V'
	call	SendSerial
	movlw	'W'
	call	SendSerial
	movlw	'C'
	call	SendSerial
	movlw	'D'
	call	SendSerial
	movlw	'P'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'C'
	call	SendSerial
	movlw	VER_MAJOR
	call	SendSerial
	movlw	'.'
	call	SendSerial
	movlw	VER_MINOR
	call	SendSerial
	goto	SendNEWLINE

SendSerialRING
	movlw	'R'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'N'
	call	SendSerial
	movlw	'G'
	call	SendSerial
	goto	SendNEWLINE
	
		
;--------------------------------------------------------------------------
; ScanButtons - Looks in the button recieve packet buffer and tries
;	to match known button push packets.
;--------------------------------------------------------------------------
ScanButtons
	movf	scanptr, w		; load FSR register
	movwf	FSR
	
FirstByteLoop
	call	GetCaptureByte
	btfsc	STATUS, Z
	return

FirstByteTest
	movlw	0x53
	subwf	scanbyte, w
	btfsc	STATUS, Z
	goto	SecondByte

	;; this byte doesn't match the beginning of a normal command packet,
	;; dump it for display and slide window to next byte.
	movf	scanbyte, w
	call	SendSerialHex
	call	SendNEWLINE
	
	goto	FirstByteLoop
	
SecondByte
	call	GetCaptureByte
	btfsc	STATUS, Z
	return

	movlw	0x2C
	subwf	scanbyte, w
	btfss	STATUS, Z
	goto	FirstByteTest

ThirdByte
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	movwf	buttonbyte1

FourthByte
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	movwf	buttonbyte2

	; if execution reaches here, we have verified that 
	; bytes 1 and 2 are valid for a command packet.

	call	ButtonDN
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonUP
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonSCAN
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonMIX
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonSEEKFW
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonSEEKBK
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD1
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD2
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD3
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD4
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD5
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	ButtonCD6
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	MonsoonEnable
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	MonsoonDisable
	btfsc	STATUS, Z
	goto	ScanButtonsEnd

	call	MonsoonInquiry
	btfsc	STATUS, Z
	goto	ScanButtonsEnd
	
	; if execution reaches here, we have verified that 
	; bytes 1 and 2 are valid for a button packet, but
	; the packet recieved is not one that we understand,
	; so lets dump the data for the user to view.
DumpPacket
	movf	scanptr, w		; restart back at the beginning of the packet
	movwf	FSR

	call	GetCaptureByte	; send byte 1
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	SendSerialHex

	call	GetCaptureByte	; send byte 2
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	SendSerialHex

	call	GetCaptureByte	; send byte 3
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	SendSerialHex
	
	call	GetCaptureByte	; send byte 4
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	SendSerialHex

	call	SendNEWLINE
		
ScanButtonsEnd
	movf	FSR, w			; save new scanptr
	movwf	scanptr
	return

FailedPacket
	movlw	2
	addwf	scanptr, f		; skip first two bytes next time
	return

;--------------------------------------------------------------------------
; Button Push Packets
;--------------------------------------------------------------------------
; 532C609F Mix 1
; 532CE01F Mix 6
; 532CA05F Scan
;	  Note: Blaupunkt Gamma V head unit will continue to send scan key code
;		unless display is switched into scan mode. 
;		(reported by tony.gilbert@orange.co.uk)
; 532C10EF Head Unit mode change. Emitted at power up, power down, and
;		 any mode change. (disable playing)
; 532C58A7 Seek Back Pressed
; 532CD827 Seek Forward Pressed
; 532C7887 Dn
; 532CA857 Dn on Mk3 premium (Adam Yellen <adam@yellen.com>)
; 532CF807 Up
; 532C6897 Up on Mk3 premium (Adam Yellen)
; 532C38C7 CD Change (third packet)
; 532CE41B Seek Forward Released (enable playing)
; 532CE41B Seek Back Released (enable playing)
; 532CE41B CD Mode selected. Emitted at power up (if starting in CD 
;			 mode), change to CD mode. (enable playing)
; 532C14EB CD Change (second packet)
; 532C0CF3 CD 1 (first packet)
; 532C8C73 CD 2 (first packet)
; 532C4CB3 CD 3 (first packet)
; 532CCC33 CD 4 (first packet)
; 532C2CD3 CD 5 (first packet)
; 532CAC53 CD 6 (first packet)
;
; Monsoon State Changes:
; 532CE41B enable playing (transition to State 2)
; 532C38C7 disc loaded inquiry (transition to State 5)
; 532C10EF disable playing (transition to State 1)
;--------------------------------------------------------------------------
; Archos Jukebox Serial Commands
; E0 Volume Down
; D0 Volume Up
; C8 Next (+)
; C4 Previous (-)
; C2 Stop
; C1 Play
;--------------------------------------------------------------------------
MonsoonEnable
	movlw	0xE4
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x1B
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

; Added by Svet
;
; We take action upon reception of the MonsoonEnable command
; only if we are currently in BIDIState1 (I call this Idle
; State). Then we go through BIDIState2, BIDIState3, BIDIState5
; (Unmute State) and end in BIDIState4 (Active State). If we
; are in any other state there is no need to respond to
; MonsoonEnable commands since we have already started the
; transitional process to Active State. And if we respond to them
; this will only cause delay in the transition, thus causing the
; "Initial Delay Problem" experinced with some DD Monsoon head
; units. I don't know why, but for some reason these head units
; will issue upto twelve MonsoonEnable commands in the beginning.
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.
; It might even improve the behaviour with the Single DIN In-Dash
; CD Player.
	movlw	1
	subwf	BIDIstate, w
	btfsc	STATUS, Z
	call	SetState2	;Skip this if not in BIDIState1

	movlw	'M'
	call	SendSerial
	movlw	'E'
	call	SendSerial
	movlw	'N'
	call	SendSerial
SendABLE
	movlw	'A'
	call	SendSerial
	movlw	'B'
	call	SendSerial
	movlw	'L'
	call	SendSerial
	movlw	'E'
	call	SendSerial
	goto	SendNEWLINE

MonsoonInquiry
	movlw	0x38
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xC7
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

;;;;	call	SetState5
; Commented by Svet
;
; We do not take any action upon reception of MonsoonInquiry
; command. The "MINQUIRY" string is only printed out to
; indicate we recognised the command. We will go through
; BIDIState5 if we receive MonsoonEnable, ButtonCDx, ButtonUP,
; ButtonDN command in order to unmute the audio.
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	movlw	'M'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'N'
	call	SendSerial
	movlw	'Q'
	call	SendSerial
	movlw	'U'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'R'
	call	SendSerial
	movlw	'Y'
	call	SendSerial
	goto	SendNEWLINE

MonsoonDisable
	movlw	0x10
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xEF
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	movlw	0xBE
	movwf	disc			; set back to CD 1
	
	movlw	1				; goto State1
	movwf	BIDIstate

	call	ResetTime

	movlw	DISCSTART		; get sendpacket to send the disc loading
	movwf	discload		; packets again (enables CD number buttons)

	movlw	'M'
	call	SendSerial
	movlw	'D'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'S'
	call	SendSerial
	goto	SendABLE

ButtonSEEKBK
	movlw	0x58
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xA7
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	ResetTime

	incf	disc, f

	movlw	0xBF			; have we gone below CD 1?
	subwf	disc, w
	movlw	0xBE
	btfsc	STATUS, C
	movwf	disc			; yes, set back to CD 1

	movlw	0xE0			; Archos Volume Down
	call	SendSerial9600

	movlw	'P'
	call	SendSerial
	movlw	'R'
	call	SendSerial
	movlw	'V'
	call	SendSerial
	goto	Send_LIST

; BE - CD 1
; BD - CD 2
; BC - CD 3
; BB - CD 4
; BA - CD 5
; B9 - CD 6

ButtonSEEKFW
	movlw	0xD8
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x27
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	ResetTime
	decf	disc, f

	movlw	0xB9			; have we gone above CD 6?
	subwf	disc, w
	movlw	0xB9
	btfss	STATUS, C
	movwf	disc			; yes, set back to CD 6
	; Note: Going beyond CD9 displays hex codes on premium head unit (CD A, CD B, CD C, etc).
	;		Going beyond CD6 mutes on monsoon head unit.

	movlw	0xD0			; Archos Volume Up
	call	SendSerial9600

	movlw	'N'
	call	SendSerial
	movlw	'X'
	call	SendSerial
	movlw	'T'
	call	SendSerial
Send_LIST
	movlw	'_'
	call	SendSerial
	movlw	'L'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'S'
	call	SendSerial
	movlw	'T'
	call	SendSerial
SendNEWLINE
	movlw	13
	call	SendSerial
	movlw	10
	call	SendSerial

	bsf	STATUS, Z
	return

ButtonMIX
	movlw	0x60			; Mix 1
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	goto	ButtonMIX6		; might still be pressing mix button, check other code
		
	movlw	0x9F
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

ButtonMIX_Toggle
	movlw	1<<mix			; toggle mix display
	xorwf	progflags, f

	movlw	0xC2			; Archos Stop
	call	SendSerial9600

	movlw	'R'
	call	SendSerial
	movlw	'A'
	call	SendSerial
	movlw	'N'
	call	SendSerial
	movlw	'D'
	call	SendSerial
	movlw	'O'
	call	SendSerial
	movlw	'M'
	call	SendSerial
	goto	SendNEWLINE

ButtonMIX6
	movlw	0xE0			; Mix 6
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return

	movlw	0x1F			; Mix 6
	subwf	buttonbyte2, w
	btfsc	STATUS, Z
	goto	ButtonMIX_Toggle

	return	

ButtonSCAN
	movlw	0xA0
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x5F
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	movlw	1<<scan			; toggle scan display
	xorwf	progflags, f
	movlw	SCANWAIT
	movwf	scancount

	movlw	0xC1			; Archos Play/Pause
	call	SendSerial9600

	movlw	'P'				; this will make the PJRC play/pause
	call	SendSerial
	movlw	'L'
	call	SendSerial
	movlw	'A'
	call	SendSerial
	movlw	'Y'
	call	SendSerial
	goto	SendNEWLINE

ButtonUP
	movlw	0xF8
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	goto	ButtonUP_MK3	; might be MK3 up code, check it instead

	movlw	0x07
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

FoundButtonUP
	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonUP command, otherwise the audio will remain muted.
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

TrackIncrement
	decf	track, f

	movlw	0x0F			; skip past hexidecimal codes
	andwf	track, w
	addlw	-0x05
	movlw	-6
	btfsc	STATUS, Z		; are with at xF?
	addwf	track, f		; yes, subtract 6 and we'll be at x0 instead
	
	movlw	0x66			; have we gone beyond Track 99?
	subwf	track, w
	movlw	0x66
	btfss	STATUS, C
	movwf	track			; yes, set back to Track 99

	movlw	0xC8			; Archos Next (+)
	call	SendSerial9600
	
	movlw	'N'
	call	SendSerial
	movlw	'E'
	call	SendSerial
	movlw	'X'
	call	SendSerial
	movlw	'T'
	call	SendSerial
	goto	SendNEWLINE

ButtonUP_MK3
	movlw	0x68
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x97
	subwf	buttonbyte2, w
	btfsc	STATUS, Z
	goto	FoundButtonUP
	
	return	

ButtonDN
	movlw	0x78
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	goto	ButtonDN_MK3	; maybe code for button DN on MK3, check it instead

	movlw	0x87
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

FoundButtonDN
	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonDN command, otherwise the audio will remain muted.
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime
TrackDecrement
	incf	track, f

	movlw	0x0F			; skip past hexidecimal codes
	andwf	track, w
	movlw	6
	btfsc	STATUS, Z		; are with at xA?
	addwf	track, f		; yes, add 6 and we'll be at x9 instead

	movlw	0xFF			; have we gone below Track 1?
	subwf	track, w
	movlw	0xFE
	btfsc	STATUS, C
	movwf	track			; yes, set back to Track 1

	movlw	0xC4			; Archos Previous (-)
	call	SendSerial9600
	
	movlw	'P'
	call	SendSerial
	movlw	'R'
	call	SendSerial
	movlw	'E'
	call	SendSerial
	movlw	'V'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'O'
	call	SendSerial
	movlw	'U'
	call	SendSerial
	movlw	'S'
	call	SendSerial
	goto	SendNEWLINE

ButtonDN_MK3
	movlw	0xA8
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x57
	subwf	buttonbyte2, w
	btfsc	STATUS, Z
	goto	FoundButtonDN

	return

ButtonCD1
	movlw	0x0C
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xF3
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	movlw	0xBF - 1
	movwf	disc			; set CD 1

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	call	SendLISTNo
	movlw	'1'
	call	SendSerial
	goto	SendNEWLINE

ButtonCD2
	movlw	0x8C
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x73
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	movlw	0xBF - 2
	movwf	disc			; set CD 2

	call	SendLISTNo
	movlw	'2'
	call	SendSerial
	goto	SendNEWLINE

ButtonCD3
	movlw	0x4C
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xB3
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	movlw	0xBF - 3
	movwf	disc			; set CD 3

	call	SendLISTNo
	movlw	'3'
	call	SendSerial
	goto	SendNEWLINE

ButtonCD4
	movlw	0xCC
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x33
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	movlw	0xBF - 4
	movwf	disc			; set CD 4

	call	SendLISTNo
	movlw	'4'
	call	SendSerial
	goto	SendNEWLINE

ButtonCD5
	movlw	0x2C
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0xD3
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	movlw	0xBF - 5
	movwf	disc			; set CD 5

	call	SendLISTNo
	movlw	'5'
	call	SendSerial
	goto	SendNEWLINE

ButtonCD6
	movlw	0xAC
	subwf	buttonbyte1, w
	btfss	STATUS, Z
	return	

	movlw	0x53
	subwf	buttonbyte2, w
	btfss	STATUS, Z
	return	

	call	SetState5
; Added by Svet
;
; We need to go through BIDIState5 (Unmute State) if we receive
; ButtonCDx command, otherwise the audio will remain muted.
; Remember, we no longer respond to MonsoonInquiry command - the
; third command sent when we press buttons 1...6 - that used to
; call SetState5
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

	call	ResetTime

	movlw	0xBF - 6
	movwf	disc			; set CD 6

	call	SendLISTNo
	movlw	'6'
	call	SendSerial
	goto	SendNEWLINE

SendLISTNo
	movlw	'L'
	call	SendSerial
	movlw	'I'
	call	SendSerial
	movlw	'S'
	call	SendSerial
	movlw	'T'
	call	SendSerial
	return

;--------------------------------------------------------------------------
; GetCaptureByte
; Returns: STATUS Z bit set - no more bytes to collect
; 	   STATUS Z bit clear - scanbyte contains next byte, FSR inc'd
;--------------------------------------------------------------------------
GetCaptureByte
	movf	FSR, w			; have we already caught up with capturer?
	subwf	capptr, w
	btfsc	STATUS, Z
	return

	movf	INDF, w			; get a byte from the capture buffer
	movwf	scanbyte

	incf	FSR, 1
	movlw	capbufferend	; have we overflowed the 
	subwf	FSR, w			; capture buffer?
	btfss	STATUS, Z
	return

	movlw	capbuffer		; yes, roll over to beginning
	movwf	FSR		
	bcf	STATUS, Z
	return			


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

;-----------------------------------------------------
; Display Update Packets
;-----------------------------------------------------
BIDIstate1
	movlw	0x74
	call	SendByte

	call	SendDisplayBytes

	movlw	0x8F
	call	SendByte
	movlw	0x7C
	call	SendByte
	return

SetState2
	movlw	2
	movwf	BIDIstate
	movlw	-2
	movwf	BIDIcount
	return
; State 2:
;  packet = 2
;  cnt = 2 then transition to State 3
;  dbuf[0] = $94
;  dbuf[1] = $BE
;  dbuf[2] = $FE
;  dbuf[3] = $FF
;  dbuf[4] = $FF
;  dbuf[5] = $FF
;  dbuf[6] = $AE
;  dbuf[7] = $9C
BIDIstate2
	movlw	0x94
	call	SendByte

	call	SendDisplayBytes	; maybe this won't work, might need above bytes instead.

	movlw	0xAE
	call	SendByte
	movlw	0x9C
	call	SendByte

	incfsz	BIDIcount, f
	return
;	goto	SetState3

SetState3
	movlw	3
	movwf	BIDIstate
	movlw	-20
	movwf	BIDIcount
	return

; State 3:
;  packet = 3
;  cnt = 20 then transition to State 4
;  dbuf[0] = $34
;  dbuf[1] = $BE
;  dbuf[2] = $FE
;  dbuf[3] = $FF
;  dbuf[4] = $FF
;  dbuf[5] = $FF
;  dbuf[6] = $AE
;  dbuf[7] = $3C
BIDIstate3
	movlw	0x34
	call	SendByte

	call	SendDisplayBytes	; maybe this won't work, might need above bytes instead.

	movlw	0xAE
	call	SendByte
	movlw	0x3C
	call	SendByte

	incfsz	BIDIcount, f
	return
	goto	SetState5
; Modified by Svet
;
; After BIDIState3 We need to go through BIDIState5 (Unmute State)
; and then end in BIDIState4.
; This thansition from BIDIState1 to BIDIState2, to BIDIState3,
; then to BIDIState5 and finaly to BIDIState4 is done only once,
; when we receive the first MonsoonEnable command.
;
; These changes are needed for the new DD Monsoon head units.
; I hope they will not cause any problems with the other head
; units that were working fine.

SetState4
	movlw	4
	movwf	BIDIstate
	return
; State 4:
;  packet = 4
;  cnt = -1
;  dbuf[0] = $34
;  dbuf[1] = $BE
;  dbuf[2] = $FE
;  dbuf[3] = $FF
;  dbuf[4] = $FF
;  dbuf[5] = $FF
;  dbuf[6] = $CF
;  dbuf[7] = $3C
BIDIstate4
	movlw	0x34
	call	SendByte

	call	SendDisplayBytes

	movlw	0xCF
	call	SendByte
	movlw	0x3C
	call	SendByte
	return

; State 5:
;  packet = 5
;  cnt = 2 then transition to State 4
;  dbuf[0] = $14
;  dbuf[1] = $2E
;  dbuf[2] = $FF
;  dbuf[3] = $FF
;  dbuf[4] = $FF
;  dbuf[5] = $FF
;  dbuf[6] = $FF
;  dbuf[7] = $1C
SetState5
	movlw	5
	movwf	BIDIstate
	movlw	-2
	movwf	BIDIcount
	return
BIDIstate5
	movlw	0x14
	call	SendByte

; Modified by Svet
;
; YES, we can send display update bytes here instead of 0xFF's
;
; I hope this will not cause any problems with any head unit.

	call	SendDisplayBytes
;;;;	movlw	0x2E 	; ??
;;;;	call	SendByte
;;;;	movlw	0xFF 	; 2 can do display update bytes here??
;;;;	call	SendByte
;;;;	movlw	0xFF	; 3
;;;;	call	SendByte
;;;;	movlw	0xFF 	; 4
;;;;	call	SendByte
;;;;	movlw	0xFF 	; 5
;;;;	call	SendByte

	movlw	0xFF 	; 6
	call	SendByte
	movlw	0x1C
	call	SendByte

	incfsz	BIDIcount, f
	return
	goto	SetState4


SendDisplayBytes
	movlw	DISCMAX		; are we trying to load CDs into head unit?
	subwf	discload, w
	movf	disc, w		; disc display value
	btfsc	STATUS, C
	goto	SendDisc	; no, just display disc number instead of load packets
	
	incf	discload, f	
	movlw	DISCMIN		; are we finished waiting to load CDs into head unit?
	subwf	discload, w
	movf	disc, w		; disc display value
	btfss	STATUS, C
	goto	SendDisc	; no, we must wait some more display packets first
	
	movf	discload, w	; yes, send a disc load packet

SendDisc
	call	SendByte

	movf	track, w
	call	SendByte

;	movlw	0xFF		; min?
	movf	minute, w	
	call	SendByte
;	movlw	0xFF		; sec?
	movf	second, w
	call	SendByte

	movlw	0xFB		; mode (scan/mix)
	btfss	progflags, mix
	iorlw	0x0F		; turn off mix light

	btfsc	progflags, scan
	andlw	0x2F		; turn on scan display

	call	SendByte
	return

ResetTime
	movlw	0xFF
	movwf	second
	movwf	minute
	return

;--------------------------------------------------------------------------
; ReceiveClearSpin - Spins CPU cycles until capturing is believed to be 
; 	done
;--------------------------------------------------------------------------
ReceiveClearSpin
	btfss	progflags, capbusy
	return						; if we're not capturing, exit wait loop.

	movlw	32					; if we've got 32 bits since last start
	subwf	capbittotal, w		; bit, we're probably okay for a while
	btfsc	STATUS, C
	return
	
	goto	ReceiveClearSpin	; busy capturing, don't mask int

;--------------------------------------------------------------------------
; SendByte - sends a byte to head unit.
;            load byte to send to head unit into W register before calling
;--------------------------------------------------------------------------
SendByte
	movwf	sendreg

	movlw	-8			; send 8 bits of data
 	movwf	sendbitcount

;;	call	ReceiveClearSpin	; make sure we've okay to mask interrupts
;;	movf	GPIO, w
;;	bcf		INTCON, GIE	; disable interrupts, timing critical code

BitLoop
	iorlw	(1<<SCLK)	; SCLK high
	movwf	GPIO
        
	andlw   ~(1<<SRX)	; load the next bit onto SRX
	rlf	sendreg, 1	; load the next bit into the carry flag
	btfsc	STATUS, C
	iorlw	(1<<SRX)
	movwf	GPIO

	andlw	~(1<<SCLK)	; SCLK low
	movwf	GPIO
	call	Wait30		; timing delay to soften emi noise.

	incfsz	sendbitcount, f	; exit loop if we've transferred 8 bits already
	goto	BitLoop

;;	bsf		INTCON, GIE	; re-enable interrupts
	
;	movlw	-84			; wait 335us for head unit to store sent byte - doesn't work so good on late 2003 wolfsburg double din
	movlw	-175		; wait 700us for head unit to store sent byte
DelayLoop				
	addlw	1
	btfss	STATUS, Z
	goto	DelayLoop

	return

;--------------------------------------------------------------------------
; SendSerialHex - Sends byte provided in the W register using SendSerial.
;	The byte is converted to a two byte ASCII hexidecimal string
;--------------------------------------------------------------------------
SendSerialHex
	movwf	sendhexreg
	swapf	sendhexreg, w	; send high nibble first
	andlw	0x0F
	addlw	-10				; less than 10?
	btfsc	STATUS, C
	addlw	'A' - ('0' + 10); no, we're in the range [Ah..Fh]
	addlw	'0' + 10		; yes, range [0..9]
	call	SendSerial

	movf	sendhexreg, w	; now send low nibble
	andlw	0x0F
	addlw	-10
	btfsc	STATUS, C
	addlw	'A' - ('0' + 10)
	addlw	'0' + 10
	goto	SendSerial		; use SendSerial's return to return to caller
	
;--------------------------------------------------------------------------
; SendSerial - Sends 19.2Kbps 8 bit serial data using bit banging.
;	Place byte to transmit into W register before calling.
;	Interrupts will be temporarily disabled by this routine. On return,
;	interrupts will be enabled.
;--------------------------------------------------------------------------
SendSerial
	movwf	sendreg
	movlw	-9		; send 8 bits
	movwf	sendbitcount

	call	ReceiveClearSpin	; make sure we've okay to mask interrupts
	bcf	INTCON, GIE	; disable interrupts, timing critical code

	movf	GPIO, w
	; initially send start bit
LowBit
	iorlw	(1<<SerialTX)
	movwf	GPIO		; 1
	nop			; 1
	call	Wait42

BitCount
	incf	sendbitcount, f ; 1
	btfsc	STATUS, Z	; 1 2 exit loop if we've transferred 8 bits already
	goto    StopBit		; 2

	rrf	sendreg, 1	; 1 load next bit into carry flag
	btfss	STATUS, C       ; 1 2
	goto	LowBit          ; 2

	andlw	~(1<<SerialTX)  ; 1
	movwf	GPIO		; 1
	call	Wait42
	goto    BitCount        ; 2

StopBit
	goto    $+1		; 2
	andlw	~(1<<SerialTX)
	movwf	GPIO
	bsf	INTCON, GIE	; enable interrupts, timing critical code done
	call	Wait44
	return

;--------------------------------------------------------------------------
; SendSerial9600 - Sends 9600bps 8 bit serial data using open drain bit 
; banging
;	Place byte to transmit into W register before calling.
;	Interrupts will be temporarily disabled by this routine. On return,
;	interrupts will be enabled.
;--------------------------------------------------------------------------
SendSerial9600
	movwf	sendreg
	movlw	-9		; send 8 bits
	movwf	sendbitcount

	call	ReceiveClearSpin	; make sure we've okay to mask interrupts
	bcf	INTCON, GIE	; disable interrupts, timing critical code

	; initially send start bit
LowBit9600
	bsf	STATUS, RP0	; select data bank 1
	ERRORLEVEL -302
	bcf	TRISIO, SerialTX9600 ; set SerialTX9600 pin as output/drain (low)
	ERRORLEVEL +302
	bcf	STATUS, RP0			; go back to data bank 0
	call	Wait46
	call	Wait46
	goto	$+1				; 94	

BitCount9600
	incf	sendbitcount, f ; 1
	btfsc	STATUS, Z	; 1 2 exit loop if we've transferred 8 bits already
	goto    StopBit9600	; 2

	rrf	sendreg, 1	; 1 load next bit into carry flag
	btfss	STATUS, C       ; 1 2
	goto	LowBit9600      ; 2

	bsf	STATUS, RP0			; select data bank 1
	ERRORLEVEL -302
	bsf	TRISIO, SerialTX9600 ; set SerialTX9600 pin as input/open (high)
	ERRORLEVEL +302
	bcf	STATUS, RP0			; go back to data bank 0
	call	Wait46
	call	Wait46
	nop						
	goto    BitCount9600    ; 2

StopBit9600
	nop
	nop
	bsf	STATUS, RP0		; select data bank 1
	ERRORLEVEL -302
	bsf	TRISIO, SerialTX9600 ; set SerialTX9600 pin as input/open (high)
	ERRORLEVEL +302
	bcf	STATUS, RP0		; go back to data bank 0
	bsf	INTCON, GIE		; enable interrupts, timing critical code done
	call	Wait48
	call	Wait48			; 96

	return

;--------------------------------------------------------------------------
; WaitXX - Burns cpu cycles for timing purposes. XX = number of cycles
;--------------------------------------------------------------------------
Wait56
	goto    $+1	; 56
	goto    $+1	; 54
	goto    $+1	; 52
	goto    $+1	; 50
Wait48
	goto    $+1	; 48
Wait46
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
Wait30
	goto    $+1	; 30
Wait28
	goto    $+1	; 28
Wait26
	goto    $+1	; 26
Wait24
	goto    $+1	; 24
Wait22
	goto    $+1	; 22
Wait20
	goto    $+1	; 20
Wait18
	goto    $+1	; 18
Wait16
	goto    $+1	; 16
Wait14
	goto    $+1	; 14
Wait12
	goto    $+1	; 12
Wait10
	goto    $+1	; 10
Wait8
	goto    $+1	; 8
Wait6
	goto    $+1	; 6
	return		; 4 (initial call used 2)


;--------------------------------------------------------------------------
; SendPacket - sends a display update packet to the head unit
;              currently hard coded to display "CD 1 Tr 1" on head unit
;--------------------------------------------------------------------------
	ORG	1013	;note: you must decrease this number if you add 
			;additional code below here.
SendPacket
; Monsoon requires use of 5 different states. This jumps to the correct
; state given the current value in the BIDIstate register.
	movlw	HIGH SendPacket
	movwf	PCLATH
	movf	BIDIstate, w
	addwf	PCL, f			
	nop						
	goto	BIDIstate1	
	goto	BIDIstate2
	goto	BIDIstate3
	goto	BIDIstate4
	goto	BIDIstate5

	ORG 2100h
	de		"VWCDPIC Firmware v", VER_MAJOR, ".", VER_MINOR, "\n"
	de		"Copyright (c) 2003, Edward Schlunder <ed@k9spud.com>\n"
	de		"Licensed under GNU General Public License v2.\n"

	END


