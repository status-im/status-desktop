import # vendor libs
  json_serialization, NimQml, task_runner

type
  Task* = proc(arg: string): void {.gcsafe, nimcall.}
  TaskArg* = ref object of RootObj
    tptr*: ByteAddress

proc decode*[T](arg: string): T =
  Json.decode(arg, T, allowUnknownFields = true)

proc encode*[T](arg: T): string =
  arg.toJson(typeAnnotations = true)
