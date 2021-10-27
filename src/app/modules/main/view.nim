import NimQml
import model, item, active_section
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      activeSection: ActiveSection
      activeSectionVariant: QVariant
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.activeSection.delete
    self.activeSectionVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.activeSection = newActiveSection()
    result.activeSectionVariant = newQVariant(result.activeSection)

  proc load*(self: View) =
    # In some point, here, we will setup some exposed main module related things.
    self.delegate.viewDidLoad()

  proc addItem*(self: View, item: Item) =
    self.model.addItem(item)

  proc model*(self: View): Model =
    return self.model

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] sectionsModel:
    read = getModel
    notify = modelChanged

  proc openStoreToKeychainPopup*(self: View) {.signal.}

  proc offerToStorePassword*(self: View) =
    self.openStoreToKeychainPopup()

  proc storePassword*(self: View, password: string) {.slot.} =
    self.delegate.storePassword(password)
  
  proc storingPasswordError*(self:View, errorDescription: string) {.signal.}

  proc emitStoringPasswordError*(self: View, errorDescription: string) =
    self.storingPasswordError(errorDescription)
  
  proc storingPasswordSuccess*(self:View) {.signal.}

  proc emitStoringPasswordSuccess*(self: View) =
    self.storingPasswordSuccess()

  proc activeSectionChanged*(self:View) {.signal.}

  proc getActiveSection(self: View): QVariant {.slot.} =
    return self.activeSectionVariant

  QtProperty[QVariant] activeSection:
    read = getActiveSection
    notify = activeSectionChanged

  proc activeSectionSet*(self: View, item: Item) =
    self.activeSection.setActiveSectionData(item)
    self.activeSectionChanged()

  proc setActiveSectionById*(self: View, sectionId: string) {.slot.} =
    let item = self.model.getItemById(sectionId)
    self.delegate.setActiveSection(item)

  proc setActiveSectionBySectionType*(self: View, sectionType: int) {.slot.} =
    ## This will try to set a section with passed sectionType to active one, in case of communities the first community
    ## will be set as active one.
    let item = self.model.getItemBySectionType(sectionType.SectionType)
    self.delegate.setActiveSection(item)

  