#
# mruby on YABM script
#
# ambient update script
#

WRITEKEY = "naisyo"
CHANNELID = "naisyo"

INTERVAL = 30

begin

yabm = YABM.new

# net setup

yabm.netstartdhcp

yabm.print yabm.getaddress + "\n"

count = 0

loop do
  yabm.print "."
  count += 1
  yabm.print " " + count.to_s

  body='{ "writeKey":"' + WRITEKEY + '", "d1":' + count.to_s + '}'

  header = Hash.new
  header.store('User-Agent', "test-agent")
  header.store('Content-Type', "application/json")
  header.store('Body', body)
  path = "/api/v2/channels/" + CHANNELID + "/data"
  res = SimpleHttp.new("http", "ambidata.io", 80).post(path, header)
  if res 
    yabm.print " " + res.status.to_s
  end
  yabm.print "\n"
  yabm.msleep(INTERVAL * 1000)
end

rescue => e
  yabm.print e.to_s
end
