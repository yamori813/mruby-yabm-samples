#
# rtlbm-mruby mruby script
#
# This is demonstration of I2C LCD
#

# i2c pin

I2CSCK = 3
I2CSDA = 5

# i2c lcd address

LCDADDR = 0x3e
MSPADDR = 0x48

class I2CLCD
  def initialize yabm
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

  def print str
    lcdcmd = [0x40]
    arr = str.split("")
    for ch in arr do
      lcdcmd.push(ch.ord)
    end
    @y.print lcdcmd.to_s
    @y.i2cwrite(LCDADDR, lcdcmd)
  end
end

begin

yabm = YABM.new

# use gpio pin
yabm.gpiosetsel(0x300000, 0x300000, 0, 0)

gpio = yabm.gpiogetdat
yabm.gpiosetdat(gpio | (1 << 16) | 0x7c00)

yabm.i2cinit(I2CSCK, I2CSDA, 1)

lcd = I2CLCD.new yabm

lcd.clear

str1 = "mruby on"
str2 = "YABM"

last = 0
loop do
  cur = yabm.i2cread(MSPADDR, 1, 2)
  if cur != 0 && cur != last
    yabm.print cur.to_s
#    lcd.print cur
  end
  last = cur
end

rescue => e
  yabm.print e.to_s
end
