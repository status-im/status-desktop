proc setup(self: StatusKeychainManager, service: string, 
  authenticationReason: string) =
  self.vptr = dos_keychainmanager_create(service, authenticationReason)

proc delete*(self: StatusKeychainManager) =
  dos_keychainmanager_delete(self.vptr)
  self.vptr.resetToNil

proc newStatusKeychainManager*(service: string, 
  authenticationReason: string): StatusKeychainManager =
  new(result, delete)
  result.setup(service, authenticationReason)

proc readDataSync*(self: StatusKeychainManager, key: string): string =
  return dos_keychainmanager_read_data_sync(self.vptr, key)

proc readDataAsync*(self: StatusKeychainManager, key: string) =
  dos_keychainmanager_read_data_async(self.vptr, key)

proc storeDataAsync*(self: StatusKeychainManager, key: string, data: string) =
  dos_keychainmanager_store_data_async(self.vptr, key, data)

proc deleteDataAsync*(self: StatusKeychainManager, key: string) =
  dos_keychainmanager_delete_data_async(self.vptr, key)