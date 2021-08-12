
#import ../[nimqmltypes, dotherside]

proc setupDockShowAppEventObject*(self: StatusEventObject, engine: QQmlApplicationEngine) =
  self.vptr = dos_statusevent_create_showAppEvent(engine.vptr)

proc setupOSThemeEventObject*(self: StatusEventObject, engine: QQmlApplicationEngine) =
  self.vptr = dos_statusevent_create_osThemeEvent(engine.vptr)

proc delete*(self: StatusEventObject) =
  dos_statusevent_delete(self.vptr)
  self.vptr.resetToNil

proc newStatusDockShowAppEventObject*(engine: QQmlApplicationEngine): StatusEventObject =
  new(result, delete)
  result.setupDockShowAppEventObject(engine)

proc newStatusOSThemeEventObject*(engine: QQmlApplicationEngine): StatusEventObject =
  new(result, delete)
  result.setupOSThemeEventObject(engine)
