#
# rtlbm-mruby mruby script
#

class BH1750
  BHADDR = 0x23
  @mtreg = 69

  # Measurement at 1 lux resolution. Measurement time is approx 120ms.
  CONTINUOUS_HIGH_RES_MODE = 0x10
  # Measurement at 0.5 lux resolution. Measurement time is approx 120ms.
  CONTINUOUS_HIGH_RES_MODE_2 = 0x11
  # Measurement at 4 lux resolution. Measurement time is approx 16ms.
  CONTINUOUS_LOW_RES_MODE = 0x13
  # Measurement at 1 lux resolution. Measurement time is approx 120ms.
  ONE_TIME_HIGH_RES_MODE = 0x20
  # Measurement at 0.5 lux resolution. Measurement time is approx 120ms.
  ONE_TIME_HIGH_RES_MODE_2 = 0x21
  # Measurement at 4 lux resolution. Measurement time is approx 16ms.
  ONE_TIME_LOW_RES_MODE = 0x23

  def initialize(yabm)
    @y = yabm
    @addr = BHADDR
  end

  def setMTreg(mtreg)
    @mtreg = mtreg
    @y.i2cwrite(@addr, [0x40 | (@mtreg >> 5)])
    @y.msleep(200)
    @y.i2cwrite(@addr, [0x60 | (@mtreg & 0x1f)])
    @y.msleep(200)
  end

  def setMeasurement(mode)
    @meas = mode
    if @meas == CONTINUOUS_HIGH_RES_MODE ||
       @meas == CONTINUOUS_HIGH_RES_MODE_2 ||
       @meas == CONTINUOUS_LOW_RES_MODE
      @y.i2cwrite(@addr, [@meas])
    end
  end

  def getLightLevel
    if @meas == ONE_TIME_HIGH_RES_MODE ||
       @meas == ONE_TIME_HIGH_RES_MODE_2
      @y.i2cwrite(@addr, [@meas])
      @y.msleep(120 * @mtreg / 69)
    elsif @meas == ONE_TIME_LOW_RES_MODE
      @y.i2cwrite(@addr, [@meas])
      @y.msleep(16 * @mtreg / 69)
    end
    bharr = @y.i2cread(@addr, 2)
    val = (bharr[0] << 8) | bharr[1]
    if @meas == CONTINUOUS_HIGH_RES_MODE_2 ||
       @meas == ONE_TIME_HIGH_RES_MODE_2
      val * 50 * 69 * 5 / (6 * @mtreg)
    else
      val * 100 * 69 * 5 / (6 * @mtreg)
    end
  end
end
