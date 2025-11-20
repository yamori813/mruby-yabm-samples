#
# bcmbm-mruby mruby script
#

class SHT3x
  SHTADDR = 0x44
  def initialize yabm
    @y = yabm
  end
  def chkcrc dat
    crc8 = 0xff
    for i in 0..1 do
      crc8 = crc8 ^ dat[i]
      8.times {
        if crc8 & 0x80 == 0x80 then
          crc8 = crc8 << 1
          crc8 = crc8 ^ 0x31
        else
          crc8 = crc8 << 1
        end
      }
    end
    if (crc8 & 0xff) == dat[2] then
      return true
    else
      return false
    end
  end
  def getStatus
    @y.i2cwrite(SHTADDR, 0xf3, 0x2d)
    @y.msleep(100)
    arr = @y.i2cread(SHTADDR, 3)
    return (arr[0] << 8) | arr[1]
  end
  def getCelsiusAndHumidity
    while @y.i2cchk(SHTADDR) == 0 do
      @y.msleep(1)
    end
    @y.i2cwrite(SHTADDR, 0x24, 0x00)
    @y.msleep(500)
    while 1 do
      arr = @y.i2cread(SHTADDR, 6)
      if arr then
        break
      end
      @y.msleep(1)
    end
    t = ((arr[0] << 8) | arr[1]) * 17500 / 65535 - 4500
    h = ((arr[3] << 8) | arr[4]) * 10000 / 65535
    return t, h
  end
end
