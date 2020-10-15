import json, os, chronicles, threadpool
import status/status
import nimqml
import uuids, asyncdispatch

logScope:
  topics = "task-runner"


var taskRunnerVPTR: pointer

var taskChan: Channel[string]
open(taskChan)

proc notifyUI(uuid: string, result: JsonNode) =
  signal_handler(taskRunnerVPTR, $(%* {"uuid": uuid, "response": result}), "receiveTaskResult")


proc myMethod(task:JsonNode) =
  # This is just a test method to simulate something that takes a long time to run
  echo "Executing 'myMethod'. UUID ", task["uuid"].getStr()
  task["result"] = newJString("DONE")
  sleep(4000)
  echo "BOOM! I'm done with ", task["uuid"].getStr()
  notifyUI(task["uuid"].getStr(), %* {"result": "Something"})


proc process*() {.thread.} =
  while true:
    let recv = taskChan.tryRecv()
    if recv.dataAvailable:
      let task = recv.msg.parseJSON
      case task["method"].getStr()
      of "myMethod": spawn myMethod(task)
      of "stop": break
      else: error "Unknown task"
                      
  sleep(400)


QtObject:
  type
    TaskRunner* = ref object of QObject
      taskRunnerThread*: Thread[void]


  proc setup(self: TaskRunner) = self.QObject.setup

  proc delete*(self: TaskRunner) = self.QObject.delete

  proc newTaskRunner*(): TaskRunner =
    new(result, delete)
    result = TaskRunner()
    result.setup()
    taskRunnerVPTR = cast[pointer](result.vptr)

  proc taskCompleted*(self: TaskRunner, uuid: string, result: string) {.signal.} 

  proc receiveTaskResult*(self: TaskRunner, result: string) {.slot.} =
    let jsonObj = result.parseJSON
    self.taskCompleted(jsonObj["uuid"].getStr, $jsonObj["response"])

  proc init*(self: TaskRunner) =
    debug "Creating task runner thread..."
    self.taskRunnerThread.createThread(process)

  proc destroy*(self: TaskRunner) =
    debug "Closing task runner thread..."
    taskChan.send($ %*{"method": "stop"})
    joinThreads(self.taskRunnerThread)
    self.delete()

  proc send*(self: TaskRunner, input: JsonNode):string =
    result = $genUUID()
    input["uuid"] = newJString(result)
    taskChan.send($input)


