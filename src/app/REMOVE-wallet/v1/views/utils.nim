import strutils, sequtils, json, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, json

logScope:
  topics = "utils-view"

QtObject:
  type UtilsView* = ref object of QObject
    etherscanLink: string
    signingPhrase: string

  proc setup(self: UtilsView) = self.QObject.setup
  proc delete(self: UtilsView) = self.QObject.delete

  proc newUtilsView*(): UtilsView =
    new(result, delete)
    result.etherscanLink = ""
    result.signingPhrase = ""
    result.setup

  proc etherscanLinkChanged*(self: UtilsView) {.signal.}

  proc getEtherscanLink*(self: UtilsView): QVariant {.slot.} =
    newQVariant(self.etherscanLink.replace("/address", "/tx"))

  proc setEtherscanLink*(self: UtilsView, link: string) =
    self.etherscanLink = link
    self.etherscanLinkChanged()

  proc signingPhraseChanged*(self: UtilsView) {.signal.}

  proc getSigningPhrase*(self: UtilsView): QVariant {.slot.} =
    newQVariant(self.signingPhrase)

  proc setSigningPhrase*(self: UtilsView, signingPhrase: string) =
    self.signingPhrase = signingPhrase
    self.signingPhraseChanged()

  QtProperty[QVariant] etherscanLink:
    read = getEtherscanLink
    notify = etherscanLinkChanged

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase
    notify = signingPhraseChanged
