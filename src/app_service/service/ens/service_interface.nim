import options

type
  ENSType* {.pure.} = enum
    IPFS,
    SWARM,
    IPNS,
    UNKNOWN

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method resourceUrl*(self: ServiceInterface, username: string): (string, string, string) {.base.} =
  raise newException(ValueError, "No implementation available")
