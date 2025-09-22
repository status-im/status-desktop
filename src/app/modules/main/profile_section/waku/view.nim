import nimqml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      activeMailserver: string

  proc delete*(self: View)
  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.activeMailserver = ""

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc activeMailserverChanged*(self: View) {.signal.}

  proc getActiveMailserver*(self: View): string {.slot.} =
    return self.activeMailserver

  QtProperty[string] activeMailserver:
    read = getActiveMailserver
    notify = activeMailserverChanged

  proc onActiveMailserverChanged*(self: View, activeMailserverId: string) =
    self.activeMailserver = activeMailserverId
    self.activeMailserverChanged()

  proc delete*(self: View) =
    self.QObject.delete

