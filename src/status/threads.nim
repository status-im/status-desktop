import nimqml
import threadpool
import stew/faux_closures

export fauxClosure

template spawnAndSend*(view: untyped, signalName: string, exprBlock: untyped) =
  let viewPtr = cast[pointer](view.vptr)
  proc backgroundTask() {.fauxClosure.} =
    let data = exprBlock
    signal_handler(viewPtr, data, signalName)
  spawn backgroundTask()