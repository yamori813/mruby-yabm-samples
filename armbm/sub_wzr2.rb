# WZR2-G300N GPIO

# D39(POWER) is direct connect to VCC
D44 = (1 << 4)		# SECURITY
D40 = (1 << 5)		# ROUTER
D45 = (1 << 0)		# DIAG

def gpioinit(yabm)
  leds = D44 | D40 | D45
  yabm.gpiosetdat(leds)
end

def ledon(yabm)
  leds = D44 | D40
  yabm.gpiosetdat(leds)
end

def ledoff(yabm)
  leds = D44 | D40 | D45
  yabm.gpiosetdat(leds)
end
