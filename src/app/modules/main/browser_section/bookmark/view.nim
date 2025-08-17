import NimQml
import io_interface
import model
import item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc addItem*(self: View, item: Item) =
    self.model.addItem(item)

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc addBookmark(self: View, url: string, name: string,) {.slot.} =
    self.delegate.storeBookmark(url, name)

  proc deleteBookmark(self: View, url: string) {.slot.} =
    self.delegate.deleteBookmark(url)

  proc removeBookmarkByUrl*(self: View, url: string) =
    self.model.removeItemByUrl(url)

  proc updateBookmark(self: View, oldUrl: string, newUrl: string, newName: string) {.slot.} =
    self.delegate.updateBookmark(oldUrl, newUrl, newName)

  proc updateBookmarkByUrl*(self: View, oldUrl: string, item: Item) =
    self.model.updateItemByUrl(oldUrl, item)
