import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      # TODO: move to the correct module once all have been merged
      isTelemetryEnabled: bool
      isDebugEnabled: bool

  proc setup(self: View) = 
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc isTelemetryEnabledChanged*(self: View) {.signal.}

  proc setIsTelemetryEnabled*(self: View, isTelemetryEnabled: bool) =
    self.isTelemetryEnabled = isTelemetryEnabled
    self.isTelemetryEnabledChanged()

  proc getIsTelemetryEnabled*(self: View): QVariant {.slot.} =
    return newQVariant(self.isTelemetryEnabled)

  QtProperty[QVariant] isTelemetryEnabled:
    read = getIsTelemetryEnabled
    notify = isTelemetryEnabledChanged

  proc toggleTelemetry*(self: View) {.slot.} = 
    self.delegate.toggleTelemetry()
    self.setIsTelemetryEnabled(not self.isTelemetryEnabled)

  proc isDebugEnabledChanged*(self: View) {.signal.}

  proc setIsDebugEnabled*(self: View, isDebugEnabled: bool) =
    self.isDebugEnabled = isDebugEnabled
    self.isDebugEnabledChanged()

  proc getIsDebugEnabled*(self: View): QVariant {.slot.} =
    return newQVariant(self.isDebugEnabled)

  QtProperty[QVariant] isDebugEnabled:
    read = getIsDebugEnabled
    notify = isDebugEnabledChanged

  proc toggleDebug*(self: View) {.slot.} = 
    self.delegate.toggleDebug()
    self.setIsDebugEnabled(not self.isDebugEnabled)
