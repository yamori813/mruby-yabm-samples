#
# morus code generator on WR8165N
#

# WR8165N, WR8166N
# GPIOA6 GREEN LED 0x0040
# GPIOB5 RED LED   0x2000
# GPIOA2 Slide SW  0x0004
# GPIOA5 Push SW   0x0020
# GPIOA4 ?         0x0010
# GPIOB2 D20       0x0400
# GPIOB3 D22       0x0800
# GPIOB4 D21       0x1000
# GPIOB6 D23       0x4000

GLED = 0x0040
RLED = 0x2000
SSW = 0x0004
PSW = 0x0020

# Use GPIOB2 and GPIOB3

SCL = 10
SDA = 11

def gpioinit(yabm) 

# JTAG(GPIOA2,4,5,6) and LED_PORT3(GPIOB5) is GPIO
  yabm.gpiosetsel(0x06, 0x1ffffff, 0x36db, 0x3fff)

  yabm.gpiosetctl(~(GLED | RLED | SSW | PSW))
  yabm.gpiosetdir(GLED | RLED)

  reg = yabm.gpiogetdat()
  yabm.gpiosetdat(reg & ~(RLED | GLED))
end

def ledon yabm
  reg = yabm.gpiogetdat()
  yabm.gpiosetdat(reg | RLED)
end

def ledoff yabm
  reg = yabm.gpiogetdat()
  yabm.gpiosetdat(reg & ~RLED)
end
