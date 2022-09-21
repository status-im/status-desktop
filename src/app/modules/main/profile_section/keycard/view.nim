import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

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

  proc runUnlockKeycardPopup*(self: View) {.slot.} =
    self.delegate.runUnlockKeycardPopup()

  proc runDisplayKeycardContentPopup*(self: View) {.slot.} =
    self.delegate.runDisplayKeycardContentPopup()

  proc runFactoryResetPopup*(self: View) {.slot.} =
    self.delegate.runFactoryResetPopup()