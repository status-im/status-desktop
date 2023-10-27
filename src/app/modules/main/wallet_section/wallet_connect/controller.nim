import NimQml, logging, json

import backend/wallet_connect as backend

import app/core/eventemitter
import app/core/signals/types

import constants

QtObject:
  type
    Controller* = ref object of QObject
      events: EventEmitter

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc newController*(events: EventEmitter): Controller =
    new(result, delete)

    result.events = events

    result.setup()

    # Register for wallet events
    result.events.on(SignalType.Wallet.event, proc(e: Args) =
      # TODO #12434: async processing
      discard
    )

  # supportedNamespaces is a Namespace as defined in status-go: services/wallet/walletconnect/walletconnect.go
  proc proposeUserPair*(self: Controller, sessionProposalJson: string, supportedNamespacesJson: string) {.signal.}

  proc pairSessionProposal(self: Controller, sessionProposalJson: string) {.slot.} =
    let ok = backend.pair(sessionProposalJson, proc (res: JsonNode) =
      let sessionProposalJson = if res.hasKey("sessionProposal"): $res["sessionProposal"] else: ""
      let supportedNamespacesJson = if res.hasKey("supportedNamespaces"): $res["supportedNamespaces"] else: ""

      self.proposeUserPair(sessionProposalJson, supportedNamespacesJson)
    )

    if not ok:
      error "Failed to pair session"

  proc getProjectId*(self: Controller): string {.slot.} =
    return constants.WALLET_CONNECT_PROJECT_ID

  QtProperty[string] projectId:
    read = getProjectId