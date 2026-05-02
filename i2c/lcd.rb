#
# mruby on YABM script
#
# This is demonstration of I2C LCD
# need compile with module subroutine file
#

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
