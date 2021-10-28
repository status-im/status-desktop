import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewWhitelist*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method changePassword*(self: ServiceInterface, address: string, password: string, newPassword: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method readTextFile*(self: ServiceInterface, path: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method writeTextFile*(self: ServiceInterface, path: string, content: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")
