#
# yabm mruby script
# BCM4712 subroutine script
#

# GPIO I2C Pin used SW3

SCL = 5
SDA = 3

def gpioinit yabm
  yabm.gpiosetdat((1 << 6) | (1 << 7))
end

def ledon yabm
  dat = yabm.gpiogetdat
  yabm.gpiosetdat(dat & ~(1 << 6))
end

def ledoff yabm
  dat = yabm.gpiogetdat
  yabm.gpiosetdat(dat | (1 << 6))
end
