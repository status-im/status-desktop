import NimQml

import ../../../shared_modules/keycard_popup/models/keycard_model

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      keycardModel: KeycardModel
      keycardModelVariant: QVariant
      keycardDetailsModel: KeycardModel
      keycardDetailsModelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete
    if not self.keycardModel.isNil:
      self.keycardModel.delete
    if not self.keycardModelVariant.isNil:
      self.keycardModelVariant.delete
    if not self.keycardDetailsModel.isNil:
      self.keycardDetailsModel.delete
    if not self.keycardDetailsModelVariant.isNil:
      self.keycardDetailsModelVariant.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    if result.keycardModel.isNil:
      result.keycardModel = newKeycardModel()
    if result.keycardModelVariant.isNil:
      result.keycardModelVariant = newQVariant(result.keycardModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getKeycardSharedModule(self: View): QVariant {.slot.} =
    let module = self.delegate.getKeycardSharedModule()
    if not module.isNil:
      return module
    return newQVariant()
  QtProperty[QVariant] keycardSharedModule:
    read = getKeycardSharedModule

  proc sharedModuleBusy*(self: View) {.signal.}
  proc emitSharedModuleBusy*(self: View) =
    self.sharedModuleBusy()

  proc displayKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDisplayKeycardSharedModuleFlow*(self: View) =
    self.displayKeycardSharedModuleFlow()

  proc destroyKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDestroyKeycardSharedModuleFlow*(self: View) =
    self.destroyKeycardSharedModuleFlow()

  proc runSetupKeycardPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runSetupKeycardPopup(keyUid)

  proc runStopUsingKeycardPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runStopUsingKeycardPopup(keyUid)

  proc runCreateNewKeycardWithNewSeedPhrasePopup*(self: View) {.slot.} =
    self.delegate.runCreateNewKeycardWithNewSeedPhrasePopup()

  proc runImportOrRestoreViaSeedPhrasePopup*(self: View) {.slot.} =
    self.delegate.runImportOrRestoreViaSeedPhrasePopup()

  proc runImportFromKeycardToAppPopup*(self: View) {.slot.} =
    self.delegate.runImportFromKeycardToAppPopup()

  proc runUnlockKeycardPopupForKeycardWithUid*(self: View, keyUid: string) {.slot.} =
    self.delegate.runUnlockKeycardPopupForKeycardWithUid(keyUid)

  proc runDisplayKeycardContentPopup*(self: View) {.slot.} =
    self.delegate.runDisplayKeycardContentPopup()

  proc runFactoryResetPopup*(self: View) {.slot.} =
    self.delegate.runFactoryResetPopup()

  proc runRenameKeycardPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runRenameKeycardPopup(keyUid)

  proc runChangePinPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runChangePinPopup(keyUid)

  proc runCreateBackupCopyOfAKeycardPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runCreateBackupCopyOfAKeycardPopup(keyUid)

  proc runCreatePukPopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runCreatePukPopup(keyUid)

  proc runCreateNewPairingCodePopup*(self: View, keyUid: string) {.slot.} =
    self.delegate.runCreateNewPairingCodePopup(keyUid)

  proc keycardModel*(self: View): KeycardModel =
    return self.keycardModel
  proc keycardModelChanged(self: View) {.signal.}
  proc getKeycardModel(self: View): QVariant {.slot.} =
    if self.keycardModelVariant.isNil:
      return newQVariant()
    return self.keycardModelVariant
  QtProperty[QVariant] keycardModel:
    read = getKeycardModel
    notify = keycardModelChanged

  proc setKeycardItems*(self: View, items: seq[KeycardItem]) =
    self.keycardModel.setItems(items)
    self.keycardModelChanged()

  proc keycardDetailsModel*(self: View): KeycardModel =
    return self.keycardDetailsModel
  proc keycardDetailsModelChanged(self: View) {.signal.}
  proc getKeycardDetailsModel(self: View): QVariant {.slot.} =
    if self.keycardDetailsModelVariant.isNil:
      return newQVariant()
    return self.keycardDetailsModelVariant
  QtProperty[QVariant] keycardDetailsModel:
    read = getKeycardDetailsModel
    notify = keycardDetailsModelChanged

  proc createModelAndSetKeycardDetailsItems*(self: View, items: seq[KeycardItem]) =
    if self.keycardDetailsModel.isNil:
      self.keycardDetailsModel = newKeycardModel()
    if self.keycardDetailsModelVariant.isNil:
      self.keycardDetailsModelVariant = newQVariant(self.keycardDetailsModel)
    self.keycardDetailsModel.setItems(items)
    self.keycardDetailsModelChanged()

  proc prepareKeycardDetailsModel*(self: View, keyUid: string) {.slot.} =
    self.delegate.prepareKeycardDetailsModel(keyUid)
