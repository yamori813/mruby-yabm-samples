#
# rtlbm-mruby mruby script
# use lib/yabmtime.rb
#

begin

# ip address setting

addr = "10.0.1.123"
mask = "255.255.255.0"
gw = "10.0.1.1"
dns = "10.0.1.1"

http_hdr1 = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\nContent-Length: "
http_hdr2 = "\r\nConnection: close\r\n\r\n"
html_bdy1 = "<html><head><title>Congrats!</title></head><body><h1>Welcome to our mruby on YABM HTTP server!</h1><p>"
html_bdy2 = "</body></html>"

yabm = YABM.new

yabm.netstart(addr, mask, gw, dns)

ntpaddr = yabm.lookup("ntp.nict.jp")
yabm.sntp(ntpaddr)
yabm.msleep 3_000

yabm.httpsvrinit
yabm.httpsvrbind(8080)

d = YABMTIME.new

loop do
  now = 0x7fffffff + yabm.now
  date = d.mkstr now + 9 * 60 * 60
  html = html_bdy1 + date + html_bdy2
  res = http_hdr1 + html.length.to_s + http_hdr2 + html
  yabm.httpsvrsetres(res, res.length)
  yabm.msleep 60_000
end

rescue => e
  yabm.print e.to_s
end
