unless process.env.ENOCEAN_DEV
  console.log "ENOCEAN_DEV is not set"
  process.exit 1

serialport = require "serialport"
Bacon = require "baconjs"
enocean = require "./enocean"

serialConfig = { baudrate: 57600, parser: serialport.parsers.raw }
serial = new serialport.SerialPort process.env.ENOCEAN_DEV, serialConfig, true

enoceanBuffers = Bacon.fromBinder (sink) ->
  serial.on "data", sink
  serial.on "close", -> sink new Bacon.End()
  serial.on "error", (err) -> sink new Bacon.Error(err)
  ( -> )

buttonEvents = enoceanBuffers
  .filter enocean.bufferStartsWithStartByte
  .flatMap (buffer) -> enoceanBuffers.startWith(buffer).bufferWithTime(100).take(1)
  .map Buffer.concat
  .filter enocean.bufferHasValidLength
  .filter enocean.bufferCanBeInterpretedAsButtonEvent
  .map enocean.parseBufferAsButtonEvent

buttonEvents.log()
