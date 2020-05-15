import NimQml
import "../status/core" as status
import nodeView

type Node* = ref object
  nodeModel*: NodeView
  nodeVariant*: QVariant

var sendRPCMessage = proc (msg: string): string =
  echo "sending RPC message"
  status.callPrivateRPC(msg)

proc newNode*(): Node =
  result = Node()
  result.nodeModel = newNodeView(sendRPCMessage)
  result.nodeVariant = newQVariant(result.nodeModel)

proc delete*(self: Node) =
  delete self.nodeModel
  delete self.nodeVariant

proc init*(self: Node) =
  discard
