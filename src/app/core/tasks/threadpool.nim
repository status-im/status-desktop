import # std libs
  atomics, json, sequtils, tables

import # vendor libs
  chronicles, chronos, json_serialization, task_runner

import # status-desktop libs
  ./common

export
  chronos, common, json_serialization

logScope:
  topics = "task-threadpool"

type
  ThreadPool* = ref object
    chanRecvFromPool: AsyncChannel[ThreadSafeString]
    chanSendToPool: AsyncChannel[ThreadSafeString]
    thread: Thread[PoolThreadArg]
    size: int
    running*: Atomic[bool]
  PoolThreadArg = object
    chanSendToMain: AsyncChannel[ThreadSafeString]
    chanRecvFromMain: AsyncChannel[ThreadSafeString]
    size: int
  TaskThreadArg = object
    id: int
    chanRecvFromPool: AsyncChannel[ThreadSafeString]
    chanSendToPool: AsyncChannel[ThreadSafeString]
  ThreadNotification = object
    id: int
    notice: string

# forward declarations
proc poolThread(arg: PoolThreadArg) {.thread.}

const MaxThreadPoolSize = 16

proc init(self: ThreadPool) =
  self.chanRecvFromPool.open()
  self.chanSendToPool.open()
  let arg = PoolThreadArg(
    chanSendToMain: self.chanRecvFromPool,
    chanRecvFromMain: self.chanSendToPool,
    size: self.size
  )
  createThread(self.thread, poolThread, arg)
  # block until we receive "ready"
  discard $(self.chanRecvFromPool.recvSync())

proc newThreadPool*(size: int = MaxThreadPoolSize): ThreadPool =
  new(result)
  result.chanRecvFromPool = newAsyncChannel[ThreadSafeString](-1)
  result.chanSendToPool = newAsyncChannel[ThreadSafeString](-1)
  result.thread = Thread[PoolThreadArg]()
  result.size = size
  result.running.store(false)
  result.init()

proc teardown*(self: ThreadPool) =
  self.running.store(false)
  self.chanSendToPool.sendSync("shutdown".safe)
  self.chanRecvFromPool.close()
  self.chanSendToPool.close()
  trace "[threadpool] waiting for the control thread to stop"
  joinThread(self.thread)

proc start*[T: TaskArg](self: Threadpool, arg: T) =
  self.chanSendToPool.sendSync(arg.encode.safe)
  self.running.store(true)

proc runner(arg: TaskThreadArg) {.async.} =
  arg.chanRecvFromPool.open()
  arg.chanSendToPool.open()

  let noticeToPool = ThreadNotification(id: arg.id, notice: "ready")
  trace "[threadpool task thread] sending 'ready'", threadid=arg.id
  await arg.chanSendToPool.send(noticeToPool.encode.safe)

  while true:
    trace "[threadpool task thread] waiting for message"
    let received = $(await arg.chanRecvFromPool.recv())

    if received == "shutdown":
      trace "[threadpool task thread] received 'shutdown'"
      break

    let
      parsed = parseJson(received)
      messageType = parsed{"$type"}.getStr
    debug "[threadpool task thread] initiating task", messageType=messageType,
      threadid=arg.id, task=received

    try:
      let task = cast[Task](parsed{"tptr"}.getInt)
      try:
        task(received)
      except Exception as e:
        error "[threadpool task thread] exception", error=e.msg
    except Exception as e:
      error "[threadpool task thread] unknown message", message=received

    let noticeToPool = ThreadNotification(id: arg.id, notice: "done")
    debug "[threadpool task thread] sending 'done' notice to pool",
      threadid=arg.id, task=received
    await arg.chanSendToPool.send(noticeToPool.encode.safe)

  arg.chanRecvFromPool.close()
  arg.chanSendToPool.close()

proc taskThread(arg: TaskThreadArg) {.thread.} =
  waitFor runner(arg)

