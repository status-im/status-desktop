proc setup(self: StatusOSNotification) =
  self.vptr = dos_osnotification_create()

proc delete*(self: StatusOSNotification) =
  dos_osnotification_delete(self.vptr)
  self.vptr.resetToNil

proc newStatusOSNotification*(): StatusOSNotification =
  new(result, delete)
  result.setup()

proc showNotification*(self: StatusOSNotification, title: string, 
  message: string, identifier: string) =
  dos_osnotification_show_notification(self.vptr, title, message, identifier)
