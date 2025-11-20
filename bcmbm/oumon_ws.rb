#
# bcmbm-mruby mruby script
#
# Weather Station used by MPL115A2, SHT30, BH1750 on WCA-G
#

# GPIO I2C Pin used SW3

SCL = 5
SDA = 3

LED10 = (1 << 6) # green
LED2 = (1 << 2)
LED6 = (1 << 1)
LED11 = (1 << 7) # red

# utility function

def pointstr(p, c)
  if p == 0 then
    return "0." + "0" * c
  elsif p.abs < 10 ** c
    l = c - p.abs.to_s.length + 1
    s = p.to_s.insert(p < 0 ? 1 : 0, "0" * l)
    return s.insert(-1 - c, ".")
  else
    return p.to_s.insert(-1 - c, ".")
  end
end

begin

# start processing

yabm = YABM.new

yabm.print "Hello oumon wather station\r\n"

#yabm.netstartdhcp

addr = "10.10.10.25"
mask = "255.255.255.0"
gw = "10.10.10.18"
dns = "10.10.10.18"

oumon = "10.10.10.18"

yabm.netstart(addr, mask, gw, dns)

yabm.print yabm.getaddress + "\r\n"

# sync date by ntp use https X.509
#ntpaddr = yabm.lookup("ntp.nict.jp")
#yabm.sntp(ntpaddr)

yabm.i2cinit(SCL, SDA, 1)

sht = SHT3x.new yabm

mpl = MPL115.new yabm

bh = BH1750.new yabm

bh.setMTreg(254)
bh.setMeasurement(BH1750::ONE_TIME_HIGH_RES_MODE_2)

measureint = 30
postint = 10
count = 0

lastst = 0
lastsh = 0
lastmp = 0

tsum = 0
hsum = 0
psum = 0
lxsum = 0

SimpleHttp.new("http", oumon, 80).request("GET", "/cgi/reboot.cgi", {'User-Agent' => "test-agent"})

yabm.watchdogstart(300)

loop do

  error = 0

  reg = yabm.gpiogetdat
  if count == postint - 1 then
    yabm.gpiosetdat(reg & ~LED11)
  else
    yabm.gpiosetdat(reg & ~LED10)
  end

  t, h = sht.getCelsiusAndHumidity
  if count == 0 || (lastst - t).abs < 100 then
    lastst = t
  else
    t = lastst
    error = error | (1 << 0)
  end
  if count == 0 || (lastsh - h).abs < 2000 then
    lastsh = h
  else
    h = lastsh
    error = error | (1 << 1)
  end
  yabm.print count.to_s + " " + pointstr(t, 2) + " " + pointstr(h, 2) + " "
  tsum = tsum + t
  hsum = hsum + h

  p = mpl.readPressure
  if count == 0 || (lastmp - p).abs < 1000 then
    lastmp = p
  else
    p = lastmp
    error = error | (1 << 2)
  end
  yabm.print pointstr(p, 2) + " "
  psum = psum + p

  lx = bh.getLightLevel
  yabm.print pointstr(lx, 2) + " "
  lxsum = lxsum + lx

  yabm.print error.to_s + "\r\n"

  if count == postint - 1 then
    t = tsum / postint
    h = hsum / postint
    p = psum / postint
    lx = lxsum / postint
    para = ""
    para = para + "&field1=" + pointstr(t, 2)
    para = para + "&field2=" + pointstr(h, 2)
    para = para + "&field3=" + pointstr(p, 2)
    para = para + "&field4=" + pointstr(lx, 2)
#    res = SimpleHttp.new("https", "api.thingspeak.com", 443).request("GET", "/update?" + para, {'User-Agent' => "test-agent"})
    res = SimpleHttp.new("http", oumon, 80).request("GET", "/cgi/wsupdate.cgi?" + para, {'User-Agent' => "test-agent"})
#    yabm.print  res.status.to_s + "\r\n"
    count = 0
    tsum = 0
    hsum = 0
    psum = 0
    lxsum = 0
    reg = yabm.gpiogetdat
    yabm.gpiosetdat(reg | LED11)
  else
    reg = yabm.gpiogetdat
    yabm.gpiosetdat(reg | LED10)
    count = count + 1
  end

  yabm.watchdogreset

  yabm.msleep(1000 * measureint)
end

rescue => e
  yabm.print e.to_s
end
