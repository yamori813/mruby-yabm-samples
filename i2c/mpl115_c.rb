#
# bcmbm-mruby mruby script
#

class MPL115
  MPLADDR = 0x60

  def initialize(yabm)
    @y = yabm
    @y.msleep(1) while @y.i2cchk(MPLADDR) == 0
    @a0 = (@y.i2cread(MPLADDR, 1, 0x04) << 8) | @y.i2cread(MPLADDR, 1, 0x05)
    @b1 = (@y.i2cread(MPLADDR, 1, 0x06) << 8) | @y.i2cread(MPLADDR, 1, 0x07)
    @b2 = (@y.i2cread(MPLADDR, 1, 0x08) << 8) | @y.i2cread(MPLADDR, 1, 0x09)
    @c12 = (@y.i2cread(MPLADDR, 1, 0x0a) << 8) | @y.i2cread(MPLADDR, 1, 0x0b)
  end

  # This calculate code is based c source code in NXP AN3785 document

  def calculatePCompLong(padc, tadc, a0, b1, b2, c12)
    a0 -= 0x10000 if a0 >= 0x8000
    b1 -= 0x10000 if b1 >= 0x8000
    b2 -= 0x10000 if b2 >= 0x8000
    c12 -= 0x10000 if c12 >= 0x8000
    padc >>= 6
    tadc >>= 6
    # ******* STEP 1 : c12x2 = c12 * Tadc
    lt1 = c12
    lt2 = tadc
    lt3 = lt1 * lt2
    c12x2 = lt3 >> 11
    # ******* STEP 2 : a1 = b1 + c12x2
    lt1 = b1
    lt2 = c12x2
    lt3 = lt1 + lt2
    a1 = lt3
    # ******* STEP 3 : a1x1 = a1 * Padc
    lt1 = a1
    lt2 = padc
    lt3 = lt1 * lt2
    a1x1 = lt3
    # ******* STEP 4 : y1 = a0 + a1x1
    lt1 = a0 << 10
    lt2 = a1x1
    lt3 = lt1 + lt2
    y1 = lt3
    # ******* STEP 5 : a2x2 = b2 * Tadc
    lt1 = b2
    lt2 = tadc
    lt3 = lt1 * lt2
    a2x2 = lt3 >> 1
    # ******* STEP 6 : PComp = y1 + a2x2
    lt1 = y1
    lt2 = a2x2
    lt3 = lt1 + lt2
    lt3 >> 9
  end

  def calculatePCompShort(padc, tadc, a0, b1, b2, c12)
    a0 -= 0x10000 if a0 >= 0x8000
    b1 -= 0x10000 if b1 >= 0x8000
    b2 -= 0x10000 if b2 >= 0x8000
    c12 -= 0x10000 if c12 >= 0x8000
    padc >>= 6
    tadc >>= 6
    c12x2 = (c12 * tadc) >> 11
    a1 = b1 + c12x2
    a1x1 = a1 * padc
    y1 = (a0 << 10) + a1x1
    a2x2 = (b2 * tadc) >> 1
    (y1 + a2x2) >> 9
  end

  def readPressure
    @y.msleep(1) while @y.i2cchk(MPLADDR) == 0
    @y.i2cwrite(MPLADDR, 0x12, 0x01)
    @y.msleep(10)
    padc = (@y.i2cread(MPLADDR, 1, 0x00) << 8) | @y.i2cread(MPLADDR, 1, 0x01)
    tadc = (@y.i2cread(MPLADDR, 1, 0x02) << 8) | @y.i2cread(MPLADDR, 1, 0x03)

    pcomp = calculatePCompShort(padc, tadc, @a0, @b1, @b2, @c12)
    pressure = ((pcomp * 1041) >> 14) + 800
    frec = ((pressure & 0xf) * 1000) / 16
    ((pressure >> 4) * 1000) + frec
  end
end
