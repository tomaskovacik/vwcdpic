;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VW CD Changer Protocol Implementation	(For use on PIC12F629 at 4MHz/5VDC)		;
; Original Code Copyright (c) 2002-2004, Edward Schlunder <ed@NOSPAM.k9spud.com>	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program is free software; you can redistribute it and/or				;
; modify it under the terms of the GNU General Public License				;
; as published by the Free Software Foundation; either version 2			;
; of the License, or (at your option) any later version.				;
;											;
; This program is distributed in the hope that it will be useful,			;
; but WITHOUT ANY WARRANTY; without even the implied warranty of			;
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the				;
; GNU General Public License for more details.						;
;											;
; You should have received a copy of the GNU General Public License			;
; along with this program; if not, write to the Free Software				;
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.		;
;											;
; If you sell devices derived from this software, make sure you read			;
; and strictly adhere to the provisions set forth in the GNU General Public		;
; License. Specifically, any modifications you make to this source code			;
; must be made available to the public under the GNU GPL.				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Firmware Evolution Credits								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Edward Schlunder <ed@NOSPAM.k9spud.com> - Original VWCDPIC Firmware			;
; Andy Wilson <awilson@NOSPAM.microsoft.com> - Monsoon protocol info			;
; Paul Stewart <stewart@NOSPAM.parc.com> - Monsoon debugged code			;
; Svetoslav Vassilev <svetoslav.vassilev@NOSPAM.excite.com> - Double DIN fixes		;
; Tony Gilbert <tony.gilbert@NOSPAM.orange.co.uk> - Blaupunkt Gamma V codes		;
; Adam Yellen <adam@NOSPAM.yellen.com> - Mk3 command codes				;
; Paul Burgess <pburgess@NOSPAM.babson.edu> - Audi Concert command codes		;
; Hans-Dieter Wohlmuth <hans-dieter.wohlmuth@NOSPAM.infineon.com> -			;
;		Suggested changes to improve Audi Concert II remote control capability.	;
; Carlo Zaskorski <kittydog42@NOSPAM.earthlink.net> -					;
;		iPod 'Mode 4' support and iPod specific code optimization		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LIST P=12F629, R=DEC
	__CONFIG _BODEN_ON & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _CP_OFF & _INTRC_OSC_NOCLKOUT

#include <p12f629.inc>
#define SPIO GPIO
#define HPIO GPIO
#define INTPORT GPIO
#define STRISIO TRISIO
#define CRCMOD 	da	0x4BB

SCLK	EQU	5
SRX	EQU	4
PWTX	EQU	2
iPodSerialTX	EQU	1					
STARTTHRESHOLD	EQU	100			
HIGHTHRESHOLD	EQU	39			
LOWTHRESHOLD	EQU	8			
PKTSIZE		EQU	-32			
REFRESH_FAST	EQU	55
REFRESH_SLOW	EQU	5240
REFRESH_PERIOD	EQU	100			
SECONDWAIT	EQU	-10			
SCANWAIT	EQU	-50			
GPRAM		EQU	32
sendreg		EQU	GPRAM+0
sendbitcount	EQU	GPRAM+1	
disc		EQU	GPRAM+2
track		EQU	GPRAM+3
minute		EQU	GPRAM+4
second		EQU	GPRAM+5		
scanptr		EQU	GPRAM+6		
scanbyte	EQU	GPRAM+7		
cmdcode		EQU	GPRAM+8		
intwsave	EQU	GPRAM+9
intstatussave	EQU	GPRAM+10
intfsrsave	EQU	GPRAM+11
progflags	EQU	GPRAM+12
capbusy		EQU	0
mix		EQU	1
scan		EQU	2
playing		EQU	3
overflow	EQU	5
dataerr		EQU	6
captime		EQU	GPRAM+13
capbit		EQU	GPRAM+14	
capbitpacket	EQU	GPRAM+15	
capptr		EQU	GPRAM+16	
BIDIstate	EQU	GPRAM+17	
BIDIcount	EQU	GPRAM+18	
ACKcount	EQU	GPRAM+19	
discload	EQU	GPRAM+20	
secondcount	EQU	GPRAM+21
scancount	EQU	GPRAM+22	
txinptr		EQU	GPRAM+23
txoutptr	EQU	GPRAM+24
txbuffer	EQU	GPRAM+25
txbufferend	EQU	GPRAM+38	
txwaitcount	EQU	GPRAM+38	
capbuffer	EQU	GPRAM+39	
capbufferend	EQU	GPRAM+64

	ORG	0
	clrf	HPIO				

	movlw   (1<<CM2)|(1<<CM1)|(1<<CM0)
	movwf   CMCON				
	goto	Start

	ORG	4
	movwf	intwsave		
	swapf	STATUS, w			
	movwf	intstatussave
	movf	TMR0, w			
	movwf	captime				
	movf	FSR, w				
	movwf	intfsrsave
	
