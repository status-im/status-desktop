import NimQml

QtObject:
  type
    View* = ref object of QObject

  proc setup(self: View) = 
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(): View =
    new(result, delete)
    result.setup()
