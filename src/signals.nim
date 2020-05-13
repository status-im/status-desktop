import libstatus

var onSignal*: SignalCallback = proc(p0: cstring): void =
  setupForeignThreadGc()
  # TODO: Dispatch depending on message type $jsonSignal["type"].getStr
  # Consider also have an intermediate object with an enum for type
  # So you do not have to deal with json objects but with a nim type
  echo $p0
  tearDownForeignThreadGc()
