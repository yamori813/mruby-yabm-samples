#
# mruby on YABM script
# AQM0802 support code
#

class I2CLCD
  # i2c lcd address
  LCDADDR = 0x3e

  def initialize(yabm)
    @y = yabm
    @y.i2cwrite(LCDADDR, [0x38, 0x39, 0x14, 0x70, 0x56, 0x6c])
    @y.msleep(200)
    @y.i2cwrite(LCDADDR, [0x38, 0x0d, 0x01])
    @y.msleep(10)
  end

  def clear
    @y.i2cwrite(LCDADDR, [0x00, 0x01])
    @y.msleep(100)
  end

  def next
    @y.i2cwrite(LCDADDR, [0x00, 0xc0])
    @y.msleep(100)
  end

  def print(str)
    lcdcmd = [0x40]
    arr = str.chars
    arr.each do |ch|
      lcdcmd.push(ch.ord)
    end
    @y.print lcdcmd.to_s
    @y.i2cwrite(LCDADDR, lcdcmd)
  end
end
