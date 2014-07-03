files form vwcdpic project
==========================

notes:
-----------

+5v: 1
GND: 8

v2:
clock:2
input:3
out:5
serial 9600:7

v3
clock:7
input:6
out:5
serial 9600:2


http://www.micahcarrick.com/pic-programming-linux.html

for i in `ls *.asm|cut -d\. -f2`;do gpasm vwcdpic-2.$i.asm;done

