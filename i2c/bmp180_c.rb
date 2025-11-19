#
# mruby on YABM script
#

class BMP180

  OSS_ULTRA_LOW_POWER = 0
  OSS_STANDARD = 1
  OSS_HIGH_RESOLUTION = 2
  OSS_ULTRA_HIGH_RESOLUTION = 3

  BMPADDR = 0x77
  PRESSURE_WAIT = [5, 8, 14, 26]

  def readup
    msb = @y.i2cread(BMPADDR, 1, 0xf6)
    lsb = @y.i2cread(BMPADDR, 1, 0xf7)
    xlsb = @y.i2cread(BMPADDR, 1, 0xf8)
    ((msb << 16) + (lsb << 8) + xlsb) >> (8 - @oss)
  end

  def readu16(addr)
    (@y.i2cread(BMPADDR, 1, addr) << 8) | @y.i2cread(BMPADDR, 1, addr + 1)
  end

  def read16(addr)
    val = (@y.i2cread(BMPADDR, 1, addr) << 8) | @y.i2cread(BMPADDR, 1, addr + 1)
    val -= 0x10000 if val >= 0x8000
    val
  end

  def initialize(yabm, oss)
    @y = yabm
    @oss = oss
    @ac1 = read16 0xaa
    @ac2 = read16 0xac
    @ac3 = read16 0xae
    @ac4 = readu16 0xb0
    @ac5 = readu16 0xb2
    @ac6 = readu16 0xb4
    @b1 = read16 0xb6
    @b2 = read16 0xb8
    @mb = read16 0xba
    @mc = read16 0xbc
    @md = read16 0xbe
  end

  def readTemperature
    @y.msleep(1) while @y.i2cchk(BMPADDR) == 0
    @y.i2cwrite(BMPADDR, 0xf4, 0x2e)
    @y.msleep(5)
    ut = read16 0xf6
    #    @y.print ut.to_s + " "

    # calculate true temperature

    x1 = ((ut - @ac6) * @ac5) >> 15
    x2 = (@mc << 11) / (x1 + @md)
    @b5 = x1 + x2
    (@b5 + 8) >> 4
  end

  def getChipid
    @y.i2cread(BMPADDR, 1, 0xd0)
  end
  # calculate true pressure

  def readPressure
    @y.i2cwrite(BMPADDR, 0xf4, 0x34 + (@oss << 6))
    @y.msleep(PRESSURE_WAIT[@oss])
    up = readup
    #    @y.print up.to_s + " "

    b6 = @b5 - 4000
    x1 = (@b2 * ((b6 * b6) >> 12)) >> 11
    x2 = (@ac2 * b6) >> 11
    x3 = x1 + x2
    b3 = ((((@ac1 * 4) + x3) << @oss) + 2) >> 2
    x1 = (@ac3 * b6) >> 13
    x2 = (@b1 * ((b6 * b6) >> 12)) >> 16
    x3 = ((x1 + x2) + 2) >> 2
    b4 = (@ac4 * (x3 + 32_768)) >> 15
    b7 = (up - b3) * (50_000 >> @oss)

    # This is only temporally code because of valid non overflow
    p = b7 / (b4 >> 1)

    x1 = (p >> 8) * (p >> 8)
    x1 = (x1 * 3038) >> 16
    x2 = (-7357 * p) >> 16
    p + ((x1 + x2 + 3791) >> 4)
  end
end
