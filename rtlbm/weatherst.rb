#
# mruby on YABM script
#
# Weather Station used by BMP180 and Si7021 on HomeSpotCube
# need sub_hsc.rb
#

APIKEY = 'naisyo'

# NONET = false
# for debug
NONET = true

MAXFAILE = 10

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

#
# sensor class
#

class SI7021
  SIADDR = 0x40
  USEHOLD = true

  TRIG_T_MEASUREMENT_HM    = 0xE3  # command trig. temp meas. hold master
  TRIG_RH_MEASUREMENT_HM   = 0xE5  # command trig. humidity meas. hold master
  TRIG_T_MEASUREMENT_POLL  = 0xF3  # command trig. temp meas. no hold master
  TRIG_RH_MEASUREMENT_POLL = 0xF5  # command trig. humidity meas. no hold master
  USER_REG_W               = 0xE6  # command writing user register
  USER_REG_R               = 0xE7  # command reading user register
  SOFT_RESET               = 0xFE  # command soft reset

  def initialize(yabm)
    @y = yabm
  end

  def getRevition
    @y.i2cread(SIADDR, 1, [0x84, 0xb8])
  end

  def getSerialStr
    siarr = @y.i2cread(SIADDR, 8, [0xfa, 0x0f])
    siarr += @y.i2cread(SIADDR, 6, [0xfc, 0xc9])
    serial_number = ''
    values = [9, 8, 6, 4, 2, 0, 7, 8]
    values.each do |n|
      serial_number += siarr[n].to_s(16).rjust(2, '0')
    end
    serial_number
  end

  # not use
  #   def chkcrc dat
  #     crc8 = 0xff
  #     for i in 0..1 do
  #       crc8 = crc8 ^ dat[i]
  #       8.times {
  #         if crc8 & 0x80 == 0x80
  #           crc8 = crc8 << 1
  #           crc8 = crc8 ^ 0x31
  #         else
  #           crc8 = crc8 << 1
  #         end
  #       }
  #     end
  #     if (crc8 & 0xff) == dat[2]
  #       return true
  #     else
  #       return false
  #     end
  #   end

  def getCelsiusHundredths
    @y.msleep(1) while @y.i2cchk(SIADDR) == 0
    if USEHOLD
      siarr = @y.i2cread(SIADDR, 3, [TRIG_T_MEASUREMENT_HM])
    else
      @y.i2cwrite(SIADDR, [TRIG_T_MEASUREMENT_POLL])
      c = 0
      loop do
        @y.msleep(10)
        siarr = @y.i2cread(SIADDR, 3)
        break unless siarr.nil?

        c += 1
        if c == 1000
          siarr = [0, 0]
          break
        end
      end
    end
    tempcode = (siarr[0] << 8) | siarr[1]
    ((tempcode * 17_572) / 65_536) - 4685
  end

  def getHumidityPercent
    @y.msleep(1) while @y.i2cchk(SIADDR) == 0
    if USEHOLD
      siarr = @y.i2cread(SIADDR, 3, [TRIG_RH_MEASUREMENT_HM])
    else
      @y.i2cwrite(SIADDR, [TRIG_RH_MEASUREMENT_POLL])
      c = 0
      loop do
        @y.msleep(10)
        siarr = @y.i2cread(SIADDR, 3)
        break unless siarr.nil?

        c += 1
        if c == 1000
          siarr = [0, 0]
          break
        end
      end
    end
    rhcode = (siarr[0] << 8) | siarr[1]
    ((125 * rhcode) / 65_536) - 6
  end
end

class BMP180
  BMPADDR = 0x77
  PRESSURE_WAIT = [5, 8, 14, 26]

  def readup
    msb = @y.i2cread(BMPADDR, 1, 0xf6)
    lsb = @y.i2cread(BMPADDR, 1, 0xf7)
    xlsb = @y.i2cread(BMPADDR, 1, 0xf8)
    ((msb << 16) + (lsb << 8) + xlsb) >> (8 - @oss)
  end

  def readu16(addr)
    (@y.i2cread(BMPADDR, 1, addr) << 8) | @y.i2cread(BMPADDR, 1, addr + 1)
  end

  def read16(addr)
    val = (@y.i2cread(BMPADDR, 1, addr) << 8) | @y.i2cread(BMPADDR, 1, addr + 1)
    val -= 0x10000 if val >= 0x8000
    val
  end

  def initialize(yabm, oss)
    @y = yabm
    @oss = oss
    @ac1 = read16 0xaa
    @ac2 = read16 0xac
    @ac3 = read16 0xae
    @ac4 = readu16 0xb0
    @ac5 = readu16 0xb2
    @ac6 = readu16 0xb4
    @b1 = read16 0xb6
    @b2 = read16 0xb8
    @mb = read16 0xba
    @mc = read16 0xbc
    @md = read16 0xbe
  end

  def readTemperature
    @y.msleep(1) while @y.i2cchk(BMPADDR) == 0
    @y.i2cwrite(BMPADDR, 0xf4, 0x2e)
    @y.msleep(5)
    ut = read16 0xf6
    #    @y.print ut.to_s + " "

    # calculate true temperature

    x1 = ((ut - @ac6) * @ac5) >> 15
    x2 = (@mc << 11) / (x1 + @md)
    @b5 = x1 + x2
    (@b5 + 8) >> 4
  end

  def getChipid
    @y.i2cread(BMPADDR, 1, 0xd0)
  end
  # calculate true pressure

  def readPressure
    @y.i2cwrite(BMPADDR, 0xf4, 0x34 + (@oss << 6))
    @y.msleep(PRESSURE_WAIT[@oss])
    up = readup
    #    @y.print up.to_s + " "

    b6 = @b5 - 4000
    x1 = (@b2 * ((b6 * b6) >> 12)) >> 11
    x2 = (@ac2 * b6) >> 11
    x3 = x1 + x2
    b3 = ((((@ac1 * 4) + x3) << @oss) + 2) >> 2
    x1 = (@ac3 * b6) >> 13
    x2 = (@b1 * ((b6 * b6) >> 12)) >> 16
    x3 = ((x1 + x2) + 2) >> 2
    b4 = (@ac4 * (x3 + 32_768)) >> 15
    b7 = (up - b3) * (50_000 >> @oss)

    # This is only temporally code because of valid non overflow
    p = b7 / (b4 >> 1)

    x1 = (p >> 8) * (p >> 8)
    x1 = (x1 * 3038) >> 16
    x2 = (-7357 * p) >> 16
    p + ((x1 + x2 + 3791) >> 4)
  end
