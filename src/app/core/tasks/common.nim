import json_serialization
from eth/common/eth_types_json_serialization import writeValue, readValue

export writeValue, readValue

export json_serialization

type
  Task* = proc(arg: string): void {.gcsafe, nimcall.}
  TaskArg* = ref object of RootObj
    tptr* {.dontSerialize.}: Task # Only used during task creation (don't access in tasks)

proc decode*[T](arg: string): T =
  Json.decode(arg, T, allowUnknownFields = true)

proc encode*[T](arg: T): string =
  arg.toJson(typeAnnotations = true)
