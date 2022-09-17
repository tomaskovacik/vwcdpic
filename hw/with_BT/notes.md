
1) - TEST OK
connect 12V to 12Vin
connect 12V to CDC_ENA_12V 
 check if 12V is present (switch Q2,Q1 works)

2)
connect jumper JP4

3) connect JP2 (R28, C34,C35 must be populated)

check if 3V6 is 3.6V, if not set using R19, R13)

program pic
connect to radio
check 3V6 voltage ripple while CDC is operational (??? or we can ignore this and listen to BT audio quality)

solder BT module, check if it connects, if so program it (disable STONES, set name etc...)

solder R4 -> enable communication PIC->BT

check audio ripple and mic bias (2V) whily BT in call

check overall audio quality

if noise from CDC is pressent, try JP1 or JP3


