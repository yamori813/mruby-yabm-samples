#
# Sample script for mruby on Yet Another Bare Metal
#

begin

yabm = YABM.new

#yabm.setbaud(9600, 0)

yabm.print "UART echo back test\r\n"

loop do
   if yabm.havech(0)
     c = yabm.getch(0)
     yabm.print c.chr
   end
end

rescue => e
  yabm.print e.to_s
end

