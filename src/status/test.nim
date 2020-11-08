import # global deps
  tables, strutils, json

import # project deps
  chronicles, web3/[ethtypes, conversions], eventemitter, stint,
  json_serialization, json_serialization/std/tables as json_tables

import # local deps
  libstatus/types, ../task_runner


logScope:
  topics = "test-model"

type
    TestModel* = ref object
      taskRunner*: TaskRunner
      events*: EventEmitter
      testData*: Table[int, StickerPack]

proc newTestModel*(events: EventEmitter, taskRunner: TaskRunner): TestModel =
  result = TestModel()
  result.taskRunner = taskRunner
  result.events = events
  result.testData = initTable[int, StickerPack]()

proc getAvailableStickerPacks*(self: TestModel): string =
  var task = Task(routine: "getAvailableStickerPacks")
  let uuid = self.taskRunner.send(task)
  result = uuid
  self.taskRunner.events.on("taskCompleted") do(e: Args):
    var args = TaskCompletedArgs(e)
    if uuid != args.uuid:
      return
    # store data in model
    self.testData = Json.decode(args.result, Table[int, StickerPack])
    self.events.emit("getAvailableStickerPacksCompleted", nil)

proc addStickerPack*(self: TestModel, pack: StickerPack) =
  self.testData.add pack.id, pack
  

