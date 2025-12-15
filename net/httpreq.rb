#
# mruby on YABM script
# need subroutine

begin

# ip address setting

addr = "10.0.1.111"
mask = "255.255.255.0"
gw = "10.0.1.1"
dns = "10.0.1.1"

http_hdr1 = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\nContent-Length: "
http_hdr2 = "\r\nConnection: close\r\n\r\n"
html_bdy = "OK"

yabm = YABM.new

gpioinit yabm

yabm.netstart(addr, mask, gw, dns)

yabm.httpsvrinit
yabm.httpsvrbind(8080)

res = http_hdr1 + html_bdy.length.to_s + http_hdr2 + html_bdy

yabm.httpsvrsetres(res, res.length)

loop do

  val = yabm.httpsvrgetreq
  if val
    req = val.lines[0].split(' ')
    ppos = req[1].index('?')
    if ppos
      if req[1].slice(0..ppos-1) == "/ctrl"
        len = req[1].length
        que = req[1][ppos+1..len]
        params = {}
        para = que.to_s.split('&')
        para.each do |p|
          a = p.split('=')
          params[a[0]] = a[1]
        end
        if params["led"] && params["led"] == "off"
          ledoff yabm
          yabm.print "ledoff\r\n"
        elsif params["led"] && params["led"] == "on"
          ledon yabm
          yabm.print "ledon\r\n"
        end
      end
    end 
  end
end

rescue => e
  yabm.print e.to_s
end
