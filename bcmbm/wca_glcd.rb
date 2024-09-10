# control code
ASCIIMODE = "\x01"
KANJIMODE = "\x02"
CLEAR = "\x0c"
LF = "\x0d"
BACK = "\x08"
FORWARD = "\x09"

begin
  yabm = YABM.new

  yabm.setbaud(9600, 1)

  loop do
    str = 'Hello mruby'
    yabm.print str, 1
    yabm.msleep 5_000

    yabm.print LF, 1
    str = 'on bcmbm'
    yabm.print str, 1
    yabm.msleep 5_000

    yabm.print CLEAR, 1
    yabm.msleep 3_000
  end
rescue StandardError => e
  yabm.print e.to_s
end
