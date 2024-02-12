import # std libs
  std/cpuinfo

import # vendor libs
  json_serialization, json, chronicles, taskpools

import # status-desktop libs
  ./common

export common, json_serialization, taskpools

logScope:
  topics = "task-threadpool"

type
  ThreadPool* = ref object
    pool: Taskpool
  ThreadSafeTaskArg* = distinct cstring

proc safe*[T: TaskArg](taskArg: T): ThreadSafeTaskArg =
  var
    strArgs = taskArg.encode()
    res = cast[cstring](allocShared(strArgs.len + 1))

  copyMem(res, strArgs.cstring, strArgs.len)
  res[strArgs.len] = '\0'
  res.ThreadSafeTaskArg

proc toString*(input: ThreadSafeTaskArg): string =
  result = $(input.cstring)
  deallocShared input.cstring

proc teardown*(self: ThreadPool) =
  self.pool.shutdown()

proc newThreadPool*(): ThreadPool =
  new(result)
  var nthreads = countProcessors()
  result.pool = Taskpool.new(num_threads = nthreads)

proc runTask(safeTaskArg: ThreadSafeTaskArg) {.gcsafe, nimcall.} =
  let taskArg = safeTaskArg.toString()
  var parsed: JsonNode

  try:
    parsed = parseJson(taskArg)
  except CatchableError as e:
    error "[threadpool task thread] parsing task arg", error=e.msg
    return

  let messageType = parsed{"$type"}.getStr

  debug "[threadpool task thread] initiating task", messageType=messageType,
    threadid=getThreadId(), task=taskArg

  try:
    let task = cast[Task](parsed{"tptr"}.getInt)
    try:
      task(taskArg)
    except CatchableError as e:
      error "[threadpool task thread] exception", error=e.msg
  except CatchableError as e:
    error "[threadpool task thread] unknown message", message=taskArg

proc start*[T: TaskArg](self: ThreadPool, arg: T) =
  self.pool.spawn runTask(arg.safe())