type
  AsyncLoadDevicesTaskArg = ref object of QObjectTaskArg

const asyncLoadDevicesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadDevicesTaskArg](argEncoded)
  let response = status_installations.getOurInstallations()

  arg.finish(response)
