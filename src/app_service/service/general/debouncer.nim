import nimqml, os

import app/core/tasks/[qt, threadpool]


include app_service/common/async_tasks

QtObject:
  type Debouncer* = ref object of QObject
    threadpool: ThreadPool
    callback: proc()
    delay: int
    checkInterval: int
    remaining: int


  proc delete*(self: Debouncer)
  proc newDebouncer*(threadpool: ThreadPool, delayMs: int, checkIntervalMs: int, callback: proc()): Debouncer =
    new(result, delete)
    result.QObject.setup
    if checkIntervalMs > delayMs:
      raise newException(ValueError, "checkIntervalMs must be less than delayMs")
    result.threadpool = threadpool
    result.callback = callback
    result.delay = delayMs
    result.checkInterval = checkIntervalMs

  proc runTimer*(self: Debouncer) =
    let arg = TimerTaskArg(
      tptr: timerTask,
      vptr: cast[uint](self.vptr),
      slot: "onTimeout",
      timeoutInMilliseconds: self.checkInterval
    )
    self.threadpool.start(arg)

  proc onTimeout(self: Debouncer, response: string) {.slot.} =
    self.remaining = self.remaining - self.checkInterval
    if self.remaining <= 0:
      self.callback()
    else:
      self.runTimer()

  proc call*(self: Debouncer) =
    let busy = self.remaining > 0
    if busy:
      return

    self.remaining = self.delay
    self.runTimer()

  proc delete*(self: Debouncer) =
    self.QObject.delete