PWTXCaptureISR:
	btfss	INTCON, INTF		
	goto	TMR0ISR
	clrf	TMR0				
	bcf	INTCON, INTF		
	btfsc	INTPORT, PWTX
	goto	PWTXCaptureBit

PWTXStartTimer:
	bcf	INTCON, T0IF		
	bsf	INTCON, T0IE		
	bsf	STATUS, RP0			
	ERRORLEVEL -302
	bsf	OPTION_REG, INTEDG	
	ERRORLEVEL +302
	bcf	STATUS, RP0		
	goto	EndInterrupt

PWTXCaptureBit:
	bsf	STATUS, RP0	
	ERRORLEVEL -302
	bcf	OPTION_REG, INTEDG	
	ERRORLEVEL +302
	bcf	STATUS, RP0			
	btfss	INTCON, T0IE		
	goto	EndInterrupt
	bsf	progflags, capbusy
	bcf	INTCON, T0IE		
	movlw	STARTTHRESHOLD		
	subwf	captime, w			
	btfss	STATUS, C
	goto	FilterNoise			
	movlw	PKTSIZE				
	movwf	capbitpacket
	goto	StartNewByteIfNecessary

FilterNoise:
	movlw	LOWTHRESHOLD		
	subwf	captime, w			
	btfss	STATUS, C
	goto	EndInterrupt		

SaveBit:
	movf	capptr, w			
	movwf	FSR
	movlw	HIGHTHRESHOLD		
	subwf	captime, w			
	rlf	INDF, f				
	incfsz	capbitpacket, f
	goto	IncrementCaptureBit
	bcf	progflags, capbusy	

IncrementCaptureBit:
	incfsz	capbit, f			
	goto	EndInterrupt		
	goto	StartNewByte		

TMR0ISR:
	btfss	INTCON, T0IE		
	goto	EndInterrupt
	btfss	INTCON, T0IF		
	goto	EndInterrupt
	bcf	INTCON, T0IE		
	bcf	progflags, capbusy	

StartNewByteIfNecessary:
	movlw	-8					
	subwf	capbit, w
	btfsc	STATUS, Z
	goto	EndInterrupt		
	bsf	progflags, dataerr
	movf	capptr, w			
	movwf	FSR

RotateLoop:
	bcf	STATUS, C			
	rlf	INDF, f
	incfsz	capbit, f			
	goto	RotateLoop			

StartNewByte:
	movlw	-8					
	movwf	capbit
	incf	capptr, f			
	movlw	capbufferend		
	subwf	capptr, w			
	movlw	capbuffer			
	btfsc	STATUS, Z
	movwf	capptr
	movf	capptr, w
	subwf	scanptr, w		
	btfsc	STATUS, Z
	bsf	progflags, overflow

EndInterrupt:
	movf	intfsrsave, w		
	movwf	FSR
	swapf	intstatussave, w	
	movwf	STATUS
	swapf	intwsave, f			
	swapf	intwsave, w
	retfie

