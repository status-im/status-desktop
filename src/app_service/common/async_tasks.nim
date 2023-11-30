#################################################
# Async timer
#################################################

type
  TimerTaskArg = ref object of QObjectTaskArg
    timeoutInMilliseconds: int
    reason: string

const timerTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[TimerTaskArg](argEncoded)
  sleep(arg.timeoutInMilliseconds)
  arg.finish(arg.reason)