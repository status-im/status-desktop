import NimQml
import ../../status/node
import ../../status/status
import threadpool
import os

QtObject:
  type NodeView* = ref object of QObject
    status*: Status
    callResult: string
    lastMessage*: string

  proc setup(self: NodeView) =
    self.QObject.setup

  proc newNodeView*(status: Status): NodeView =
    new(result)
    result.status = status
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


  proc getPrice*(self: pointer) =
    sleep(5000)    
    signal_handler(self, "100 USD", "mySlot")

  proc onSend*(self: NodeView, inputJSON: string) {.slot.} =
    echo "OnSend:::::::::::::::::::::::::::::::::::"
    var this = cast[pointer](self.vptr)
    echo "before:::::::::::::::::::::::::::::::::::"
    spawn getPrice(this)
    echo "after::::::::::::::::::::::::::::::::::::"

  proc mySlot(self: NodeView, x: string) {.slot.} =
    echo "RECEIVED DATA::::::::::::::::::::::::::::"
    echo x
    echo ".........................................."


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
