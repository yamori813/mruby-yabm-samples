#
# Sample script for mruby on Yet Another Bare Metal
#

begin
  yabm = YABM.new

  yabm.setbaud(9600, 1)

  yabm.print "UART two port test\r\n"

  loop do
    if yabm.havech(0)
      c = yabm.getch(0)
      yabm.print c.chr, 1
    end
    if yabm.havech(1)
      c = yabm.getch(1)
      yabm.print c.chr, 0
    end
  end
rescue StandardError => e
  yabm.print e.to_s
end
