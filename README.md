VWCDPIC Audio Interface Adapter
==========================

This is my personal "resurrection" of VWCDPIC project with:

- custom fixies/patches (take look down to notes about fixies)
- PCB (smd and tht version - HW folder)
- all files from internet relative to wvcdpic, just for archive (old folder)

spare boards from dirtyPCB are avalaible for sale:

<a href="https://www.tindie.com/stores/tomaskovacik/?ref=offsite_badges&utm_source=sellers_tomaskovacik&utm_medium=badges&utm_campaign=badge_medium"><img src="https://d2ss6ovg47m0r5.cloudfront.net/badges/tindie-mediums.png" alt="I sell on Tindie" width="150" height="78"></a>

From original vwcdpic site:

*Allows you to use most audio devices (such as MP3 players) with your stock head unit in 1998+ Volkswagen automobiles.*

*The Volkswagen 1998 and later automobiles are equipped with a trunk mounted CD Changer interface. This is great for hooking up an extra audio device to your car's sound system because it is pre-wired for you. However, Volkswagen's OEM head unit locks this interface from being used by anything but a Volkswagen CD Changer by muting the audio inputs unless there is a valid data stream coming from the CD Changer. Of course, this data stream is not documented by Volkswagen.*

*The VWCDPIC is a "lock pick," if you will, that unlocks the CD Changer interface by sending the required data stream, fooling the head unit into thinking a real Volkswagen CD Changer is connected. With a VWCDPIC, you'll be able to connect any audio device up to your stock OEM head unit. If you are connecting a PJRC MP3 Player, you'll even be able to remotely control your player from the head unit's buttons up front (after you build a cable described here). *

folders:
-------------------
hex: hex files from original vwcdpic site

old: old files 

hw: complet kicad project for smd and tht version of emulator

pinout:
--------------------
| signal        | PIC pin  |
|---------------|----------|
| +5v           | 1 |
| GND           | 8 |
| CLK:          | 7 |
| DataIn:       | 6 |
| DataOut:      | 5 |
| serial 9600:  | 2 |

compile:
---------

http://www.micahcarrick.com/pic-programming-linux.html

for i in `ls *.asm|cut -d\. -f2`;do gpasm vwcdpic-2.$i.asm;done

notes:
-------
2.8pre3 (latest 
- better works with audi concert1/chorus1 head unit made by blaupunkt (previous,next CD works)
- switching from CDC to radio back to CDC works on concert1/chorus1
- tested with:
	- audi concert 1(blaupunkt)
	- audi concert 1(philips)
	- audi concert 2
	- chorus1(blaupunkt)
	- Symohony I
	- vw blaupunkt RadioNavigationSystem MCD
	- VW Passat Blaupunkt Gamma (similar to Gamma V)
	- Audi Symphony II BOSE
	- for original list of supported radios look to original.html

hex/vwcdpic-3.x-2.7d-RCD300-1-pic12f629.hex is only version works with RCD300 head units! thx to Morten for test.

for more info look in original.html



