#
# mruby on YABM script
#
# Weather Station used by BMP180 and Si7021 on HomeSpotCube
# need sub_hsc.rb i2c/bmp180_c.rb i2c/si7021_c.rb
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
