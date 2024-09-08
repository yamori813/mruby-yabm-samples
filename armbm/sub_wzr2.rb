# WCA-G GPIO

# LED1 is direct connect to VCC
D44 = (1 << 4)
D40 = (1 << 5)
D45 = (1 << 0)

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
