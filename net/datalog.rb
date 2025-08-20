#
# mruby on YABM script
# use lib/yabmtime.rb, rtlbm/sub_hsc.rb
# BMP180 temperature logging script
#

# GPIO I2C Pin (SW12)

SCL = 2
SDA = 11

BMPADDR = 0x77

PRESSURE_WAIT = [5, 8, 14, 26]

def readup(yabm, oss) 
  msb = yabm.i2cread(BMPADDR, 1, 0xf6)
  lsb = yabm.i2cread(BMPADDR, 1, 0xf7)
  xlsb = yabm.i2cread(BMPADDR, 1, 0xf8)
  val = ((msb << 16) + (lsb << 8) + xlsb) >> (8 - oss)
  return val
end

def readu16(yabm, addr) 
  val = yabm.i2cread(BMPADDR, 1, addr) << 8 | yabm.i2cread(BMPADDR, 1, addr + 1)
  return val
end

def read16(yabm, addr) 
  val = yabm.i2cread(BMPADDR, 1, addr) << 8 | yabm.i2cread(BMPADDR, 1, addr + 1)
  if val >= 0x8000 then
    val = val - 0x10000
  end
  return val
end

begin

# ip address setting

addr = "10.0.1.123"
mask = "255.255.255.0"
gw = "10.0.1.1"
dns = "10.0.1.1"

http_hdr1 = "HTTP/1.1 200 OK\r\nContent-type: application/json\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: "
http_hdr2 = "\r\nConnection: close\r\n\r\n"

yabm = YABM.new

yabm.netstart(addr, mask, gw, dns)
#ntpaddr = yabm.lookup("ntp.nict.jp")
ntpaddr = "10.0.1.18"
yabm.sntp(ntpaddr)
yabm.msleep 3_000

yabm.httpsvrinit
yabm.httpsvrbind(8080)

body = '[]'
res = http_hdr1 + body.length.to_s + http_hdr2 + body
yabm.httpsvrsetres(res, res.length)

gpioinit(yabm)

yabm.i2cinit(SCL, SDA, 1)

ac1 = read16(yabm, 0xaa)
ac2 = read16(yabm, 0xac)
ac3 = read16(yabm, 0xae)
ac4 = readu16(yabm, 0xb0)
ac5 = readu16(yabm, 0xb2)
ac6 = readu16(yabm, 0xb4)
b1 = read16(yabm, 0xb6)
b2 = read16(yabm, 0xb8)
mb = read16(yabm, 0xba)
mc = read16(yabm, 0xbc)
md = read16(yabm, 0xbe)

d = YABMTIME.new

json = ""
sum = 0
count = 0

now = 0x7fffffff + yabm.now
tm = d.mktm now + 9 * 60 * 60

lm = tm[4]
ld = tm[3]
lh = tm[2]

loop do

  now = 0x7fffffff + yabm.now
  tm = d.mktm now + 9 * 60 * 60
  if lh != tm[2]
    mstr = (lm + 1).to_s(10).rjust(2, '0') 
    dstr = ld.to_s(10).rjust(2, '0') 
    hstr = lh.to_s(10).rjust(2, '0') 
    av = sum / count
    lastdat = '{"time":"' + mstr + dstr + hstr + '","temp":' + (av / 10).to_s + '.' + (av % 10).to_s + '}'
    if json.length == 0
      json = lastdat
    else
      json = json + ',' + lastdat
    end
    body = '[' + json + ']'
    res = http_hdr1 + body.length.to_s + http_hdr2 + body
    yabm.print res
    yabm.httpsvrsetres(res, res.length)
    lm = tm[4]
    ld = tm[3]
    lh = tm[2]
    sum = 0
    count = 0
  end

  yabm.msleep(1000)
  yabm.i2cwrite(BMPADDR, 0xf4, 0x2e)
  yabm.msleep(500)
  ut = read16(yabm, 0xf6)
  yabm.print ut.to_s + " "

  if ut != 0
    x1 = (ut - ac6) * ac5 >> 15
    x2 = (mc << 11) / (x1 + md)
    b5 = x1 + x2
    t = (b5 + 8) >> 4

    tstr = (t / 10).to_s + "." + (t % 10).to_s
    sum = sum + t
    count = count + 1

    yabm.print tstr + " "
  end

  yabm.msleep 60_000
end

rescue => e
  yabm.print e.to_s
end
