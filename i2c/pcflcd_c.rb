#
# mruby on YABM script
# LCD with PCF8574 support code
#

class I2CPCFLCD
  # i2c lcd address
  LCDADDR = 0x24

  def cmdwrite(c)
    h = [(c & 0xf0) | 0x08] * 3
    h[1] |= 0x04
    @y.i2cwrite(LCDADDR, h)
    l = [((c << 4) & 0xf0)| 0x08] * 3
    l[1] |= 0x04
    @y.i2cwrite(LCDADDR, l)
  end

  def datwrite(c)
    h = [(c & 0xf0) | 0x09] * 3
    h[1] |= 0x04
    @y.i2cwrite(LCDADDR, h)
    l = [((c << 4) & 0xf0)| 0x09] * 3
    l[1] |= 0x04
    @y.i2cwrite(LCDADDR, l)
  end

  def initialize(yabm)
    @y = yabm
    @y.write(LCDADDR, [0x30, 0x34, 0x30])
    @y.write(LCDADDR, [0x30, 0x34, 0x30])
    @y.write(LCDADDR, [0x30, 0x34, 0x30])

    @y.write(LCDADDR, [0x20, 0x24, 0x20])

    @y.write(LCDADDR, [0x20, 0x24, 0x20])
    @y.write(LCDADDR, [0x80, 0x84, 0x80])

    @y.write(LCDADDR, [0x00, 0x04, 0x00])
    @y.write(LCDADDR, [0xf0, 0xf4, 0xf0])

    @y.write(LCDADDR, [0x00, 0x04, 0x00])
    @y.write(LCDADDR, [0x10, 0x14, 0x10])

    @y.write(LCDADDR, [0x00, 0x04, 0x00])
    @y.write(LCDADDR, [0x60, 0x64, 0x60])

    @y.write(LCDADDR, [0x00, 0x04, 0x00])
    @y.write(LCDADDR, [0x28, 0x2c, 0x28])

    @y.msleep(10)
  end

  def clear
    datwrite(0x01)
    @y.msleep(100)
  end

  def home
    datwrite(0x02)
    @y.msleep(100)
  end

  def next
    datwrite(0xc0)
    @y.msleep(100)
  end

  def putc(c)
    datwrite(c)
  end

  def print(str)
    arr = str.chars
    arr.each do |ch|
      putc(ch.ord)
    end
  end
end
