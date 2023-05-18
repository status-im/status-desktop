import json, tables
import base

type WakuFetchingBackupProgress* = object
  dataNumber*: int
  totalNumber*: int 

type WakuFetchingBackupProgressSignal* = ref object of Signal
  clock*: uint64
  fetchingBackupProgress*: Table[string, WakuFetchingBackupProgress]

proc fromEvent*(T: type WakuFetchingBackupProgressSignal, event: JsonNode): WakuFetchingBackupProgressSignal =
  result = WakuFetchingBackupProgressSignal()
  result.fetchingBackupProgress = initTable[string, WakuFetchingBackupProgress]()

  let e = event["event"]
  if e.contains("clock"):
    result.clock = uint64(e["clock"].getBiggestInt)
  if e.contains("fetchingBackedUpDataProgress") and e["fetchingBackedUpDataProgress"].kind == JObject:
    for key in e["fetchingBackedUpDataProgress"].keys:
      let entity = e["fetchingBackedUpDataProgress"][key]
      var details = WakuFetchingBackupProgress()
      if entity{"dataNumber"} != nil:
        details.dataNumber = entity["dataNumber"].getInt()
      if entity{"totalNumber"} != nil:
        details.totalNumber = entity["totalNumber"].getInt()
      result.fetchingBackupProgress[key] = details