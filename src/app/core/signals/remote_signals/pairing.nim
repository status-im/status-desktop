import json, tables, chronicles
import base
import ../../../../app_service/service/accounts/dto/accounts
import ../../../../app_service/service/devices/dto/installation
import ../../../../app_service/service/devices/dto/local_pairing_event


type LocalPairingSignal* = ref object of Signal
  eventType*: EventType
  action*: Action
  error*: string
  accountData*: LocalPairingAccountData
  installation*: InstallationDto

proc fromEvent*(T: type LocalPairingSignal, event: JsonNode): LocalPairingSignal =
  result = LocalPairingSignal()
  let e = event["event"]
  if e.contains("type"):
    result.eventType = e["type"].getStr().parse()
  if e.contains("action"):
    result.action = e["action"].getInt().parse()
  if e.contains("error"):
    result.error = e["error"].getStr()
  debug "local pairing event", `type` = result.eventType, action = result.action, error = result.error, event = $event
  if not e.contains("data"):
    return
  case result.eventType:
    of EventReceivedAccount:
      result.accountData = e["data"].toLocalPairingAccountData()
    of EventReceivedInstallation:
      result.installation = e["data"].toInstallationDto()
    else:
      discard
