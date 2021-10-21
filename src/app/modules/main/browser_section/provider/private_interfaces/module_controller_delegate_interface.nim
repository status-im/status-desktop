method setDappsAddress*(self: AccessInterface, newDappAddress: string) =
  raise newException(ValueError, "No implementation available")

method onDappAddressChanged*(self: AccessInterface, newDappAddress: string) =
  raise newException(ValueError, "No implementation available")
