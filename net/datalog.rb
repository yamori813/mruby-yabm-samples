#
# mruby on YABM script
# use lib/yabmtime.rb, rtlbm/sub_hsc.rb, i2c/bmp160.rb 
# BMP180 temperature logging script
#

# GPIO I2C Pin (SW12)

SCL = 2
SDA = 11

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

b = BMP180.new yabm, BMP180::OSS_STANDARD

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
  t = b.readTemperature
  tstr = (t / 10).to_s + "." + (t % 10).to_s
  sum = sum + t
  count = count + 1

  yabm.print tstr + " "

  yabm.msleep 60_000
end

rescue => e
  yabm.print e.to_s
end
