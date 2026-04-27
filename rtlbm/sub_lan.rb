#
# rtlbm-mruby mruby script
#

# i2c pin

SCL = 3
SDA = 5

RLED = (1 << 4)

def gpioinit(yabm)

# use gpio pin
#  yabm.gpiosetsel(0x300000, 0x300000, 0, 0)

#  gpio = yabm.gpiogetdat
#  yabm.gpiosetdat(gpio | (1 << 16) | 0x7c00)
end

def ledon(yabm)
  reg = yabm.gpiogetdat
  yabm.gpiosetdat(reg & ~RLED)
end

def ledoff(yabm)
  reg = yabm.gpiogetdat
  yabm.gpiosetdat(reg | RLED)
end
