#
# bcmbm-mruby mruby script
#
# Weather Station used by MPL115A2, SHT30, BH1750 on WCA-G
# use i2c/bh1750_c.rb i2c/mpl115_c.rb i2c/sht3x_c.rb 

# GPIO I2C Pin used SW3

SCL = 5
SDA = 3

LED10 = (1 << 6) # green
LED2 = (1 << 2)
LED6 = (1 << 1)
LED11 = (1 << 7) # red

MEASINTERVAL = 30
MEASCOUNT = 5

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

yabm.i2cinit(SCL, SDA, 1)

sht = SHT3x.new yabm

mpl = MPL115.new yabm

bh = BH1750.new yabm

aht = AHT21.new yabm

ens = ENS160.new yabm

bh.setMTreg(254)
bh.setMeasurement(BH1750::ONE_TIME_HIGH_RES_MODE_2)

count = 0

tsum = 0
hsum = 0
psum = 0
lxsum = 0
aqimax = 0
tvocsum = 0
eco2sum = 0

SimpleHttp.new("http", oumon, 80).request("GET", "/cgi/reboot.cgi", {'User-Agent' => "test-agent"})

yabm.watchdogstart(300)

loop do

  reg = yabm.gpiogetdat
  if count == MEASCOUNT - 1 then
    yabm.gpiosetdat(reg & ~LED11)
  else
    yabm.gpiosetdat(reg & ~LED10)
  end

  t, h = sht.getCelsiusAndHumidity
  yabm.print count.to_s + " " + pointstr(t, 2) + " " + pointstr(h, 2) + " "
  tsum = tsum + t
  hsum = hsum + h

  p = mpl.readPressure
  yabm.print pointstr(p, 2) + " "
  psum = psum + p

  lx = bh.getLightLevel
  yabm.print pointstr(lx, 2) + " "
  lxsum = lxsum + lx

  trh = aht.sensorRead
  ens.setTempRh trh[0], trh[1]
  gas = ens.getData
  yabm.print gas[0].to_s + " " + gas[1].to_s + " " + gas[2].to_s + " "
  if gas[0] > aqimax then
    aqimax = gas[0]
  end
  tvocsum += gas[1]
  eco2sum += gas[2]

  yabm.print "\r\n"

  if count == MEASCOUNT - 1 then
    t = tsum / MEASCOUNT
    h = hsum / MEASCOUNT
    p = psum / MEASCOUNT
    lx = lxsum / MEASCOUNT
    tv = tvocsum / MEASCOUNT
    ec = eco2sum / MEASCOUNT
    para = "&field1=" + pointstr(t, 2)
    para += "&field2=" + pointstr(h, 2)
    para += "&field3=" + pointstr(p, 2)
    para += "&field4=" + pointstr(lx, 2)
    para += "&field5=" + aqimax.to_s
    para += "&field6=" + tv.to_s
    para += "&field7=" + ec.to_s
    res = SimpleHttp.new("http", oumon, 80).request("GET", "/cgi/wsupdate.cgi?" + para, {'User-Agent' => "test-agent"})

    count = 0

    tsum = 0
    hsum = 0
    psum = 0
    lxsum = 0
    aqimax = 0
    tvocsum = 0
    eco2sum = 0

    reg = yabm.gpiogetdat
    yabm.gpiosetdat(reg | LED11)
  else
    reg = yabm.gpiogetdat
    yabm.gpiosetdat(reg | LED10)
    count = count + 1
  end

  yabm.watchdogreset

  yabm.msleep(1000 * MEASINTERVAL)
end

rescue => e
  yabm.print e.to_s
end