Start:
	movlw	capbuffer			
	movwf	capptr				
	movwf	scanptr
	movwf	FSR
	clrf	INDF				
	movlw	-8					
	movwf	capbit		
	movlw	txbuffer			
	movwf	txinptr				
	movwf	txoutptr
	bsf	STATUS, RP0			
	ERRORLEVEL -302
	movlw	(1<<INTEDG) | (1<<PS2)	
	movwf	OPTION_REG
	movlw	(1<<PWTX) | (1<<3) | (1<<iPodSerialTX)
	movwf	TRISIO			
	clrwdt	
	call	3FFh			
	movwf	OSCCAL	
	ERRORLEVEL +302
	bcf	STATUS, RP0		
	clrf	progflags
	clrf	ACKcount
	clrf	txwaitcount
	movlw	0xBE
	movwf	disc
	movlw	0xFE
	movwf	track
	call	SetStateIdleThenPlay
	movlw 	(1<<INTE) | (1<<GIE)
	movwf	INTCON

SendDisplayPacket:
	bcf	T1CON, TMR1ON 
	movlw	high (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
	movwf	TMR1H
	movlw	low (0xFFFF - (REFRESH_PERIOD * (1000 / 8)))
	movwf	TMR1L
	bcf	PIR1, TMR1IF	
	movlw	00110001b		
	movwf	T1CON						
	call	SendPacket
	btfsc	STATUS, Z			
	incfsz	scancount, f
	goto	SecondWait
	movlw	SCANWAIT
	movwf	scancount	
	movlw	~(1<<scan)			
	andwf	progflags, f

SecondWait:
	incfsz	secondcount, f
	goto	IdleLoopSkipSend
	movlw	SECONDWAIT
	movwf	secondcount
	
SecondIncrement:
	movf	txwaitcount, f
	btfss	STATUS, Z
	decf	txwaitcount, f
	btfss	progflags, playing
	goto	IdleLoop						
	decf	second, f
	movlw	0x0F				
	andwf	second, w
	addlw	-0x05
	movlw	-6
	btfsc	STATUS, Z			
	addwf	second, f				
	movlw	0xFF	
	subwf	second, w
	btfsc	STATUS, C
	goto	IdleLoopSkipSend
	movlw	0xFF
	movwf	second				

MinuteIncrement:
	decf	minute, f
	movlw	0x0F				
	andwf	minute, w
	addlw	-0x05
	movlw	-6
	btfsc	STATUS, Z			
	addwf	minute, f				
	movlw	0xFF
	subwf	minute, w
	btfsc	STATUS, C
	goto	IdleLoopSkipSend
	movlw	0xFF
	movwf	minute				

IdleLoop:
	btfsc	PIR1, TMR1IF		
	goto	SendDisplayPacket	

IdleLoopSkipSend:
	btfss	progflags, overflow	
	goto	CheckFrameError		
	bcf	progflags, overflow	

CheckFrameError:
	btfss	progflags, dataerr	
	goto	NoDataError			
	bcf	progflags, dataerr	

NoDataError:
	movf	txwaitcount, f
	btfsc	STATUS, Z	
	call	ScanCommandBytes

SendTXStringByte:
	movf	txoutptr, w
	movwf	FSR		
	movf	txwaitcount, f	
	btfss	STATUS, Z
	goto	IdleLoop				
	subwf	txinptr, w		
	btfsc	STATUS, Z		
	goto	IdleLoop			
	call	GetNextStringByte
	btfsc	STATUS, Z			
	goto	SendTXStringByte	
	btfsc	STATUS, DC		
	goto	iPodSend		
	call	SerialLoad					
	btfsc	progflags, capbusy
	goto	IdleLoop			

Send19200:
	call	SerialSend
	incf	INDF, f			
	goto	IdleLoop

iPodSend:
	call	SerialLoad				
	btfsc	progflags, capbusy
	goto	IdleLoop				
	call	iPodSerialSend
	incf	INDF, f				
	incf	INDF, f				
	goto	IdleLoop

ScanCommandBytes:
	movf	scanptr, w		
	movwf	FSR				
	
FirstByteLoop:
	call	GetCaptureByte
	btfsc	STATUS, Z
	return

FirstByteTest:
	movlw	0x53			
	subwf	scanbyte, w
	btfsc	STATUS, Z
	goto	SecondByte
	movf	scanbyte, w
	call	EnqueueHex
	call	SaveScanPointer	
	goto	FirstByteLoop
	
SecondByte:
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movlw	0x2C			
	subwf	scanbyte, w
	btfsc	STATUS, Z
	goto	ThirdByte
	movlw	0x53
	call	EnqueueHex
	goto	FirstByteTest

ThirdByte:
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	movwf	cmdcode			

FourthByte:
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	addwf	cmdcode, w	
	addlw	1
	btfss	STATUS, Z
	goto	DumpFullCommand
	movf	cmdcode, w
	andlw	00000011b
	btfss	STATUS, Z
	goto	DumpFullCommand	
	call	SaveScanPointer
	movlw	-4
	movwf	ACKcount			
	movlw	HIGH CommandVectorTable
	movwf	PCLATH
	bcf		STATUS, C
	rrf		cmdcode, f		
	rrf		cmdcode, w
	rlf		cmdcode, f			
	addlw	low CommandVectorTable
	movwf	PCL				

DumpFullCommand:
	movf	scanptr, w		
	movwf	FSR
	call	GetCaptureByte	
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	EnqueueHex
	call	GetCaptureByte	
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	EnqueueHex
	call	GetCaptureByte
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	EnqueueHex	
	call	GetCaptureByte	
	btfsc	STATUS, Z
	return
	movf	scanbyte, w
	call	EnqueueHex
		
SaveScanPointer:
	movf	FSR, w			
	movwf	scanptr
	
	return

HU_Unknown:	

	return

HU_ChangeCD:
	clrf	ACKcount		
	
	return					

HU_ModeOn:		
	call	EnqueueiPodHeader
	movlw	low iPodMode2Enter
	call	EnqueueString
	btfss	progflags, playing
	call	SetStateInitPlay
	call	iPodPlayCommand
	call	iPodReleaseCommand
	return
				
HU_LoadCD:		
	btfsc	progflags, playing
	call	SetStateInitPlay 
	
	return

HU_ModeOff:		
	btfsc	progflags, playing
	call	SetStateIdle	
	movlw	0xBF - 1
	movwf	disc	
	movlw	0xFF - 1
	movwf	track		
	call	iPodPlayCommand
	movlw	low Wait3Seconds
	call	EnqueueString
	call	iPodReleaseCommand

	return

HU_Rewind:
	call	iPodPrevTrack

	return

HU_PreviousDisc:
	return

HU_FastFoward:
	call	iPodNextTrack

	return

HU_Mix:		
	call	EnqueueiPodHeader
	movlw	low iPodMode4Enter
	call	EnqueueString
	call	iPodPlayCommand
	call	iPodReleaseCommand

	return

HU_Scan:
	call	iPodPlayCommand
	call	iPodReleaseCommand

	return
		
HU_NextTrack:
	btfsc	progflags, playing 
	call	SetStateTrackLeadIn
	call	iPodNextTrack
	call	iPodReleaseCommand

	return

HU_PreviousTrack:
	btfsc	progflags, playing 
	call	SetStateTrackLeadIn
	call	iPodPrevTrack
	call	iPodReleaseCommand

	return

HU_CD1:
	call	iPodReleaseCommand
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack1
	call	EnqueueString

	return

HU_CD2:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack41
	call	EnqueueString

	return

HU_CD3:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack81
	call	EnqueueString

	return

HU_CD4:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack121
	call	EnqueueString

	return

HU_CD5:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodVolumeUp
	call	EnqueueString
	call	iPodReleaseCommand
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack161
	call	EnqueueString

	return

HU_CD6:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodVolumeDown
	call	EnqueueString
	call	iPodReleaseCommand
	call	EnqueueiPodHeader
	call	EnqueueiPodMode4
	movlw	low iPodTrack201
	call	EnqueueString

	return

iPodPlayCommand:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodPlay
	call	EnqueueString

	return

iPodReleaseCommand:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodRelease
	call	EnqueueString

	return

iPodNextTrack:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodNextCommand
	call	EnqueueString

	return

iPodPrevTrack:
	call	EnqueueiPodHeader
	call	EnqueueiPodMode2
	movlw	low iPodPreviousCommand
	call	EnqueueString

	return

GetCaptureByte:
	movf	FSR, w		
	subwf	capptr, w
	btfsc	STATUS, Z
	
	return
	
	movf	INDF, w			
	movwf	scanbyte
	incf	FSR, 1
	movlw	capbufferend	
	subwf	FSR, w		
	btfss	STATUS, Z
	
	return

	movlw	capbuffer	
	movwf	FSR		
	bcf	STATUS, Z
	
	return		

SetStateIdle:
	bcf	progflags, playing
	movlw	low StateIdle
	movwf	BIDIstate
	return

SetStateIdleThenPlay:
	bcf	progflags, playing
	movlw	low StateIdleThenPlay
	movwf	BIDIstate
	movlw	-20
	movwf	BIDIcount
	
	return

SetStatePlay:
	bsf	progflags, playing
	movlw	low StatePlay
	movwf	BIDIstate
	
	return		

SetStateInitPlay:
	bsf	progflags, playing
	movlw	low StateInitPlay
	movwf	BIDIstate
	movlw	0x2E
	movwf	discload	
	movlw	-24
	movwf	BIDIcount
	
	return

SetStatePlayLeadIn:
	bsf	progflags, playing
	movlw	low StatePlayLeadIn
	movwf	BIDIstate
	movlw	-10
	movwf	BIDIcount
	
	return

SetStateTrackLeadIn:
	bsf	progflags, playing
	movlw	low StateTrackLeadIn
	movwf	BIDIstate
	movlw	-12
	movwf	BIDIcount
	
	return					

SendPacket:
	movlw	HIGH StateVectors
	movwf	PCLATH
	movf	BIDIstate, w
	movwf	PCL			
		
SendDisplayBytes:
	movf	disc, w		
	call	SendByte

SendDisplayBytesNoCD:	
	movf	track, w
	call	SendByte
	movf	minute, w	
	call	SendByte
	movf	second, w
	call	SendByte
	movlw	0xFB		
	btfss	progflags, mix
	iorlw	0x0F		
	btfsc	progflags, scan
	andlw	0x2F		
	goto	SendByte

SendDisplayBytesInitCD:	
	movlw	0xFF - 0x99		
	call	SendByte
	movlw	0xFF - 0x99		
	call	SendByte
	movlw	0xFF - 0x59		
	call	SendByte
	movlw	0xB7										
	goto	SendByte
		
SendFrameByte:
	movf	ACKcount, f
	btfsc	STATUS, Z
	goto	SendByte
	andlw	11011111b	
	incf	ACKcount, f

SendByte:
	call	SerialLoad
	incf	sendbitcount, f	
	movf	HPIO, w

BitLoop:
	iorlw	(1<<SCLK)	
	movwf	HPIO
	andlw   ~(1<<SRX)		
	rlf	sendreg, 1	
	btfsc	STATUS, C
	iorlw	(1<<SRX)
	movwf	HPIO
	andlw	~(1<<SCLK)	
	movwf	HPIO
	call	Wait15			
	call	Wait15
	incfsz	sendbitcount, f	
	goto	BitLoop
	movlw	-175		
	
DelayLoop:				
	addlw	1			
	btfss	STATUS, Z		
	goto	DelayLoop		

	return

SerialLoad:
	movwf	sendreg
	movlw	-9					
	movwf	sendbitcount
	
	return

SerialSend:
	bcf	INTCON, GIE	
	movf	SPIO, w			

iPodSerialSend:
	bcf	SPIO, iPodSerialTX
	bcf	INTCON, GIE	

iPodLowBit:
	bsf	STATUS, RP0		
	ERRORLEVEL -302
	bcf	STRISIO, iPodSerialTX 
	ERRORLEVEL +302
	bcf	STATUS, RP0		
	call	Wait21
	call	Wait21

iPodBitCount:
	incf	sendbitcount, f
	btfsc	STATUS, Z		
	goto    iPodStopBit		
	rrf	sendreg, 1		
	btfss	STATUS, C      
	goto	iPodLowBit     
	bsf	STATUS, RP0		
	ERRORLEVEL -302
	bsf	STRISIO, iPodSerialTX
	ERRORLEVEL +302
	bcf	STATUS, RP0	
	call	Wait20
	call	Wait21
	goto    iPodBitCount    

iPodStopBit:
	goto    $+1				
	bsf	STATUS, RP0		
	ERRORLEVEL -302
	bsf	STRISIO, iPodSerialTX
	ERRORLEVEL +302
	bcf	STATUS, RP0		
	bsf	INTCON, GIE		
	call	Wait21
	call	Wait22
	
	return					

EndString:
	incf	txoutptr, f		
	movlw	txbufferend		
	subwf	txoutptr, w		
	movlw	txbuffer		
	btfsc	STATUS, Z
	movwf	txoutptr		
	bsf	STATUS, Z		
	
	return

EnqueueiPodHeader:		
	movlw	low iPodHeader
	goto	EnqueueString

EnqueueiPodMode2:		
	movlw	low iPodMode2
	goto	EnqueueString

EnqueueiPodMode4:		
	movlw	low iPodMode4
	goto	EnqueueString
	
EnqueueString:
	movwf	sendreg				
	movf	FSR, w				
	movwf	sendbitcount	
	movf	txinptr, w			
	movwf	FSR
	movf	sendreg, w
	movwf	INDF				
	incf	txinptr, f			
	movlw	txbufferend			
	subwf	txinptr, w
	movlw	txbuffer
	btfsc	STATUS, Z
	movwf	txinptr					
	movf	sendbitcount, w		
	movwf	FSR
	bsf	STATUS, Z
	
	return

EnqueueHex:
	movwf	cmdcode
	swapf	cmdcode, w		
	andlw	0x0F
	movwf	sendbitcount
	addwf	sendbitcount, w
	addlw	low s0
	call	EnqueueString
	rlf	cmdcode, f	
	movf	cmdcode, w	
	andlw	(0x0F << 1)		
	addlw	low s0
	goto	EnqueueString

GetNextStringByte:
	movlw	high SerialDataStrings
	movwf	PCLATH
	movf	INDF, w
	bcf	STATUS, Z		
	bcf	STATUS, DC	
	movwf	PCL

StateVectors:	
StateIdle:		
	movlw	0x74
	call	SendFrameByte
	call	SendDisplayBytes
	movlw	0x8F		
	call	SendByte
	movlw	0x7C
	goto	SendFrameByte

StateIdleThenPlay:		
	incfsz	BIDIcount, f
	goto	StateIdle
	call	SetStateInitPlay
	goto	StateIdle

StateInitPlay:
	movlw	0x34
	call	SendFrameByte
	btfss	BIDIcount, 0
	goto	StateInitPlayAnnounceCD
	call	SendDisplayBytes
	movlw	0xEF
	call	SendByte

StateInitPlayEnd:				
	movlw	0x3C
	call	SendFrameByte		
	incfsz	BIDIcount, f
	
	return

	goto	SetStatePlayLeadIn
		
StateInitPlayAnnounceCD:		
	movf	discload, w
	call	SendByte
	movlw	0x29
	subwf	discload, w		
	movlw	0x2E			
	btfss	STATUS, Z
	decf	discload, w		
	movwf	discload	
	call	SendDisplayBytesInitCD
	movlw	0xFF
	call	SendByte
	goto	StateInitPlayEnd
		
StatePlayLeadIn:
	movlw	0x34
	call	SendFrameByte
	btfss	BIDIcount, 0
	goto	StatePlayLeadInAnnounceCD
	call	SendDisplayBytes
	movlw	0xAE
	call	SendByte
		
StatePlayLeadInEnd:
	movlw	0x3C
	call	SendFrameByte	
	incfsz	BIDIcount, f
	
	return

	goto	SetStatePlay
		
StatePlayLeadInAnnounceCD
	movf	disc, w
	andlw	0x0F
	iorlw	0x20
	call	SendByte
	call	SendDisplayBytesInitCD
	movlw	0xFF
	call	SendByte
	goto	StatePlayLeadInEnd
		
StateTrackLeadIn:
	movlw	0x34
	call	SendFrameByte
	call	SendDisplayBytes
	movlw	0xAE
	call	SendByte
	movlw	0x3C
	call	SendFrameByte	
	incfsz	BIDIcount, f
	
	return

	goto	SetStatePlay

StatePlay:
	movlw	0x34
	call	SendFrameByte
	call	SendDisplayBytes
	movlw	0xCF
	call	SendByte
	movlw	0x3C
	goto	SendFrameByte
	
	ORG 	0x300

SerialDataStrings:
s0:	
	dt	'0'
	goto	EndString
		
Wait3Seconds:
	movlw	3
	movwf	txwaitcount
	goto	EndString

Wait1Second:
	movlw	1
	movwf	txwaitcount
	goto	EndString
		
iPodHeader:
	bsf	STATUS, DC
	retlw	0xFF
	bsf	STATUS, DC
	retlw	0x55
	goto	EndString

iPodMode2:
	bsf	STATUS, DC
	retlw	0x03
	bsf	STATUS, DC
	retlw	0x02
	bsf	STATUS, DC
	retlw	0x00
	goto	EndString

iPodMode4:
	bsf	STATUS, DC
	retlw	0x07
	bsf	STATUS, DC
	retlw	0x04
	bsf	STATUS, DC
	retlw	0x00
	goto	EndString

iPodMode2Enter:
	bsf	STATUS, DC
	retlw	0x03
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x01
	bsf	STATUS, DC
	retlw	0x02
	bsf	STATUS, DC
	retlw	0xFA
	goto	EndString

iPodMode4Enter:
	bsf	STATUS, DC
	retlw	0x03
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x01
	bsf	STATUS, DC
	retlw	0x04
	bsf	STATUS, DC
	retlw	0xF8
	goto	EndString

iPodTrack1:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0xCD
	goto	EndString

iPodTrack41:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x29
	bsf	STATUS, DC
	retlw	0xA4
	goto	EndString

iPodTrack81:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x51
	bsf	STATUS, DC
	retlw	0x7C
	goto	EndString

iPodTrack121:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x78
	bsf	STATUS, DC
	retlw	0x55
	goto	EndString

iPodTrack161:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0xA0
	bsf	STATUS, DC
	retlw	0x2D
	goto	EndString


iPodTrack201:
	bsf	STATUS, DC
	retlw	0x28
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0xC8
	bsf	STATUS, DC
	retlw	0x05
	goto	EndString
	
iPodNextCommand:
	bsf	STATUS, DC
	retlw	0x08
	bsf	STATUS, DC
	retlw	0xF3
	goto	EndString
		
iPodPreviousCommand:
	bsf	STATUS, DC
	retlw	0x10
	bsf	STATUS, DC
	retlw	0xEB
	goto	EndString

iPodPlay:
	bsf	STATUS, DC
	retlw	0x01
	bsf	STATUS, DC
	retlw	0xFA
	goto	EndString

iPodVolumeUp:
	bsf	STATUS, DC
	retlw	0x02
	bsf	STATUS, DC
	retlw	0xF9
	goto	EndString

iPodVolumeDown:
	bsf	STATUS, DC
	retlw	0x04
	bsf	STATUS, DC
	retlw	0xF7
	goto	EndString

iPodRelease:		
	bsf	STATUS, DC
	retlw	0x00
	bsf	STATUS, DC
	retlw	0xFB
	goto	EndString
						
	CRCMOD					

Wait24:	goto    $+1				
Wait22:	goto    $+1			
Wait20:	goto    $+1				
Wait18:	goto    $+1				
Wait16:	goto    $+1				
Wait14:	goto    $+1			
Wait12:	goto    $+1			
Wait10:	goto    $+1			
Wait8:	goto    $+1			
Wait6:	goto    $+1			

	return			

Wait23:	
	nop
	goto	Wait20

Wait21:
	nop
	goto	Wait18

Wait15:	
	nop
	goto	Wait12

	ORG	0x3FF - 64

CommandVectorTable:		
CMD00:	goto	HU_Unknown
CMD04:	goto	HU_Unknown
CMD08:	goto	HU_Unknown
CMD0C:	goto	HU_CD1	
CMD10:	goto	HU_ModeOff	
CMD14:  goto  	HU_ChangeCD	
CMD18:	goto	HU_PreviousDisc	
CMD1C:	goto	HU_Unknown
CMD20:	goto	HU_Unknown
CMD24:	goto	HU_Unknown
CMD28:	goto	HU_Unknown
CMD2C:	goto	HU_CD5		
CMD30:	goto	HU_Unknown
CMD34:	goto	HU_Unknown
CMD38:	goto	HU_LoadCD	 
CMD3C:	goto	HU_Unknown
CMD40:	goto	HU_Unknown
CMD44:	goto	HU_Unknown
CMD48:	goto	HU_Unknown
CMD4C:	goto	HU_CD3		
CMD50:	goto	HU_Unknown
CMD54:	goto	HU_Unknown
CMD58:	goto	HU_Rewind	
CMD5C:	goto	HU_Unknown
CMD60:	goto	HU_Mix			
CMD64:	goto	HU_Unknown
CMD68:	goto	HU_NextTrack			
CMD6C:	goto	HU_Unknown
CMD70:	goto	HU_Unknown
CMD74:	goto	HU_Unknown
CMD78:	goto	HU_PreviousTrack		
CMD7C:	goto	HU_Unknown
CMD80:	goto	HU_Unknown
CMD84:	goto	HU_Unknown
CMD88:	goto	HU_Unknown
CMD8C:	goto	HU_CD2		
CMD90:	goto	HU_Unknown
CMD94:	goto	HU_Unknown
CMD98:	goto	HU_Unknown
CMD9C:	goto	HU_Unknown
CMDA0:	goto	HU_Scan			
CMDA4:	goto	HU_Unknown	
CMDA8:	goto	HU_PreviousTrack			
CMDAC:	goto	HU_CD6		
CMDB0:	goto	HU_Unknown
CMDB4:	goto	HU_Unknown
CMDB8:	goto	HU_Unknown
CMDBC:	goto	HU_Unknown
CMDC0:	goto	HU_Unknown
CMDC4:	goto	HU_Unknown
CMDC8:	goto	HU_Unknown
CMDCC:	goto	HU_CD4		
CMDD0:	goto	HU_Unknown
CMDD4:	goto	HU_Unknown
CMDD8:	goto	HU_FastFoward	
CMDDC:	goto	HU_Unknown
CMDE0:	goto	HU_Mix			
CMDE4:	goto	HU_ModeOn	
CMDE8:	goto	HU_Unknown
CMDEC:	goto	HU_Unknown
CMDF0:	goto	HU_Unknown
CMDF4:	goto	HU_Unknown
CMDF8:	goto	HU_NextTrack			
CMDFC:	goto	HU_Unknown
		
	ORG 2100h

	de	"iPod-VW Head Unit Control"

	END
