import json, tables
import base
import ../../../../app_service/service/accounts/dto/accounts



type LocalPairingSignal* = ref object of Signal
  eventType*: string
  action*: int
  error*: string
  account*: AccountDto

proc fromEvent*(T: type LocalPairingSignal, event: JsonNode): LocalPairingSignal =
  result = LocalPairingSignal()
  let e = event["event"]
  if e.contains("type"):
    result.eventType = e["type"].getStr
  if e.contains("action"):
    result.action = e["action"].getInt
  if e.contains("error"):
    result.error = e["error"].getStr
  if e.contains("data"):
    result.account = e["data"].toAccountDto()
