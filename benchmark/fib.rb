#
# mruby on YABM script
#

FNUM = 32

def fib(num)
  return num if num < 2

  fib(num - 2) + fib(num - 1)
end

begin
  yabm = YABM.new

  loop do
    start = yabm.count
    fib(FNUM)
    time = (yabm.count - start) / 1000
    yabm.print "fib(#{FNUM}): #{time} sec,"
  end
rescue StandardError => e
  yabm.print e.to_s
end
