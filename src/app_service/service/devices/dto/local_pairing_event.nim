import json
include ../../../common/[json_utils]
import ../../../../app/core/eventemitter
import ../../accounts/dto/accounts
import installation

type
  EventType* {.pure.} = enum
    EventUnknown = -1,
    EventConnectionError = 0,
    EventConnectionSuccess = 1,
    EventTransferError = 2,
    EventTransferSuccess = 3,
    EventReceivedAccount = 4,
    EventReceivedInstallation = 5
    EventProcessSuccess = 6,
    EventProcessError = 7

type
  Action* {.pure.} = enum
    ActionUnknown = 0
    ActionConnect = 1,
    ActionPairingAccount = 2,
    ActionSyncDevice = 3,
    ActionPairingInstallation = 4,

type
  LocalPairingAccountData* = ref object
    account*: AccountDTO
    password*: string
    chatKey*: string
    keycardPairings*: string

type
  LocalPairingEventArgs* = ref object of Args
    eventType*: EventType
    action*: Action
    error*: string
    accountData*: LocalPairingAccountData
    installation*: InstallationDto

proc parse*(self: string): EventType =
  case self:
    of "connection-error":
      return EventConnectionError
    of "connection-success":
      return EventConnectionSuccess
    of "transfer-error":
      return EventTransferError
    of "transfer-success":
      return EventTransferSuccess
    of "process-success":
      return EventProcessSuccess
    of "process-error":
      return EventProcessError
    of "received-account":
      return EventReceivedAccount
    of "received-installation":
      return EventReceivedInstallation
    else:
      return EventUnknown

proc parse*(self: int): Action =
  case self:
    of 1:
      return ActionConnect
    of 2:
      return ActionPairingAccount
    of 3:
      return ActionSyncDevice
    of 4:
      return ActionPairingInstallation
    else:
      return ActionUnknown


proc toLocalPairingAccountData*(jsonObj: JsonNode): LocalPairingAccountData =
  result = LocalPairingAccountData()
  discard jsonObj.getProp("password", result.password)
  discard jsonObj.getProp("chatKey", result.chatKey)
  discard jsonObj.getProp("keycardPairings", result.keycardPairings)

  var accountObj: JsonNode
  if(jsonObj.getProp("account", accountObj)):
    result.account = toAccountDto(accountObj)
