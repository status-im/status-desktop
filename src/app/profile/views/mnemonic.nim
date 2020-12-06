import NimQml, chronicles, strutils
import ../../../status/status
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/types

logScope:
  topics = "mnemonic-view"

QtObject:
  type MnemonicView* = ref object of QObject
    status: Status

  proc setup(self: MnemonicView) =
    self.QObject.setup

  proc delete*(self: MnemonicView) =
    self.QObject.delete

  proc newMnemonicView*(status: Status): MnemonicView =
    new(result, delete)
    result.status = status
    result.setup

  proc isBackedUp*(self: MnemonicView): bool {.slot.} =
    let mnemonic = status_settings.getSetting[string](Setting.Mnemonic, "")
    return mnemonic == ""
  
  proc seedPhraseRemoved*(self: MnemonicView) {.signal.}

  QtProperty[bool] isBackedUp:
    read = isBackedUp
    notify = seedPhraseRemoved

  proc getMnemonic*(self: MnemonicView): QVariant {.slot.} =
    # Do not keep the mnemonic in memory, so fetch it when necessary
    let mnemonic = status_settings.getSetting[string](Setting.Mnemonic, "")
    return newQVariant(mnemonic)

  QtProperty[QVariant] get:
    read = getMnemonic
    notify = seedPhraseRemoved

  proc remove*(self: MnemonicView) {.slot.} =
    discard status_settings.saveSetting(Setting.Mnemonic, "")
    self.seedPhraseRemoved()

  proc getWord*(self: MnemonicView, idx: int): string {.slot.} =
    let mnemonics = status_settings.getSetting[string](Setting.Mnemonic, "").split(" ")
    return mnemonics[idx]


