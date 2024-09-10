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
LEFTKEY = 76
RIGHTKEY = 82
CENTERKEY = 79

# LED1 is direct connect to VCC
LED10 = (1 << 6)
LED2 = (1 << 2)
LED6 = (1 << 1)
LED11 = (1 << 7)

def fib(num)
  return num if num < 2

  fib(num - 2) + fib(num - 1)
end

def dispfib(yabm)
  yabm.print ASCIIMODE, 1
  yabm.print 'fib(30)', 1
  yabm.print LF, 1
  yabm.print fib(30).to_s, 1
end

def disptitle(yabm)
  yabm.print ASCIIMODE, 1
  yabm.print 'mruby on', 1
  yabm.print LF, 1
  yabm.print 'YABM', 1
end

def dispkanji(yabm)
  yabm.print KANJIMODE, 1
  str = '洋酒といえば、誰でも最初に思い'
  yabm.print str, 1
  yabm.print LF, 1
  str = '浮かべるのがウイスキー。'
  yabm.print str, 1
  yabm.print LF, 1
  str = 'いわば洋酒のシンボル的な存在な'
  yabm.print str, 1
  yabm.print LF, 1
  str = 'のだが、英語表記が［一般に〔米'
  yabm.print str, 1
end

begin
  yabm = YABM.new

  yabm.setbaud(9600, 1)

  disptitle yabm

  loop do
    next unless yabm.havech(1)

    chr = yabm.getch(1)
    disptitle yabm if chr == CENTERKEY
    dispkanji yabm if chr == UPKEY
    dispfib yabm if chr == DOWNKEY
    if chr == LEFTKEY
      led = yabm.gpiogetdat
      led |= LED2
      yabm.gpiosetdat(led)
    elsif chr == RIGHTKEY
      led = yabm.gpiogetdat
      led &= ~LED2
      yabm.gpiosetdat(led)
    end
  end
rescue StandardError => e
  yabm.print e.to_s
end
