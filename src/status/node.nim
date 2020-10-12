import libstatus/core as status
import ../eventemitter

type NodeModel* = ref object
  events*: EventEmitter

proc newNodeModel*(): NodeModel =
  result = NodeModel()
  result.events = createEventEmitter()

proc delete*(self: NodeModel) =
  discard

proc sendRPCMessageRaw*(self: NodeModel, msg: string): string =
  echo "sending RPC message"
  status.callPrivateRPCRaw(msg)
