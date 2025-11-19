#
# mruby on YABM script
#
# HTU21D sample code on HomeSpotCube
# need sub_hsc.rb i2c/ens160_c.rb i2c/aht21_c.rb i2c/htu21d_c.rb
#

# GPIO I2C Pin (SW12)

SCL = 2
SDA = 11

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

# main

begin
  yabm = YABM.new

  yabm.netstartdhcp

  gpioinit yabm

  yabm.i2cinit(SCL, SDA, 10)

  h = HTU21D.new yabm
  t = AHT21.new yabm
  e = ENS160.new yabm

  h.reset

  loop do
    hstr = pointstr(h.getCelsiusHundredths, 2)
    yabm.print "HTU21:#{hstr}, "
    arr = t.sensorRead
    tstr = arr[0].to_s
    yabm.print "AHT21:#{tstr}, "
    e.setTempRh arr[0], arr[1]

    arr = e.getData
    astr = arr[0].to_s
    yabm.print "ENS160:#{astr}, "
    astr = arr[1].to_s
    yabm.print "#{astr}, "
    astr = arr[2].to_s
    yabm.print "#{astr}\r\n"
    yabm.msleep 60_000
  end

rescue StandardError => e
  yabm.print e.to_s
end
