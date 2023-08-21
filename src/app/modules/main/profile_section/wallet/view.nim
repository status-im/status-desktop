import NimQml

import ./io_interface
from app/modules/shared_modules/keypair_import/module import ImportKeypairModuleMode

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

  proc getAccountsModule(self: View): QVariant {.slot.} =
    return self.delegate.getAccountsModule()
  QtProperty[QVariant] accountsModule:
    read = getAccountsModule

  proc getNetworksModule(self: View): QVariant {.slot.} =
    return self.delegate.getNetworksModule()
  QtProperty[QVariant] networksModule:
    read = getNetworksModule

  proc getCollectiblesModel(self: View): QVariant {.slot.} =
    return self.delegate.getCollectiblesModel()
  QtProperty[QVariant] collectiblesModel:
    read = getCollectiblesModel

  proc runKeypairImportPopup*(self: View, keyUid: string, mode: int) {.slot.} =
    self.delegate.runKeypairImportPopup(keyUid, ImportKeypairModuleMode(mode))

  proc getKeypairImportModule(self: View): QVariant {.slot.} =
    return self.delegate.getKeypairImportModule()
  QtProperty[QVariant] keypairImportModule:
    read = getKeypairImportModule

  proc displayKeypairImportPopup*(self: View) {.signal.}
  proc emitDisplayKeypairImportPopup*(self: View) =
    self.displayKeypairImportPopup()

  proc destroyKeypairImportPopup*(self: View) {.signal.}
  proc emitDestroyKeypairImportPopup*(self: View) =
    self.destroyKeypairImportPopup()

  proc hasPairedDevicesChanged*(self: View) {.signal.}
  proc emitHasPairedDevicesChangedSignal*(self: View) =
    self.hasPairedDevicesChanged()
  proc getHasPairedDevices(self: View): bool {.slot.} =
    return self.delegate.hasPairedDevices()
  QtProperty[bool] hasPairedDevices:
    read = getHasPairedDevices
    notify = hasPairedDevicesChanged