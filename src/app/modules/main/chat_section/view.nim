import NimQml
import model

QtObject:
  type
    View* = ref object of QObject
      model: Model
      
  proc setup(self: View) = 
    self.QObject.setup
    self.model = newModel()

  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(): View =
    new(result, delete)
    result.setup()
