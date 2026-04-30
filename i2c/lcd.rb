#
# mruby on YABM script
#
# This is demonstration of I2C LCD
# need compile with subroutine file
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

begin
  yabm = YABM.new

  gpioinit(yabm)

  yabm.i2cinit(SCL, SDA, 1)

  lcd = I2CLCD.new yabm

  lcd.clear

  str1 = 'mruby on'
  str2 = 'YABM'

  i = 0
  loop do
    yabm.print '.'
    yabm.msleep(500)
    if i < str1.length
      lcd.print str1[i]
    else
      lcd.print str2[i - 8]
    end
    i += 1
    lcd.next if i == str1.length
    next unless i == str1.length + str2.length

    yabm.msleep(1_000)
    5.times do
      ledon yabm
      yabm.msleep(200)
      ledoff yabm
      yabm.msleep(200)
    end
    yabm.msleep(3_000)
    lcd.clear
    i = 0
  end
rescue StandardError => e
  yabm.print e.to_s
end
