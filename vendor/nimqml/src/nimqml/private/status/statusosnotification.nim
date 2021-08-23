proc setup(self: StatusOSNotificationObject) =
  self.vptr = dos_statusosnotification_create()

proc delete*(self: StatusOSNotificationObject) =
  dos_statusosnotification_delete(self.vptr)
  self.vptr.resetToNil

proc newStatusOSNotificationObject*(): StatusOSNotificationObject =
  new(result, delete)
  result.setup()

proc showNotification*(self: StatusOSNotificationObject, title: string, 
  message: string, identifier: string) =
  dos_statusosnotification_show_notification(self.vptr, title, message, identifier)
