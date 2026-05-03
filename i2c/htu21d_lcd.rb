#
# mruby on YABM script
#
# HTU21D sample code 
# need compile with module subroutine file
# need i2c/htu21d_c.rb i2c/lcd_c.rb
#

def pointstr(p, c)
  if p == 0
    "0.#{'0' * c}"
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

  gpioinit(yabm)

  yabm.i2cinit(SCL, SDA, 2)

  h = HTU21D.new yabm

  lcd = I2CLCD.new yabm

  lcd.clear

  h.reset

  lcd.setcgram

  #  lcd.print "SN: #{h.htu21_read_serial_number}"
  #  yabm.msleep 5_000

  loop do
    ledon yabm
    lcd.home
    yabm.msleep 5
    temp = h.getCelsiusHundredths
    str = pointstr(temp, 2) + "C"
    yabm.print "#{str},"
    i = 0
    lcd.print ' ' # ???
    rstr = str.rjust(8, ' ')
    while i < rstr.length
      lcd.print rstr[i]
      i += 1
    end
    rh = h.getHumidityPercent
    str = rh.to_s + "%"
    yabm.print "#{str} "
    lcd.print ' ' # ???
    yabm.msleep 5
    lcd.next
    yabm.msleep 5
    i = 0
    rstr = str.rjust(8, ' ')
    while i < rstr.length
      lcd.print rstr[i]
      i += 1
    end
    ledoff yabm
    for num in 0..4 do
      lcd.home
      yabm.msleep 5
      lcd.next
      yabm.msleep 5
      lcd.bou num
      yabm.msleep 4_000
    end

  end
rescue StandardError => e
  yabm.print e.to_s
end
