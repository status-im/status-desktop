import NimQml

import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      currentLocale: string

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

  proc setIsDDMMYYDateFormat*(self: View, isDDMMYYDateFormat: bool) {.slot.} =
    self.delegate.setIsDDMMYYDateFormat(isDDMMYYDateFormat)

  proc setIs24hTimeFormat*(self: View, is24hTimeFormat: bool) {.slot.} =
    self.delegate.setIs24hTimeFormat(is24hTimeFormat)

  proc changeLocale*(self: View, locale: string) {.slot.} =
    self.delegate.changeLocale(locale)

  proc getLocale*(self: View): string {.slot.} =
    self.currentLocale

  proc localeChanged*(self: View) {.signal.}

  QtProperty[string] currentLocale:
    read = getLocale
    notify = localeChanged

  proc setLocale*(self: View, locale: string) =
    if locale != self.currentLocale:
      self.currentLocale = locale
      self.localeChanged()
