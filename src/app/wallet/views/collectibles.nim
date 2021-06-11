import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables

import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings]
import ../../../status/wallet/collectibles as status_collectibles
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet,
  ../../../status/tasks/[qt, task_runner_impl]

import collectibles_list, accounts
import account_list, account_item

logScope:
  topics = "collectibles-view"

type
  LoadCollectiblesTaskArg = ref object of QObjectTaskArg
    address: string
    collectiblesType: string
    running*: ByteAddress # pointer to threadpool's `.running` Atomic[bool]

const loadCollectiblesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LoadCollectiblesTaskArg](argEncoded)
  var running = cast[ptr Atomic[bool]](arg.running)
  var collectiblesOrError = ""
  case arg.collectiblesType:
    of status_collectibles.CRYPTOKITTY:
      collectiblesOrError = status_collectibles.getCryptoKitties(arg.address)
    of status_collectibles.KUDO:
      collectiblesOrError = status_collectibles.getKudos(arg.address)
    of status_collectibles.ETHERMON:
      collectiblesOrError = status_collectibles.getEthermons(arg.address)
    of status_collectibles.STICKER:
      collectiblesOrError = status_collectibles.getStickers(arg.address, running[])

  let output = %*{
    "address": arg.address,
    "collectibleType": arg.collectiblesType,
    "collectiblesOrError": collectiblesOrError
  }
  arg.finish(output)

proc loadCollectibles[T](self: T, slot: string, address: string, collectiblesType: string) =
  let arg = LoadCollectiblesTaskArg(
    tptr: cast[ByteAddress](loadCollectiblesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    address: address,
    collectiblesType: collectiblesType,
    running: cast[ByteAddress](addr self.status.tasks.threadpool.running)
  )
  self.status.tasks.threadpool.start(arg)

QtObject:
  type CollectiblesView* = ref object of QObject
      status: Status
      accountsView*: AccountsView
      currentCollectiblesLists*: CollectiblesList

  proc setup(self: CollectiblesView) =
    self.QObject.setup

  proc delete(self: CollectiblesView) =
    self.currentCollectiblesLists.delete

  proc newCollectiblesView*(status: Status, accountsView: AccountsView): CollectiblesView =
    new(result, delete)
    result.status = status
    result.currentCollectiblesLists = newCollectiblesList()
    result.accountsView = accountsView # TODO: not ideal but a solution for now
    result.setup

  proc currentCollectiblesListsChanged*(self: CollectiblesView) {.signal.}

  proc getCurrentCollectiblesLists(self: CollectiblesView): QVariant {.slot.} =
    return newQVariant(self.currentCollectiblesLists)

  proc setCurrentCollectiblesLists*(self: CollectiblesView, collectiblesLists: seq[CollectibleList]) =
    self.currentCollectiblesLists.setNewData(collectiblesLists)
    self.currentCollectiblesListsChanged()

  QtProperty[QVariant] collectiblesLists:
    read = getCurrentCollectiblesLists
    write = setCurrentCollectiblesLists
    notify = currentCollectiblesListsChanged

  proc loadCollectiblesForAccount*(self: CollectiblesView, address: string, currentCollectiblesList: seq[CollectibleList]) =
    if (currentCollectiblesList.len > 0):
      return
    # Add loading state if it is the current account
    if address == self.accountsView.currentAccount.address:
      for collectibleType in status_collectibles.COLLECTIBLE_TYPES:
        self.currentCollectiblesLists.addCollectibleListToList(CollectibleList(
          collectibleType: collectibleType,
          collectiblesJSON: "[]",
          error: "",
          loading: 1
        ))

    # TODO find a way to use a loop to streamline this code
    # Create a thread in the threadpool for each collectible. They can end in whichever order
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.CRYPTOKITTY)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.KUDO)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.ETHERMON)
    self.loadCollectibles("setCollectiblesResult", address, status_collectibles.STICKER)

  proc setCollectiblesResult(self: CollectiblesView, collectiblesJSON: string) {.slot.} =
    let collectibleData = parseJson(collectiblesJSON)
    let address = collectibleData["address"].getStr
    let collectibleType = collectibleData["collectibleType"].getStr
    
    var collectibles: JSONNode
    try:
      collectibles = parseJson(collectibleData["collectiblesOrError"].getStr)
    except Exception as e:
      # We failed parsing, this means the result is an error string
      self.currentCollectiblesLists.setErrorByType(
        collectibleType,
        $collectibleData["collectiblesOrError"]
      )
      return

    # Add the collectibles to the WalletAccount
    let index = self.accountsView.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accountsView.accounts.addCollectibleListToAccount(index, collectibleType, $collectibles)

    if address == self.accountsView.currentAccount.address:
      # Add CollectibleListJSON to the right list
      self.currentCollectiblesLists.setCollectiblesJSONByType(
        collectibleType,
        $collectibles
      )

  proc reloadCollectible*(self: CollectiblesView, collectibleType: string) {.slot.} =
    let address = self.accountsView.currentAccount.address
    self.loadCollectibles("setCollectiblesResult", address, collectibleType)
    self.currentCollectiblesLists.setLoadingByType(collectibleType, 1)
