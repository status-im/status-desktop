proc delete*(self: QTimer) =
  dos_qtimer_delete(self.vptr)
  self.vptr.resetToNil

proc setup*(self: QTimer) =
  self.vptr = dos_qtimer_create()

proc newQTimer*() : QTimer =
  new(result, delete)
  result.setup()

proc setInterval*(self: QTimer, interval: int) =
  dos_qtimer_set_interval(self.vptr, interval)

proc interval*(self: QTimer): int =
  return dos_qtimer_interval(self.vptr)

proc start*(self:QTimer) =
  dos_qtimer_start(self.vptr)

proc stop*(self:QTimer) =
  dos_qtimer_stop(self.vptr)

proc setSingleShot*(self:QTimer, singleShot: bool) =
  dos_qtimer_set_single_shot(self.vptr, singleShot)

proc isSingleShot*(self:QTimer): bool =
  return dos_qtimer_is_single_shot(self.vptr)

proc isActive*(self:QTimer): bool =
  return dos_qtimer_is_active(self.vptr)
