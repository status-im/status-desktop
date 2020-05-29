import NimQml
import ../../status/node

QtObject:
  type NodeView* = ref object of QObject
    model: NodeModel
    callResult: string
    lastMessage*: string

  proc setup(self: NodeView) =
    self.QObject.setup

  proc newNodeView*(model: NodeModel): NodeView =
    new(result)
    result.model = model
    result.callResult = "Use this tool to call JSONRPC methods"
    result.lastMessage = ""
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
    self.setCallResult(self.model.sendRPCMessageRaw(inputJSON))
    echo "Done!: ", self.callResult

  proc onMessage*(self: NodeView, message: string) {.slot.} =
    self.setCallResult(message)
    echo "Received message: ", message

  proc lastMessage*(self: NodeView): string {.slot.} =
    result = self.lastMessage

  proc receivedMessage*(self: NodeView, lastMessage: string) {.signal.}

  proc setLastMessage*(self: NodeView, lastMessage: string) {.slot.} =
    self.lastMessage = lastMessage
    self.receivedMessage(lastMessage)

  QtProperty[string] lastMessage:
    read = lastMessage
    write = setLastMessage
    notify = receivedMessage
