#
# morus code generator
# need compile with subroutine file
#

MORSE_NUM = ['01111', '00111', '00011', '00001', '00000', '10000', '11000', '11100', '11110', '11111']

MORSE_ALPH = ['01', '1000', '1010', '100', '0', '0010', '110', '0000', '00', '0111', '101', '0100', '11', '10', '111', '0110', '1101', '010', '000', '1', '001', '0001', '011', '1001', '1011', '1100']

LEN = 70

def morus(yabm, str)
  i = 0
  while i < str.length
    ledon yabm
    if str[i] == '0'
      yabm.msleep LEN
    else
      yabm.msleep LEN * 3
    end
    ledoff yabm
    i += 1
    yabm.msleep LEN
  end
end

yabm = YABM.new

gpioinit(yabm)

str = 'mruby on yet another bare metal'

loop do
  i = 0
  while i < str.length
    if str[i] == ' '
      yabm.msleep LEN * 7
    elsif str[i] >= 'a' && str[i] <= 'z'
      morus yabm, MORSE_ALPH[str[i].ord - 'a'.ord]
    else
      morus yabm, MORSE_NUM[str[i].ord - '0'.ord]
    end
    i += 1
  end
  yabm.msleep 3_000
end
