#
# mruby on YABM script
#

class ENS160
  ENS160ADDR = 0x53

  PART_ID = 0x00
  OPMODE = 0x10
  OPMODE_IDLE = 0x01
  OPMODE_STANDERD = 0x02
  TEMP_IN = 0x13
  RH_IN = 0x15
  DATA_STATUS = 0x20
  DATA_AQI = 0x21
  DATA_TVOC = 0x22
  DATA_ECO2 = 0x24

  def initialize(yabm)
    @y = yabm
    @y.i2cwrite(ENS160ADDR, [OPMODE, OPMODE_IDLE])
  end

  def id
    arr = @y.i2cread(ENS160ADDR, 2, [PART_ID])
    (arr[1] << 8) | arr[0]
  end

  def setTempRh(t, r)
    val = (((t * 100) + 27_315) * 64) / 100
    @y.i2cwrite(ENS160ADDR, [TEMP_IN, val & 0xff, val >> 8])
    @y.i2cwrite(ENS160ADDR,  [RH_IN,  val & 0xff, val >> 8])
  end

  def getData
    @y.i2cwrite(ENS160ADDR,  [OPMODE, OPMODE_STANDERD])
    @y.msleep 10_000 while @y.i2cread(ENS160ADDR, 1, [DATA_STATUS]) & 0x02 == 0
    aqi = @y.i2cread(ENS160ADDR, 1, [DATA_AQI])
    arr = @y.i2cread(ENS160ADDR, 2, [DATA_TVOC])
    tvoc = (arr[1] << 8) | arr[0]
    arr = @y.i2cread(ENS160ADDR, 2, [DATA_ECO2])
    eco2 = (arr[1] << 8) | arr[0]
    @y.i2cwrite(ENS160ADDR, [OPMODE,OPMODE_IDLE])
    [aqi, tvoc, eco2]
  end
end
