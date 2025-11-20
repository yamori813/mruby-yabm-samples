#
# rtlbm-mruby mruby script
#
# This is demonstration for BH1750
# Used BBR-4MG V2
# use i2c/bh1750_c.rb

# i2c pin

# TRST# (1) has internal pull-up resistor
I2CSCK = 3
# TDI (3) has internal pull-up resistor
I2CSDA = 5

def pointstr(p, c)
  if p == 0
    '0.' + ('0' * c)
  elsif p.abs < 10**c
    l = c - p.abs.to_s.length + 1
    s = p.to_s.insert(p < 0 ? 1 : 0, '0' * l)
    s.insert(-1 - c, '.')
  else
    p.to_s.insert(-1 - c, '.')
  end
end

begin
  yabm = YABM.new

  # use gpio pin
  yabm.gpiosetsel(0x300000, 0x300000, 0, 0)

  gpio = yabm.gpiogetdat
  yabm.gpiosetdat(gpio | (1 << 16) | 0x7c00)

  yabm.i2cinit(I2CSCK, I2CSDA, 1)

  bh = BH1750.new(yabm, BHADDR)

  interval = 20

  count = 0

  bh.setMTreg(254)
  bh.setMeasurement(BH1750::ONE_TIME_HIGH_RES_MODE_2)

  loop do
    lx = bh.getLightLevel
    yabm.print count.to_s + ' '
    yabm.print pointstr(lx, 2) + "\r\n"
    yabm.msleep(1000 * interval)
    count += 1
  end
rescue StandardError => e
  yabm.print e.to_s
end
