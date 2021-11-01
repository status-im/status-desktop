import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      currentFleet: string

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.QObject.setup

  proc fleetChanged*(self: View, newFleet: string) {.signal.}

  proc changeFleet*(self: View, newFleet: string) {.slot.} =
    self.currentFleet = newFleet
    self.delegate.setFleet(newFleet)
    self.fleetChanged(newFleet)

  proc setFleet*(self: View, newFleet: string) =
    self.currentFleet = newFleet
    self.fleetChanged(newFleet)

  proc getFleet*(self: View): string {.slot.} = self.currentFleet

  QtProperty[string] fleet:
    read = getFleet
    notify = fleetChanged