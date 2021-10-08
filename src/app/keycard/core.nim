import NimQml, chronicles, std/wrapnils
import status/[signals, status, keycard]
import status/types/[account, rpc_response]
import types/keycard as keycardtypes
import view

logScope:
  topics = "keycard-model"

type KeycardController* = ref object
  view*: KeycardView
  variant*: QVariant
  status: Status

proc newController*(status: Status): KeycardController =
  result = KeycardController()
  result.status = status
  result.view = newKeycardView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: KeycardController) =
  delete self.variant
  delete self.view

proc reset*(self: KeycardController) =
  self.view.reset()

proc handleNodeLogin(self: KeycardController, response: NodeSignal) =
  if self.view.newAccount != nil:
    if ?.response.event.error == "":
      self.status.events.emit("login", AccountArgs(account: self.view.newAccount))

proc init*(self: KeycardController) =
  self.status.events.on(SignalType.KeycardConnected.event) do(e:Args):
    self.view.getCardState()
    self.view.cardConnected()
  self.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    self.handleNodeLogin(NodeSignal(e))