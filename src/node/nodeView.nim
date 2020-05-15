import NimQml

QtObject:
  type NodeView* = ref object of QObject
    callResult: string
    sendRPCMessage: proc (msg: string):  string

  proc setup(self: NodeView) =
    self.QObject.setup

  proc newNodeView*(sendRPCMessage: proc): NodeView =
    new(result)
    result.sendRPCMessage = sendRPCMessage
    result.callResult = "Use this tool to call JSONRPC methods"
    result.setup

  proc delete*(self: NodeView) =
    self.QObject.delete

  proc callResult*(self: NodeView): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: NodeView, callResult: string) {.signal.}

  proc setCallResult(self: NodeView, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: NodeView, callResult: string) = self.setCallResult(callResult)

  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: NodeView, inputJSON: string) {.slot.} =
    self.setCallResult(self.sendRPCMessage(inputJSON))
    echo "Done!: ", self.callResult

  proc onMessage*(self: NodeView, message: string) {.slot.} =
    self.setCallResult(message)
    echo "Received message: ", message
