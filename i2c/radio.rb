#
# rtlbm-mruby mruby script
#
# Not wrok
#

# GPIO I2C Pin (SW12)

SCL = 2
SDA = 11

begin
  yabm = YABM.new

  gpioinit(yabm)

  yabm.i2cinit(SCL, SDA, 1)

  id = yabm.i2cread(0x11, 1, 0)
  yabm.print id.to_s

  loop do
    yabm.msleep(3_000)
  end
rescue StandardError => e
  yabm.print e.to_s
end
