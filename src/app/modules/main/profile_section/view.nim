import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc setup(self: View) = 
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getAdvancedModule(self: View): QVariant {.slot.} =
    return self.delegate.getAdvancedModule()
  QtProperty[QVariant] advancedModule:
    read = getAdvancedModule

  proc getDevicesModule(self: View): QVariant {.slot.} =
    return self.delegate.getDevicesModule()
  QtProperty[QVariant] devicesModule:
    read = getDevicesModule

  proc getSyncModule(self: View): QVariant {.slot.} =
    return self.delegate.getSyncModule()
  QtProperty[QVariant] syncModule:
    read = getSyncModule