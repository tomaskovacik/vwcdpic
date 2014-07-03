files form vwcdpic project
==========================

notes:
-----------
pinout:

|  | v2 | V3 |
|----|----|----|
|+5v|1|1|
|GND|8|8|
| CLK: | 2 | 7 |
| DataIn: | 3 | 6 |
| DataOut: | 5 | 6 |
| serial 9600: | 7 | 2 |

compile:

http://www.micahcarrick.com/pic-programming-linux.html

for i in `ls *.asm|cut -d\. -f2`;do gpasm vwcdpic-2.$i.asm;done

