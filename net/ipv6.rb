#
# mruby on yabm script
# need compile with subroutine file
# 
#

begin

yabm = YABM.new

yabm.netstartdhcp

gpioinit yabm

# sync date by ntp use https X.509
#ntpaddr = yabm.lookup("ntp.nict.jp")
#yabm.sntp(ntpaddr)

yabm.msleep 3_000
ntpaddr6 = yabm.lookup6("ntp.nict.jp")
yabm.print ntpaddr6 + "\r\n"
yabm.sntp(ntpaddr6)

count = 0
interval = 60
times = 10

yabm.watchdogstart(256)

while count < times
  count += 1
  ledon yabm
  yabm.print count.to_s
  res = SimpleHttp.new("https", "v6.ipv6-test.com", 443, 1).request("GET", "/api/myip.php", {'User-Agent' => "test-agent"})
  ledoff yabm
  yabm.print " " + res.body.to_s + "\r\n"
  yabm.msleep interval * 1000
  yabm.watchdogreset
end

rescue => e
  yabm.print e.to_s
end
