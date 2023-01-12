import NimQml

import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      currentLanguage: string

  proc delete*(self: View) =
    self.QObject.delete
    self.model.delete
    self.modelVariant.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc changeLanguage*(self: View, language: string) {.slot.} =
    self.delegate.changeLanguage(language)

  proc getLanguage*(self: View): string {.slot.} =
    self.currentLanguage

  proc languageChanged*(self: View) {.signal.}

  QtProperty[string] currentLanguage:
    read = getLanguage
    notify = languageChanged

  proc setLanguage*(self: View, language: string) =
    if language != self.currentLanguage:
      self.currentLanguage = language
      self.languageChanged()
