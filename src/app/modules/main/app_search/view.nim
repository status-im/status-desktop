import NimQml
import result_model, location_menu_model
import io_interface

QtObject:
  type View* = ref object of QObject
    delegate: io_interface.AccessInterface
    searchResultModel: result_model.Model
    locationMenuModel: location_menu_model.Model

  proc delete*(self: View) =
    self.searchResultModel.delete
    self.locationMenuModel.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.searchResultModel = result_model.newModel()
    result.locationMenuModel = location_menu_model.newModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc searchResultModel*(self: View): result_model.Model =
    return self.searchResultModel

  proc locationMenuModel*(self: View): location_menu_model.Model =
    return self.locationMenuModel

  proc getSearchResultModel*(self: View): QVariant {.slot.} =
    return newQVariant(self.searchResultModel)

  QtProperty[QVariant] resultModel:
    read = getSearchResultModel

  proc getLocationMenuModel*(self: View): QVariant {.slot.} =
    newQVariant(self.locationMenuModel)

  QtProperty[QVariant] locationMenuModel:
    read = getLocationMenuModel

  proc prepareLocationMenuModel*(self: View) {.slot.} =
    self.delegate.prepareLocationMenuModel()

  proc setSearchLocation*(
      self: View, location: string = "", subLocation: string = ""
  ) {.slot.} =
    self.delegate.setSearchLocation(location, subLocation)

  proc getSearchLocationObject*(self: View): string {.slot.} =
    self.delegate.getSearchLocationObject()

  proc searchMessages*(self: View, searchTerm: string) {.slot.} =
    self.delegate.searchMessages(searchTerm)

  proc resultItemClicked*(self: View, itemId: string) {.slot.} =
    self.delegate.resultItemClicked(itemId)

  proc appSearchCompleted(self: View) {.signal.}
  proc emitAppSearchCompletedSignal*(self: View) =
    self.appSearchCompleted()
