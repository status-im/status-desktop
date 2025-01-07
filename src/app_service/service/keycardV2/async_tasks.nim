type
  AsyncSetPinTaskArg = ref object of QObjectTaskArg
    pin: string

proc asyncSetPinTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSetPinTaskArg](argEncoded)
  try:
    # TODO Call function from keycard_go
    echo "Set pin ", arg.pin
    arg.finish(%*{
      "error": ""
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })
