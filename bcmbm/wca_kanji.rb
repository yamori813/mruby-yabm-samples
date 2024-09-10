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
  yabm.print KANJIMODE, 1

  loop do
    str = 'あいうえお'
    yabm.print str, 1
    yabm.msleep 5_000

    yabm.print LF, 1
    str = 'abcdef12345'
    yabm.print str, 1
    yabm.msleep 5_000

    yabm.print LF, 1
    str = '洋酒といえば、誰でも最初に思い'
    yabm.print str, 1
    yabm.print LF, 1
    str = '浮かべるのがウイスキー。'
    yabm.print str, 1
    yabm.msleep 10_000

    yabm.print CLEAR, 1
    yabm.msleep 3_000
  end
rescue StandardError => e
  yabm.print e.to_s
end
