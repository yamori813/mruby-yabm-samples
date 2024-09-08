#
# rtlbm-mruby mruby script
# GPIO input check script for RTL8196E

begin
  yabm = YABM.new

  # JTAG and all LED is GPIO
  yabm.gpiosetsel(0x06, 0x1ffffff, 0x36db, 0x3fff)

  # all pin is gpio
  reg = 0
  yabm.gpiosetctl(reg)

  # all pin is in
  reg = 0
  yabm.gpiosetdir(reg)

  yabm.print "GPIO input check\n"

  loop do
    val = yabm.gpiogetdat
    yabm.print "#{val}\n"
    yabm.msleep(2_000)
  end
rescue StandardError => e
  yabm.print e.to_s
end
