import # vendor libs
  chronicles, task_runner

import # status-desktop libs
  ./marathon, ./threadpool

export marathon, task_runner, threadpool

logScope:
  topics = "task-runner"

type
  TaskRunner* = ref object
    threadpool*: ThreadPool
    marathon*: Marathon

proc newTaskRunner*(): TaskRunner =
  new(result)
  result.threadpool = newThreadPool()
  result.marathon = newMarathon()

proc init*(self: TaskRunner) =
  self.threadpool.init()
  self.marathon.init()

proc teardown*(self: TaskRunner) =
  self.threadpool.teardown()
  self.marathon.teardown()
