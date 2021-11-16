import # std libs
  json

import # vendor libs
  chronicles, chronos, json_serialization, task_runner

import # status-desktop libs
  ../common

export
  chronos, common, json_serialization

logScope:
  topics = "task-marathon-worker"

type
  WorkerThreadArg* = object # of RootObj
    chanSendToMain*: AsyncChannel[ThreadSafeString]
    chanRecvFromMain*: AsyncChannel[ThreadSafeString]
    vptr*: ByteAddress
  MarathonWorker* = ref object of RootObj
    chanSendToWorker*: AsyncChannel[ThreadSafeString]
    chanRecvFromWorker*: AsyncChannel[ThreadSafeString]
    thread*: Thread[WorkerThreadArg]
    vptr*: ByteAddress

method name*(self: MarathonWorker): string {.base.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")

method init*(self: MarathonWorker) {.base.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")

method teardown*(self: MarathonWorker) {.base.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")

method onLoggedIn*(self: MarathonWorker) {.base.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")

method worker(arg: WorkerThreadArg) {.async, base, gcsafe, nimcall.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")

method workerThread(arg: WorkerThreadArg) {.thread, base, gcsafe, nimcall.} =
  # override this base method
  raise newException(CatchableError, "Method without implementation override")