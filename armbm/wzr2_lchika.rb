# WCA-G GPIO

# LED1 is direct connect to VCC
D44 = (1 << 4)
D40 = (1 << 5)
D45 = (1 << 0)

begin
  yabm = YABM.new

  orgdir = yabm.gpiogetdir
  yabm.print "ORG DIR: #{orgdir}\r\n"

  leds = D44 | D40 | D45

  loop do
    leds &= ~D45
    yabm.gpiosetdat(leds)
    yabm.msleep(5000)
    leds |= D45
    yabm.gpiosetdat(leds)
    yabm.msleep(5000)
  end
rescue StandardError => e
  yabm.print e.to_s
end
