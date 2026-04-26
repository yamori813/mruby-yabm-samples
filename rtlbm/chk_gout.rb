#
# rtlbm-mruby mruby script
# GPIO output check script for RTL8196E

begin
  yabm = YABM.new

  yabm.print "GPIO out check\r\n"

  # JTAG and all LED is GPIO
  yabm.gpiosetsel(0x06, 0x1ffffff, 0x36db, 0x3fff)

  # all pin is gpio
  reg = 0
  yabm.gpiosetctl(reg)

  # all pin is out
  reg = 0xffff
  yabm.gpiosetdir(reg)

  # only GPIOA and GPIOB
  i = 0
  loop do
    yabm.print "#{i}\r\n"
    2.times do
      reg = 1 << i
      yabm.gpiosetdat(reg)
      yabm.msleep(2_000)
      reg = 0
      yabm.gpiosetdat(reg)
      yabm.msleep(2_000)
    end
    i += 1
    i = 0 if i == 16
  end
rescue StandardError => e
  yabm.print e.to_s
end
