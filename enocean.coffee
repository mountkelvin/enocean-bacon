RORG_RPS_TELEGRAM = 0xF6

eventByteMapping = {}
eventByteMapping[0x50] = "1"
eventByteMapping[0x10] = "2"
eventByteMapping[0x70] = "3"
eventByteMapping[0x30] = "4"
eventByteMapping[0x15] = "12"
eventByteMapping[0x37] = "34"
eventByteMapping[0x35] = "14"
eventByteMapping[0x17] = "23"

bufferDataLength = (buffer) ->
  buffer[1] * 0xff + buffer[2]

bufferOptionalDataLength = (buffer) ->
  buffer[3]

bufferStartsWithStartByte = (buffer) ->
  buffer[0] == 0x55

bufferHasValidLength = (buffer) ->
  enoceanHeaderLength = 6
  totalLength = enoceanHeaderLength + (bufferDataLength buffer) + (bufferOptionalDataLength buffer) + 1
  buffer.length == totalLength

bufferData = (buffer) ->
  dataLength = bufferDataLength buffer
  buffer.slice 6, 6 + dataLength

bufferCanBeInterpretedAsButtonEvent = (buffer) ->
  data = bufferData buffer
  data[0] == RORG_RPS_TELEGRAM && bufferDataLength(buffer) == 7 && bufferOptionalDataLength(buffer) == 7

parseBufferAsButtonEvent = (buffer) ->
  data = bufferData buffer
  enoceanAddressBuffer = data.slice 2, 6
  eventByte = data[1]
  enoceanAddress = enoceanAddressBuffer.toString("hex")
  key = eventByteMapping[eventByte]
  event = if key? then "keydown" else "keyup"
  { enoceanAddress, event, key }

exports.bufferStartsWithStartByte = bufferStartsWithStartByte
exports.bufferHasValidLength = bufferHasValidLength
exports.bufferCanBeInterpretedAsButtonEvent = bufferCanBeInterpretedAsButtonEvent
exports.parseBufferAsButtonEvent = parseBufferAsButtonEvent