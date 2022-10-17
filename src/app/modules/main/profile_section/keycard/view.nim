import NimQml

import ../../../shared_modules/keycard_popup/models/keycard_model

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      keycardModel: KeycardModel
      keycardModelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete
    if not self.keycardModel.isNil:
      self.keycardModel.delete
    if not self.keycardModelVariant.isNil:
      self.keycardModelVariant.delete

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
    return self.delegate.getKeycardSharedModule()
  QtProperty[QVariant] keycardSharedModule:
    read = getKeycardSharedModule
    
  proc displayKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDisplayKeycardSharedModuleFlow*(self: View) =
    self.displayKeycardSharedModuleFlow()

  proc destroyKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDestroyKeycardSharedModuleFlow*(self: View) =
    self.destroyKeycardSharedModuleFlow()

  proc runSetupKeycardPopup*(self: View) {.slot.} =
    self.delegate.runSetupKeycardPopup()

  proc runGenerateSeedPhrasePopup*(self: View) {.slot.} =
    self.delegate.runGenerateSeedPhrasePopup()

  proc runImportOrRestoreViaSeedPhrasePopup*(self: View) {.slot.} =
    self.delegate.runImportOrRestoreViaSeedPhrasePopup()

  proc runImportFromKeycardToAppPopup*(self: View) {.slot.} =
    self.delegate.runImportFromKeycardToAppPopup()

  proc runUnlockKeycardPopupForKeycardWithUid*(self: View, keycardUid: string) {.slot.} =
    self.delegate.runUnlockKeycardPopupForKeycardWithUid(keycardUid)

  proc runDisplayKeycardContentPopup*(self: View) {.slot.} =
    self.delegate.runDisplayKeycardContentPopup()

  proc runFactoryResetPopup*(self: View) {.slot.} =
    self.delegate.runFactoryResetPopup()

  proc runRenameKeycardPopup*(self: View, keycardUid: string, keyUid: string) {.slot.} =
    self.delegate.runRenameKeycardPopup(keycardUid, keyUid)

  proc runChangePinPopup*(self: View, keycardUid: string, keyUid: string) {.slot.} =
    self.delegate.runChangePinPopup(keycardUid, keyUid)

  proc runCreateBackupCopyOfAKeycardPopup*(self: View) {.slot.} =
    self.delegate.runCreateBackupCopyOfAKeycardPopup()

  proc runCreatePukPopup*(self: View) {.slot.} =
    self.delegate.runCreatePukPopup()

  proc runCreateNewPairingCodePopup*(self: View) {.slot.} =
    self.delegate.runCreateNewPairingCodePopup()

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

  proc getKeycardDetailsAsJson*(self: View, keycardUid: string): string {.slot.} =
    return self.delegate.getKeycardDetailsAsJson(keycardUid)
  
  proc keycardProfileChanged(self: View) {.signal.}
  proc emitKeycardProfileChangedSignal*(self: View) =
    self.keycardProfileChanged()
  
  proc keycardUidChanged(self: View, oldKcUid: string, newKcUid: string) {.signal.}
  proc emitKeycardUidChangedSignal*(self: View, oldKcUid: string, newKcUid: string) =
    self.keycardUidChanged(oldKcUid, newKcUid)

  proc keycardDetailsChanged(self: View, kcUid: string) {.signal.}
  proc emitKeycardDetailsChangedSignal*(self: View, kcUid: string) =
    self.keycardDetailsChanged(kcUid)