end

#
# main
#

begin
  yabm = YABM.new

  unless NONET

    yabm.netstartdhcp

    yabm.msleep 2_000
    yabm.print "IP address : #{yabm.getaddress}\r\n"

    ntpaddr = yabm.lookup('ntp.nict.jp')
    yabm.sntp(ntpaddr)
  end

  gpioinit(yabm)

  yabm.i2cinit(SCL, SDA, 1)

  lastbt = 0
  lastbp = 0
  lastst = 0
  lastsh = 0

  # Si7021 Firmware Revision
  si = SI7021.new(yabm)
  rev = si.getRevition
  ser = si.getSerialStr
  yabm.print "Si SN: #{ser} REV: #{rev}\r\n"

  # 0 ultra low power, 1 standard, 2 high resolution, 3 ultra high resolution
  bmp = BMP180.new(yabm, 3)
  id = bmp.getChipid
  yabm.print "BMP180 ID: #{id}\r\n"

  # indecate start by led
  reg = yabm.gpiogetdat
  reg &= ~STATUS_LED2
  yabm.gpiosetdat(reg)

  count = 0
  neterr = 0

  yabm.watchdogstart(256)

  loop do
    reg = yabm.gpiogetdat
    reg &= ~TOP_LED3
    yabm.gpiosetdat(reg)

    error = 0

    yabm.print "#{count} "

    # BMP180

    bt = bmp.readTemperature
    if count == 0 || (lastbt - bt).abs < 10
      btstr = pointstr(bt, 1)
      lastbt = bt
    else
      btstr = pointstr(lastbt, 1)
      error |= (1 << 0)
    end
    yabm.print "BMPT: #{btstr} "

    bp = bmp.readPressure
    if count == 0 || (lastbp - bp).abs < 100
      bpstr = pointstr(bp, 2)
      lastbp = bp
    else
      bpstr = pointstr(lastbp, 2)
      error |= (1 << 1)
    end
    yabm.print "P: #{bpstr} #{error} "

    # Si7021

    sh = si.getHumidityPercent
    if count == 0 || (lastsh - sh).abs < 20
      shstr = sh.to_s
      lastsh = sh
    else
      shstr = lastsh.to_s
      error |= (1 << 3)
    end

    st = si.getCelsiusHundredths
    if count == 0 || (lastst - st).abs < 100
      ststr = pointstr(st, 2)
      lastst = st
    else
      ststr = pointstr(lastst, 2)
      error |= (1 << 2)
    end
    yabm.print "SIT: #{ststr} RH: #{shstr} #{error}"

    para = 'api_key=' + APIKEY + '&field1=' + count.to_s + '&field2=' + btstr + '&field3=' + bpstr + '&field4=' + ststr + '&field5=' + shstr + '&field6=' + error.to_s
    if !NONET
      res = SimpleHttp.new('https', 'api.thingspeak.com', 443).request('GET', '/update?' + para,
                                                                       { 'User-Agent' => 'test-agent' })
      if !res.nil? && res.status.to_s.length != 0
        yabm.print " #{res.status}"
        neterr = 0
      else
        neterr += 1
        raise '' if neterr == MAXFAILE
      end
    end
    yabm.print "\r\n"
    count += 1

    reg = yabm.gpiogetdat
    reg |= TOP_LED3
    yabm.gpiosetdat(reg)

    if count == 500
      reg = yabm.gpiogetdat
      reg |= STATUS_LED2
      yabm.gpiosetdat(reg)
    end

    yabm.watchdogreset

    # ThingSpeak Free account need at intervals over 15 sec.
    if NONET
      yabm.msleep(5_000)
    else
      yabm.msleep(20_000)
    end
  end
rescue StandardError => e
  yabm.print e.to_s
end
