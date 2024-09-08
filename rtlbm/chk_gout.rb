#
# rtlbm-mruby mruby script
# GPIO output check script for RTL8196E

begin

yabm = YABM.new

yabm.print "GPIO out check\n"

# JTAG and all LED is GPIO
yabm.gpiosetsel(0x06, 0x1ffffff, 0x36db, 0x3fff)

# all pin is gpio
reg = 0
yabm.gpiosetctl(reg)

#all pin is out
reg = 0xffff
yabm.gpiosetdir(reg)


i = 0
loop do
  yabm.print i.to_s + "\n"
  if i < 16 
    reg = 1 << i
  else
    reg = ~(1 << (i - 16))
  end
  yabm.gpiosetdat(reg)
  yabm.msleep(2_000)
  i = i + 1
  if i == 32
    i = 0
  end
end

rescue => e
  yabm.print e.to_s
end

