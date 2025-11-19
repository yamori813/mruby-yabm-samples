#
# mruby on YABM script
# for BMP180
# need compile with subroutine file
# use i2c/bmp180_c.rb
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

begin

  yabm = YABM.new

  gpioinit(yabm)

  yabm.i2cinit(SCL, SDA, 1)

  b = BMP180.new yabm, BMP180::OSS_STANDARD

  loop do

    reg = yabm.gpiogetdat()
    reg = reg & ~TOP_LED3
    yabm.gpiosetdat(reg)

    t = b.readTemperature
    tstr = pointstr(t, 1)
    yabm.print tstr + " "

    p = b.readPressure
    pstr = pointstr(p, 2)
    yabm.print pstr + "\r\n "

    yabm.msleep(10_000)

  end

rescue => e
  yabm.print e.to_s
end
