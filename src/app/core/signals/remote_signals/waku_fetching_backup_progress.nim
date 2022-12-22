import json, tables
import base

type WakuFetchingBackupProgress* = object
  dataNumber*: int
  totalNumber*: int 

type WakuFetchingBackupProgressSignal* = ref object of Signal
  fetchingBackupProgress*: Table[string, WakuFetchingBackupProgress]

proc fromEvent*(T: type WakuFetchingBackupProgressSignal, event: JsonNode): WakuFetchingBackupProgressSignal =
  result = WakuFetchingBackupProgressSignal()
  result.fetchingBackupProgress = initTable[string, WakuFetchingBackupProgress]()

  if event["event"].hasKey("fetchingBackedUpDataProgress") and event["event"]{"fetchingBackedUpDataProgress"}.kind == JObject:
    for key in event["event"]["fetchingBackedUpDataProgress"].keys:
      let entity = event["event"]["fetchingBackedUpDataProgress"][key]
      var details = WakuFetchingBackupProgress()
      if entity{"dataNumber"} != nil:
        details.dataNumber = entity["dataNumber"].getInt()
      if entity{"totalNumber"} != nil:
        details.totalNumber = entity["totalNumber"].getInt()
      result.fetchingBackupProgress[key] = details