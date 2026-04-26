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

  yabm.print "GPIO input check\r\n"

  last = 0

  last = yabm.gpiogetdat
  loop do
    val = yabm.gpiogetdat
    if last != val
      bit = if last < val
              1
            else
              0
            end
      a = (val - last).abs
      yabm.print "#{a.to_s(16)}:"
      p = -1
      while a != 0
        a >>= 1
        p += 1
      end
      yabm.print "#{p}:#{bit}"
      yabm.print "\r\n"
    end
    last = val
  end
rescue StandardError => e
  yabm.print e.to_s
end
