#
# mruby on YABM script
#

class SI7021
  SIADDR = 0x40
  USEHOLD = true

  TRIG_T_MEASUREMENT_HM    = 0xE3  # command trig. temp meas. hold master
  TRIG_RH_MEASUREMENT_HM   = 0xE5  # command trig. humidity meas. hold master
  TRIG_T_MEASUREMENT_POLL  = 0xF3  # command trig. temp meas. no hold master
  TRIG_RH_MEASUREMENT_POLL = 0xF5  # command trig. humidity meas. no hold master
  USER_REG_W               = 0xE6  # command writing user register
  USER_REG_R               = 0xE7  # command reading user register
  SOFT_RESET               = 0xFE  # command soft reset

  def initialize(yabm)
    @y = yabm
  end

  def getRevition
    @y.i2cread(SIADDR, 1, [0x84, 0xb8])
  end

  def getSerialStr
    siarr = @y.i2cread(SIADDR, 8, [0xfa, 0x0f])
    siarr += @y.i2cread(SIADDR, 6, [0xfc, 0xc9])
    serial_number = ''
    values = [9, 8, 6, 4, 2, 0, 7, 8]
    values.each do |n|
      serial_number += siarr[n].to_s(16).rjust(2, '0')
    end
    serial_number
  end

  # not use
  #   def chkcrc dat
  #     crc8 = 0xff
  #     for i in 0..1 do
  #       crc8 = crc8 ^ dat[i]
  #       8.times {
  #         if crc8 & 0x80 == 0x80
  #           crc8 = crc8 << 1
  #           crc8 = crc8 ^ 0x31
  #         else
  #           crc8 = crc8 << 1
  #         end
  #       }
  #     end
  #     if (crc8 & 0xff) == dat[2]
  #       return true
  #     else
  #       return false
  #     end
  #   end

  def getCelsiusHundredths
    @y.msleep(1) while @y.i2cchk(SIADDR) == 0
    if USEHOLD
      siarr = @y.i2cread(SIADDR, 3, [TRIG_T_MEASUREMENT_HM])
    else
      @y.i2cwrite(SIADDR, [TRIG_T_MEASUREMENT_POLL])
      c = 0
      loop do
        @y.msleep(10)
        siarr = @y.i2cread(SIADDR, 3)
        break unless siarr.nil?

        c += 1
        if c == 1000
          siarr = [0, 0]
          break
        end
      end
    end
    tempcode = (siarr[0] << 8) | siarr[1]
    ((tempcode * 17_572) / 65_536) - 4685
  end

  def getHumidityPercent
    @y.msleep(1) while @y.i2cchk(SIADDR) == 0
    if USEHOLD
      siarr = @y.i2cread(SIADDR, 3, [TRIG_RH_MEASUREMENT_HM])
    else
      @y.i2cwrite(SIADDR, [TRIG_RH_MEASUREMENT_POLL])
      c = 0
      loop do
        @y.msleep(10)
        siarr = @y.i2cread(SIADDR, 3)
        break unless siarr.nil?

        c += 1
        if c == 1000
          siarr = [0, 0]
          break
        end
      end
    end
    rhcode = (siarr[0] << 8) | siarr[1]
    ((125 * rhcode) / 65_536) - 6
  end
end
