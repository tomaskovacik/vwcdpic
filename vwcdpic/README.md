files form vwcdpic project
==========================

notes:
-----------
pinout:
+---------------+---+
| +5v           | 1 |
| GND           | 8 |
| CLK:          | 7 |
| DataIn:       | 6 |
| DataOut:      | 5 |
| serial 9600:  | 2 |
+---------------+---+
compile:

http://www.micahcarrick.com/pic-programming-linux.html

for i in `ls *.asm|cut -d\. -f2`;do gpasm vwcdpic-2.$i.asm;done

2.8pre3 now better works with audi concert1/chorus1 head unit (chorus1,concert1) made by blaupunkt

hex/vwcdpic-3.x-2.7d-RCD300-1-pic12f629.hex is only version works with RCD300 head units! tested thx to Morten for test.


