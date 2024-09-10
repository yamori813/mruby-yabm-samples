# control code
ASCIIMODE = "\x01"
KANJIMODE = "\x02"
CLEAR = "\x0c"
LF = "\x0d"
BACK = "\x08"
FORWARD = "\x09"

# key code
UPKEY = 85
DOWNKEY = 68
LEFTKEY =76
RIGHTKEY = 82
CENTERKEY = 79

begin
  yabm = YABM.new

  yabm.setbaud(9600, 1)

  yabm.print 'mruby on', 1
  yabm.print LF, 1
  yabm.print 'YABM', 1

  loop do
    next unless yabm.havech(1)

    chr = yabm.getch(1)
    yabm.print "\x0c", 1
    yabm.print 'UP', 1 if chr == UPKEY
    yabm.print 'DOWN', 1 if chr == DOWNKEY
    yabm.print 'LEFT', 1 if chr == LEFTKEY
    yabm.print 'RIGHT', 1 if chr == RIGHTKEY
    yabm.print 'CENTER', 1 if chr == CENTERKEY
  end
rescue StandardError => e
  yabm.print e.to_s
end
