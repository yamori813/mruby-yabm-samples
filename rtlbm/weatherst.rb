#
# mruby on YABM script
#
# Weather Station used by BMP180 
# need compile with subroutine file
# need i2c/bmp180_c.rb
#

APIKEY = 'naisyo'

if APIKEY == 'naisyo'
  NONET = true
else
  NONET = false
end

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

  # 0 ultra low power, 1 standard, 2 high resolution, 3 ultra high resolution
  bmp = BMP180.new(yabm, 3)
  id = bmp.getChipid
  yabm.print "BMP180 ID: #{id}\r\n"

  count = 0

  yabm.watchdogstart(256)

  loop do

    yabm.print "#{count} "

    ledon yabm

    # BMP180

    bt = bmp.readTemperature
    btstr = pointstr(bt, 1)
    yabm.print "BMPT: #{btstr} "

    bp = bmp.readPressure
    bpstr = pointstr(bp, 2)

    yabm.print "P: #{bpstr} "

    para = 'api_key=' + APIKEY + '&field1=' + count.to_s + '&field2=' + btstr + '&field3=' + bpstr

    if !NONET
      res = SimpleHttp.new('https', 'api.thingspeak.com', 443).request('GET', '/update?' + para,
                                                                       { 'User-Agent' => 'test-agent' })
      if !res.nil? && res.status.to_s.length != 0
        yabm.print " #{res.status}"
      end
    end
    yabm.print "\r\n"
    count += 1

    ledoff yabm

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
