#
# mruby on YABM script
#

class AHT21
  AHT21ADDR = 0x38

  AHT21_INIT_COMMAND = [0x71]
  AHT21_READ_COMMAND = [0xAC, 0x33, 0x00]

  def initialize(yabm)
    @y = yabm
    @y.i2cwrite(AHT21ADDR, AHT21_INIT_COMMAND)
    @y.msleep 100
  end

  def sensorRead
    @y.i2cwrite(AHT21ADDR, AHT21_READ_COMMAND)
    @y.msleep 80
    arr = @y.i2cread(AHT21ADDR, 7)
    humidity = (arr[1] << 12) | (arr[2] << 4) | (arr[3] >> 4)
    humidity *= 100
    humidity /= 0x100000
    temperature = ((arr[3] & 0xf) << 16) | (arr[4] << 8) | arr[5]
    temperature *= 200
    temperature /= 0x100000
    temperature -= 50
    [temperature, humidity]
  end
end
