#
# mruby on YABM script
# use lib/yabmtime.rb
#

begin

yabm = YABM.new

yabm.netstartdhcp

yabm.print yabm.getaddress + "\r\n"
  
ntpaddr = yabm.lookup("ntp.nict.jp")
yabm.sntp(ntpaddr)
yabm.msleep 3_000

d = YABMTIME.new

yabm.print "Hello Bear Metal mruby on YABM\r\n"
    
loop do
  now = 0x7fffffff + yabm.now
  date = d.mkstr now + 9 * 60 * 60
  yabm.print date + "\r\n"
  yabm.msleep 60_000
end
    
rescue => e
  yabm.print e.to_s
end
