begin

yabm = YABM.new

yabm.netstartdhcp

yabm.print "Hello Bear Metal mruby on YABM\r\n"

count = 1

yabm.print yabm.getaddress + "\r\n"

loop do

  yabm.print "simple http " + count.to_s + "\r\n"

  s = SimpleHttp.new("http", "httpbin.org", 80)
  if s
    res = s.request("GET", "/ip", {'User-Agent' => "test-agent"})
    if res.status.to_s == ""
      yabm.print "ERROR\r\n"
    else
      yabm.print "GET done " + res.status.to_s + "\r\n"
    end
  else
    yabm.print "SimpleHttp error\r\n"
  end

  count += 1

  yabm.msleep 10_000
end

rescue => e
  yabm.print e.to_s
end
