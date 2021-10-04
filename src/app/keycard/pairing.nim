import json, os
import types/keycard

import ../../constants

let PAIRINGSTORE = joinPath(DATADIR, "keycard-pairings.json")

type KeycardPairingController* = ref object
  store: JsonNode

proc newPairingController*(): KeycardPairingController =
  result = KeycardPairingController()
  if fileExists(PAIRINGSTORE):
    result.store = parseJSON(readFile(PAIRINGSTORE))
  else:
    result.store = %*{}

proc save(self: KeycardPairingController) =
  writeFile(PAIRINGSTORE, $self.store)

proc addPairing*(self: KeycardPairingController, instanceUID: string, pairing: KeycardPairingInfo) =
  self.store[instanceUID] = %* pairing
  self.save()

proc removePairing*(self: KeycardPairingController, instanceUID: string) =
  self.store.delete(instanceUID)
  self.save()

proc getPairing*(self: KeycardPairingController, instanceUID: string): KeycardPairingInfo =
  let node = self.store{instanceUID}
  if node != nil:
    result = to(node, KeycardPairingInfo)
