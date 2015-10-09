files form vwcdpic project
==========================

hex: hex files from original vwcdpic site
old: old files 
hw: complet kicad project for smd and tht version of emulator
vwcdpic-2.8pre3.asm - latest asm

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
2.8pre3
- better works with audi concert1/chorus1 head unit made by blaupunkt (previous,next CD works)
- switching from CDC to radio back to CDC works
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



