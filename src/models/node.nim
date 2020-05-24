import eventemitter
# import json
# import strformat
# import strutils
import "../status/core" as status

type NodeModel* = ref object
  events*: EventEmitter

proc newNodeModel*(events: EventEmitter): NodeModel =
  result = NodeModel()
  result.events = events

proc delete*(self: NodeModel) =
  discard

proc sendRPCMessageRaw*(self: NodeModel, msg: string): string =
  echo "sending RPC message"
  status.callPrivateRPCRaw(msg)
