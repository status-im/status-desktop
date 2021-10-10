import NimQml
import model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      test: int
      
  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.test = 1001
    echo "TEST SET TO: ", result.test

  method load*(self: View) =
    self.delegate.viewDidLoad()

  proc testChanged*(self: View) {.signal.}

  proc getTest(self: View): int {.slot.} =
    return self.test

  proc setTest(self: View, t: int) {.slot.} =
    if(self.test == t):
      return

    echo "Nwq Value....", t
    self.test = t
    self.testChanged()

  QtProperty[QVariant] test:
    read = getTest
    write = setTest
    notify = testChanged