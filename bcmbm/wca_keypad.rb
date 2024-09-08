begin
  yabm = YABM.new

  yabm.setbaud(9600, 1)

  yabm.print 'mruby on', 1
  yabm.print "\x0d", 1
  yabm.print 'YABM', 1

  loop do
    next unless yabm.havech(1)

    chr = yabm.getch(1)
    yabm.print "\x0c", 1
    yabm.print 'UP', 1 if chr == 85
    yabm.print 'DOWN', 1 if chr == 68
    yabm.print 'LEFT', 1 if chr == 76
    yabm.print 'RIGHT', 1 if chr == 82
    yabm.print 'CENTER', 1 if chr == 79
  end
rescue StandardError => e
  yabm.print e.to_s
end
