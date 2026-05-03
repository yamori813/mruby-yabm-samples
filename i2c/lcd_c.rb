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
    @y.i2cwrite(LCDADDR, [0x38, 0x0c, 0x01])
    @y.msleep(10)
  end

  def clear
    @y.i2cwrite(LCDADDR, [0x00, 0x01])
    @y.msleep(100)
  end

  def home
    @y.i2cwrite(LCDADDR, [0x00, 0x02])
    @y.msleep(100)
  end

  def next
    @y.i2cwrite(LCDADDR, [0x00, 0xc0])
    @y.msleep(100)
  end

  def setcgram
    bar = [1, 3, 5, 7]
    @y.i2cwrite(LCDADDR, [0x00, 0x38])
    @y.i2cwrite(LCDADDR, [0x00, 0x40])
    @y.msleep(100)
    for j in 0..3 do
      (7 - bar[j]).times do
        @y.i2cwrite(LCDADDR, [0x40, 0x00])
        @y.msleep(100)
      end
      bar[j].times do
        @y.i2cwrite(LCDADDR, [0x40, 0x1f])
        @y.msleep(100)
      end
      @y.i2cwrite(LCDADDR, [0x40, 0x00])
    end
  end

  def bou(num)
    if num == 0 then
      @y.i2cwrite(LCDADDR, [0x40, 0x20])
    else
      @y.i2cwrite(LCDADDR, [0x40, 0x00 + num - 1])
    end
  end

  def print(str)
    lcdcmd = [0x40]
    arr = str.chars
    arr.each do |ch|
      lcdcmd.push(ch.ord)
    end
#    @y.print lcdcmd.to_s
    @y.i2cwrite(LCDADDR, lcdcmd)
  end
end
