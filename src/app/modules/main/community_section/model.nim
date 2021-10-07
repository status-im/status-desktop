import NimQml
import item

QtObject:
  type 
    Model* = ref object of QAbstractListModel
      sections: seq[Item]

  proc setup(self: Model) = 
    self.QAbstractListModel.setup

  proc delete*(self: Model) =
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.setup