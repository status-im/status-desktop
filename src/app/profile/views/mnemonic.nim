import NimQml, chronicles, strutils
import ../../../status/[status, settings]
import ../../../status/types
import options

logScope:
  topics = "mnemonic-view"

QtObject:
  type MnemonicView* = ref object of QObject
    status: Status
    isMnemonicBackedUp: Option[bool]

  proc setup(self: MnemonicView) =
    self.QObject.setup

  proc delete*(self: MnemonicView) =
    self.QObject.delete

  proc newMnemonicView*(status: Status): MnemonicView =
    new(result, delete)
    result.status = status
    result.setup

  proc isBackedUp*(self: MnemonicView): bool {.slot.} =
    if self.isMnemonicBackedUp.isNone:
      self.isMnemonicBackedUp = some(self.status.settings.getSetting[:string](Setting.Mnemonic, "") == "")
    self.isMnemonicBackedUp.get()
  
  proc seedPhraseRemoved*(self: MnemonicView) {.signal.}

  QtProperty[bool] isBackedUp:
    read = isBackedUp
    notify = seedPhraseRemoved

  proc getMnemonic*(self: MnemonicView): QVariant {.slot.} =
    # Do not keep the mnemonic in memory, so fetch it when necessary
    let mnemonic = self.status.settings.getSetting[:string](Setting.Mnemonic, "")
    return newQVariant(mnemonic)

  QtProperty[QVariant] get:
    read = getMnemonic
    notify = seedPhraseRemoved

  proc remove*(self: MnemonicView) {.slot.} =
    discard self.status.settings.saveSetting(Setting.Mnemonic, "")
    self.isMnemonicBackedUp = some(true)
    self.seedPhraseRemoved()

  proc getWord*(self: MnemonicView, idx: int): string {.slot.} =
    let mnemonics = self.status.settings.getSetting[:string](Setting.Mnemonic, "").split(" ")
    return mnemonics[idx]


