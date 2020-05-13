import types
import json

var onSignal*: SignalCallback = proc(p0: cstring): void =
  setupForeignThreadGc()
  # TODO: Dispatch depending on message type $jsonSignal["type"].getStr
  # Consider also have an intermediate object with an enum for type
  # So you do not have to deal with json objects but with a nim type

  let jsonSignal = ($p0).parseJson
  let messageType = $jsonSignal["type"].getStr 

  case messageType:
    of "messages.new":
      echo $p0
    else:
      discard messageType  #TODO: do something

  tearDownForeignThreadGc()
