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

  proc isBackedUp*(self: View): bool {.slot.} =
    return self.delegate.isBackedup()

  proc seedPhraseRemoved*(self: View) {.signal.}

  QtProperty[bool] isBackedUp:
    read = isBackedUp
    notify = seedPhraseRemoved

  proc getMnemonic*(self: View): QVariant {.slot.} =
    return newQVariant(self.delegate.getMnemonic())

  QtProperty[QVariant] get:
    read = getMnemonic
    notify = seedPhraseRemoved

  proc remove*(self: View) {.slot.} =
    self.delegate.remove()
    self.seedPhraseRemoved()

  proc getWord*(self: View, index: int): string {.slot.} =
    return self.delegate.getWord(index)
