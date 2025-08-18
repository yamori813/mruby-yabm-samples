#
# rtlbm-mruby mruby script
#

begin

# ip address setting

addr = "10.0.1.123"
mask = "255.255.255.0"
gw = "10.0.1.1"
dns = "10.0.1.1"

http_hdr1 = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\nContent-Length: "
http_hdr2 = "\r\nConnection: close\r\n\r\n"
html_bdy = "<html><head><title>Congrats!</title></head><body><h1>Welcome to our mruby on YABM HTTP server!</h1><p>This is a small test page, served by LwIP raw method.</body></html>"

yabm = YABM.new

yabm.netstart(addr, mask, gw, dns)

yabm.httpsvrinit
yabm.httpsvrbind(8080)

res = http_hdr1 + html_bdy.length.to_s + http_hdr2 + html_bdy

yabm.httpsvrsetres(res, res.length)

loop do

end

rescue => e
  yabm.print e.to_s
end