proc pool(arg: PoolThreadArg) {.async.} =
  let
    chanSendToMain = arg.chanSendToMain
    chanRecvFromMainOrTask = arg.chanRecvFromMain
  var threadsBusy = newTable[int, tuple[thr: Thread[TaskThreadArg],
    chanSendToTask: AsyncChannel[ThreadSafeString]]]()
  var threadsIdle = newSeq[tuple[id: int, thr: Thread[TaskThreadArg],
    chanSendToTask: AsyncChannel[ThreadSafeString]]](arg.size)
  var taskQueue: seq[string] = @[] # FIFO queue
  var allReady = 0
  chanSendToMain.open()
  chanRecvFromMainOrTask.open()

  trace "[threadpool] sending 'ready' to main thread"
  await chanSendToMain.send("ready".safe)

  for i in 0..<arg.size:
    let id = i + 1
    let chanSendToTask = newAsyncChannel[ThreadSafeString](-1)
    chanSendToTask.open()
    trace "[threadpool] adding to threadsIdle", threadid=id
    threadsIdle[i].id = id
    createThread(
      threadsIdle[i].thr,
      taskThread,
      TaskThreadArg(id: id, chanRecvFromPool: chanSendToTask,
        chanSendToPool: chanRecvFromMainOrTask
      )
    )
    threadsIdle[i].chanSendToTask = chanSendToTask

  # when task received and number of busy threads == MaxThreadPoolSize,
  # then put the task in a queue

  # when task received and number of busy threads < MaxThreadPoolSize, pop
  # a thread from threadsIdle, track that thread in threadsBusy, and run
  # task in that thread

  # if "done" received from a thread, remove thread from threadsBusy, and
  # push thread into threadsIdle

  while true:
    trace "[threadpool] waiting for message"
    var task = $(await chanRecvFromMainOrTask.recv())

    if task == "shutdown":
      trace "[threadpool] sending 'shutdown' to all task threads"
      for tpl in threadsIdle:
        await tpl.chanSendToTask.send("shutdown".safe)
      for tpl in threadsBusy.values:
        await tpl.chanSendToTask.send("shutdown".safe)
      break

    let
      jsonNode = parseJson(task)
      messageType = jsonNode{"$type"}.getStr
    trace "[threadpool] determined message type", messageType=messageType

    case messageType
      of "ThreadNotification":
        try:
          let notification = decode[ThreadNotification](task)
          trace "[threadpool] received notification",
            notice=notification.notice, threadid=notification.id

          if notification.notice == "ready":
            trace "[threadpool] received 'ready' from a task thread"
            allReady = allReady + 1

          elif notification.notice == "done":
            let tpl = threadsBusy[notification.id]
            trace "[threadpool] adding to threadsIdle",
                newlength=(threadsIdle.len + 1)
            threadsIdle.add (notification.id, tpl.thr, tpl.chanSendToTask)
            trace "[threadpool] removing from threadsBusy",
              newlength=(threadsBusy.len - 1), threadid=notification.id
            threadsBusy.del notification.id

            if taskQueue.len > 0:
              trace "[threadpool] removing from taskQueue",
                newlength=(taskQueue.len - 1)
              task = taskQueue[0]
              taskQueue.delete 0, 0

              trace "[threadpool] removing from threadsIdle",
                newlength=(threadsIdle.len - 1)
              let tpl = threadsIdle[0]
              threadsIdle.delete 0, 0
              trace "[threadpool] adding to threadsBusy",
                newlength=(threadsBusy.len + 1), threadid=tpl.id
              threadsBusy.add tpl.id, (tpl.thr, tpl.chanSendToTask)
              await tpl.chanSendToTask.send(task.safe)

          else:
            error "[threadpool] unknown notification", notice=notification.notice
        except Exception as e:
          warn "[threadpool] unknown error in thread notification", message=task, error=e.msg

      else: # must be a request to do task work
        if allReady < arg.size or threadsBusy.len == arg.size:
          # add to queue
          trace "[threadpool] adding to taskQueue",
            newlength=(taskQueue.len + 1)
          taskQueue.add task

        # do we have available threads in the threadpool?
        elif threadsBusy.len < arg.size:
          # check if we have tasks waiting on queue
          if taskQueue.len > 0:
            # remove first element from the task queue
            trace "[threadpool] adding to taskQueue",
              newlength=(taskQueue.len + 1)
            taskQueue.add task
            trace "[threadpool] removing from taskQueue",
              newlength=(taskQueue.len - 1)
            task = taskQueue[0]
            taskQueue.delete 0, 0

          trace "[threadpool] removing from threadsIdle",
            newlength=(threadsIdle.len - 1)
          let tpl = threadsIdle[0]
          threadsIdle.delete 0, 0
          trace "[threadpool] adding to threadsBusy",
            newlength=(threadsBusy.len + 1), threadid=tpl.id
          threadsBusy.add tpl.id, (tpl.thr, tpl.chanSendToTask)
          await tpl.chanSendToTask.send(task.safe)

  var allTaskThreads = newSeq[tuple[id: int, thr: Thread[TaskThreadArg]]]()

  for tpl in threadsIdle:
    tpl.chanSendToTask.close()
    allTaskThreads.add (tpl.id, tpl.thr)
  for id, tpl in threadsBusy.pairs:
    tpl.chanSendToTask.close()
    allTaskThreads.add (id, tpl.thr)

  chanSendToMain.close()
  chanRecvFromMainOrTask.close()

  trace "[threadpool] waiting for all task threads to stop"
  for tpl in allTaskThreads:
    debug "[threadpool] join thread", threadid=tpl.id
    joinThread(tpl.thr)

proc poolThread(arg: PoolThreadArg) {.thread.} =
  waitFor pool(arg)
