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

# i2c address

MPLADDR = 0x60
SHTADDR = 0x44
BHADDR = 0x23

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

# senser class

class BH1750
  @mtreg = 69

  # Measurement at 1 lux resolution. Measurement time is approx 120ms.
  CONTINUOUS_HIGH_RES_MODE  = 0x10
  # Measurement at 0.5 lux resolution. Measurement time is approx 120ms.
  CONTINUOUS_HIGH_RES_MODE_2 = 0x11
  # Measurement at 4 lux resolution. Measurement time is approx 16ms.
  CONTINUOUS_LOW_RES_MODE = 0x13
  # Measurement at 1 lux resolution. Measurement time is approx 120ms.
  ONE_TIME_HIGH_RES_MODE = 0x20
  # Measurement at 0.5 lux resolution. Measurement time is approx 120ms.
  ONE_TIME_HIGH_RES_MODE_2 = 0x21
  # Measurement at 4 lux resolution. Measurement time is approx 16ms.
  ONE_TIME_LOW_RES_MODE = 0x23

  def init yabm, addr
    @y = yabm
    @addr = addr
  end

  def setMTreg mtreg
    @mtreg = mtreg
    @y.i2cwrite(@addr, [0x40 | (@mtreg >> 5)])
    @y.msleep(200)
    @y.i2cwrite(@addr, [0x60 | (@mtreg & 0x1f)])
    @y.msleep(200)
  end

  def setMeasurement mode
    @meas = mode
    if @meas == CONTINUOUS_HIGH_RES_MODE ||
      @meas == CONTINUOUS_HIGH_RES_MODE_2 ||
      @meas == CONTINUOUS_LOW_RES_MODE then
      @y.i2cwrite(@addr, [@meas])
    end
  end

  def getLightLevel
    if @meas == ONE_TIME_HIGH_RES_MODE ||
      @meas == ONE_TIME_HIGH_RES_MODE_2 then
      @y.i2cwrite(@addr, [@meas])
      @y.msleep(120 * @mtreg / 69)
    elsif @meas == ONE_TIME_LOW_RES_MODE then
      @y.i2cwrite(@addr, [@meas])
      @y.msleep(16 * @mtreg / 69)
    end
    bharr = @y.i2cread(@addr, 2)
    val = (bharr[0] << 8) | bharr[1]
    if @meas == CONTINUOUS_HIGH_RES_MODE_2 ||
      @meas == ONE_TIME_HIGH_RES_MODE_2 then
      lx = val * 50 * 69 * 5 / (6 * @mtreg)
    else
      lx = val * 100 * 69 * 5 / (6 * @mtreg)
    end
    return lx
  end
end

class SHT3x
  def init yabm
    @y = yabm
  end
  def chkcrc dat
    crc8 = 0xff
    for i in 0..1 do
      crc8 = crc8 ^ dat[i]
      8.times {
        if crc8 & 0x80 == 0x80 then
          crc8 = crc8 << 1
          crc8 = crc8 ^ 0x31
        else
          crc8 = crc8 << 1
        end
      }
    end
    if (crc8 & 0xff) == dat[2] then
      return true
    else
      return false
    end
  end
  def getStatus
    @y.i2cwrite(SHTADDR, 0xf3, 0x2d)
    @y.msleep(100)
    arr = @y.i2cread(SHTADDR, 3)
    return (arr[0] << 8) | arr[1]
  end
  def getCelsiusAndHumidity
    while @y.i2cchk(SHTADDR) == 0 do
      @y.msleep(1)
    end
    @y.i2cwrite(SHTADDR, 0x24, 0x00)
    @y.msleep(500)
    while 1 do
      arr = @y.i2cread(SHTADDR, 6)
      if arr then
        break
      end
      @y.msleep(1)
    end
    t = ((arr[0] << 8) | arr[1]) * 17500 / 65535 - 4500
    h = ((arr[3] << 8) | arr[4]) * 10000 / 65535
    return t, h
  end
end

class MPL115
  def init yabm
    @y = yabm
    while @y.i2cchk(MPLADDR) == 0 do
      @y.msleep(1)
    end
    @a0 = @y.i2cread(MPLADDR, 1, 0x04) << 8 | @y.i2cread(MPLADDR, 1, 0x05)
    @b1 = @y.i2cread(MPLADDR, 1, 0x06) << 8 | @y.i2cread(MPLADDR, 1, 0x07)
    @b2 = @y.i2cread(MPLADDR, 1, 0x08) << 8 | @y.i2cread(MPLADDR, 1, 0x09)
    @c12 = @y.i2cread(MPLADDR, 1, 0x0a) << 8 | @y.i2cread(MPLADDR, 1, 0x0b)
  end

# This calculate code is based c source code in NXP AN3785 document

  def calculatePCompShort(padc, tadc, a0, b1, b2, c12)
    if a0 >= 0x8000 then
      a0 = a0 - 0x10000
    end
    if b1 >= 0x8000 then
      b1 = b1 - 0x10000
    end
    if b2 >= 0x8000 then
      b2 = b2 - 0x10000
    end
    if c12 >= 0x8000 then
      c12 = c12 - 0x10000
    end
    padc = padc >> 6
    tadc = tadc >> 6
    c12x2 = (c12 * tadc) >> 11
    a1 = b1 + c12x2;
    a1x1 = a1 * padc
    y1 = (a0 << 10) + a1x1
    a2x2 = (b2 * tadc) >> 1
    pcomp = (y1 + a2x2) >> 9
    return pcomp
  end

  def readPressure
    while @y.i2cchk(MPLADDR) == 0 do
      @y.msleep(1)
    end
    @y.i2cwrite(MPLADDR, 0x12, 0x01)
    @y.msleep(10)
    padc = @y.i2cread(MPLADDR, 1, 0x00) << 8 | @y.i2cread(MPLADDR, 1, 0x01)
    tadc = @y.i2cread(MPLADDR, 1, 0x02) << 8 | @y.i2cread(MPLADDR, 1, 0x03)

    pcomp = calculatePCompShort(padc, tadc, @a0, @b1, @b2, @c12)
    pressure = ((pcomp * 1041) >> 14) + 800
    frec = ((pressure & 0xf) * 1000) / 16
    return ((pressure >> 4) * 1000) + frec
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

sht = SHT3x.new
sht.init yabm

mpl = MPL115.new
mpl.init yabm

bh = BH1750.new
bh.init(yabm, BHADDR)

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
