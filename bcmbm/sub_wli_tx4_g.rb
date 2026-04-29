#
# yabm mruby script
# WLI-TX4-G subroutine script
#

# LED10			6
# LED2			2
# LED16			3
# LED6(Not Impliment)	1
# LED11			7

SCL = 1
SDA = 7

def gpioinit yabm
  yabm.gpiosetdir((1 << 6) | (1 << 2) | (1 << 3) | (1 << 1) | (1 << 7))
  yabm.gpiosetdat((1 << 6) | (1 << 2) | (1 << 3) | (1 << 1) | (1 << 7))
end

def ledon yabm
  dat = yabm.gpiogetdat
  yabm.gpiosetdat(dat & ~(1 << 6))
end

def ledoff yabm
  dat = yabm.gpiogetdat
  yabm.gpiosetdat(dat | (1 << 6))
end
