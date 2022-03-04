method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method addPermission*(self: AccessInterface, hostname: string, address: string, permission: string) =
  raise newException(ValueError, "No implementation available")