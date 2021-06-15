import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint

import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings, wallet, tokens]
import ../../../status/wallet/collectibles as status_collectibles
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet,
  ../../../status/utils as status_utils,
  ../../../status/tokens as status_tokens,
  ../../../status/ens as status_ens,
  ../../../status/tasks/[qt, task_runner_impl]

import account_list, account_item, transaction_list, accounts, asset_list, token_list, transactions

logScope:
  topics = "utils-view"

QtObject:
  type UtilsView* = ref object of QObject
      status: Status
      etherscanLink: string
      signingPhrase: string

  proc setup(self: UtilsView) =
    self.QObject.setup

  proc delete(self: UtilsView) =
    echo "delete"

  proc newUtilsView*(status: Status): UtilsView =
    new(result, delete)
    result.status = status
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
