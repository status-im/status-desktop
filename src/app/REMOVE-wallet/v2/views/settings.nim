import strutils, sequtils, json, web3/[ethtypes, conversions], stint
import NimQml, sequtils, chronicles

logScope:
  topics = "settings-view"

QtObject:
  type SettingsView* = ref object of QObject
    etherscanLink: string
    signingPhrase: string

  proc setup(self: SettingsView) = self.QObject.setup
  proc delete(self: SettingsView) = self.QObject.delete

  proc newSettingsView*(): SettingsView =
    new(result, delete)
    result.etherscanLink = ""
    result.signingPhrase = ""
    result.setup

  proc etherscanLinkChanged*(self: SettingsView) {.signal.}

  proc getEtherscanLink*(self: SettingsView): QVariant {.slot.} =
    newQVariant(self.etherscanLink.replace("/address", "/tx"))

  proc setEtherscanLink*(self: SettingsView, link: string) =
    self.etherscanLink = link
    self.etherscanLinkChanged()

  proc signingPhraseChanged*(self: SettingsView) {.signal.}

  proc getSigningPhrase*(self: SettingsView): QVariant {.slot.} =
    newQVariant(self.signingPhrase)

  proc setSigningPhrase*(self: SettingsView, signingPhrase: string) =
    self.signingPhrase = signingPhrase
    self.signingPhraseChanged()

  QtProperty[QVariant] etherscanLink:
    read = getEtherscanLink
    notify = etherscanLinkChanged

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase
    notify = signingPhraseChanged
