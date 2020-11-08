import
  json, os, chronicles, threadpool, macros, tables

import
  nimqml, eventemitter, uuids, json_serialization,
  json_serialization/std/tables as json_tables

import
  status/libstatus/[types, stickers]

logScope:
  topics = "task-runner"

type
  Task* = object
    uuid*: string
    routine*: string
  
  TaskCompletedArgs* = ref object of Args
    uuid*: string
    result*: string

var taskRunnerVPTR: pointer
var taskChan: Channel[Task]
open(taskChan)

proc notifyUI(uuid: string, result: string) =
  signal_handler(taskRunnerVPTR, $(%* {"uuid": uuid, "result": result}), "receiveTaskResult")

template run(task: Task, routine: untyped) =
  echo "Executing task ", task.uuid
  let uuid = task.uuid

  let bgTask = proc (uuid: string) =
    let data = routine()
    echo "BOOM! I'm done with ", uuid
    notifyUI(uuid, Json.encode(data))
  spawn bgTask(uuid)


proc myMethod(): string =
  # This is just a test method to simulate something that takes a long time to run
  sleep(4000)
  return "some string that took ages to retrieve"

proc process*() {.thread.} =
  while true:
    let recv = taskChan.tryRecv()
    if recv.dataAvailable:
      let task = recv.msg

      case task.routine
      of "myMethod": task.run(myMethod)
      of "getAvailableStickerPacks": task.run(getAvailableStickerPacks)
      of "stop": break
      else: error "Unknown task"
                      
  sleep(400)

QtObject:
  type
    TaskRunner* = ref object of QObject
      taskRunnerThread*: Thread[void]
      events*: EventEmitter

  proc setup(self: TaskRunner) = self.QObject.setup

  proc delete*(self: TaskRunner) = self.QObject.delete

  proc newTaskRunner*(): TaskRunner =
    new(result, delete)
    result = TaskRunner()
    result.events = createEventEmitter()
    result.setup()
    taskRunnerVPTR = cast[pointer](result.vptr)

  proc taskCompleted*(self: TaskRunner, uuid: string, result: string) {.signal.} 

  proc receiveTaskResult*(self: TaskRunner, result: string) {.slot.} =
    let args = Json.decode(result, TaskCompletedArgs)
    self.taskCompleted(args.uuid, args.result)
    self.events.emit("taskCompleted", args)

  proc init*(self: TaskRunner) =
    debug "Creating task runner thread..."
    self.taskRunnerThread.createThread(process)

  proc destroy*(self: TaskRunner) =
    debug "Closing task runner thread..."
    taskChan.send(Task(routine: "stop"))
    joinThreads(self.taskRunnerThread)
    taskChan.close()
    self.delete()

  proc send*(self: TaskRunner, task: var Task): string =
    if task.uuid == "":
      task.uuid = $genUUID()
    taskChan.send(task)
    task.uuid
