#
# bcmbm-mruby mruby script
#

class MPL115
  MPLADDR = 0x60

  def initialize yabm
    @y = yabm
    while @y.i2cchk(MPLADDR) == 0 do
      @y.msleep(1)
    end
    @a0 = @y.i2cread(MPLADDR, 1, 0x04) << 8 | @y.i2cread(MPLADDR, 1, 0x05)
    @b1 = @y.i2cread(MPLADDR, 1, 0x06) << 8 | @y.i2cread(MPLADDR, 1, 0x07)
    @b2 = @y.i2cread(MPLADDR, 1, 0x08) << 8 | @y.i2cread(MPLADDR, 1, 0x09)
    @c12 = @y.i2cread(MPLADDR, 1, 0x0a) << 8 | @y.i2cread(MPLADDR, 1, 0x0b)
  end

# This calculate code is based c source code in NXP AN3785 document

  def calculatePCompShort(padc, tadc, a0, b1, b2, c12)
    if a0 >= 0x8000 then
      a0 = a0 - 0x10000
    end
    if b1 >= 0x8000 then
      b1 = b1 - 0x10000
    end
    if b2 >= 0x8000 then
      b2 = b2 - 0x10000
    end
    if c12 >= 0x8000 then
      c12 = c12 - 0x10000
    end
    padc = padc >> 6
    tadc = tadc >> 6
    c12x2 = (c12 * tadc) >> 11
    a1 = b1 + c12x2;
    a1x1 = a1 * padc
    y1 = (a0 << 10) + a1x1
    a2x2 = (b2 * tadc) >> 1
    pcomp = (y1 + a2x2) >> 9
    return pcomp
  end

  def readPressure
    while @y.i2cchk(MPLADDR) == 0 do
      @y.msleep(1)
    end
    @y.i2cwrite(MPLADDR, 0x12, 0x01)
    @y.msleep(10)
    padc = @y.i2cread(MPLADDR, 1, 0x00) << 8 | @y.i2cread(MPLADDR, 1, 0x01)
    tadc = @y.i2cread(MPLADDR, 1, 0x02) << 8 | @y.i2cread(MPLADDR, 1, 0x03)

    pcomp = calculatePCompShort(padc, tadc, @a0, @b1, @b2, @c12)
    pressure = ((pcomp * 1041) >> 14) + 800
    frec = ((pressure & 0xf) * 1000) / 16
    return ((pressure >> 4) * 1000) + frec
  end
end

