proc setupDockShowAppEventObject*(self: StatusEvent, engine: QQmlApplicationEngine) =
  self.vptr = dos_event_create_showAppEvent(engine.vptr)

proc setupOSThemeEventObject*(self: StatusEvent, engine: QQmlApplicationEngine) =
  self.vptr = dos_event_create_osThemeEvent(engine.vptr)

proc delete*(self: StatusEvent) =
  dos_event_delete(self.vptr)
  self.vptr.resetToNil

proc newStatusDockShowAppEventObject*(engine: QQmlApplicationEngine): StatusEvent =
  new(result, delete)
  result.setupDockShowAppEventObject(engine)

proc newStatusOSThemeEventObject*(engine: QQmlApplicationEngine): StatusEvent =
  new(result, delete)
  result.setupOSThemeEventObject(engine)
