import NimQml, Tables, json, chronicles

import status/[status, wallet2]
import ../../../core/[main]
import ../../../core/tasks/[qt, threadpool]

import collection_list, asset_list

logScope:
  topics = "app-wallet2-collectibles-view"

type
  LoadCollectionsTaskArg = ref object of QObjectTaskArg
    address: string

const loadCollectionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LoadCollectionsTaskArg](argEncoded)
  let output = wallet2.getOpenseaCollections(arg.address)
  arg.finish(output)

proc loadCollections[T](self: T, slot: string, address: string) =
  let arg = LoadCollectionsTaskArg(
    tptr: cast[ByteAddress](loadCollectionsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot, address: address,
  )
  self.appService.threadpool.start(arg)

type
  LoadAssetsTaskArg = ref object of QObjectTaskArg
    address: string
    collectionSlug: string
    limit: int

const loadAssetsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LoadAssetsTaskArg](argEncoded)
  let output = %*{
    "collectionSlug": arg.collectionSlug,
    "assets": parseJson(wallet2.getOpenseaAssets(arg.address, arg.collectionSlug, arg.limit)),
  }
  arg.finish(output)

proc loadAssets[T](self: T, slot: string, address: string, collectionSlug: string) =
  let arg = LoadAssetsTaskArg(
    tptr: cast[ByteAddress](loadAssetsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot, address: address, collectionSlug: collectionSlug, limit: 200
  )
  self.appService.threadpool.start(arg)

QtObject:
  type CollectiblesView* = ref object of QObject
      status: Status
      appService: AppService
      collections: CollectionList
      isLoading: bool
      assets: Table[string, AssetList]

  proc setup(self: CollectiblesView) = self.QObject.setup

  proc delete(self: CollectiblesView) =
    self.collections.delete
    for list in self.assets.values:
      list.delete
    self.QObject.delete

  proc newCollectiblesView*(status: Status, appService: AppService): CollectiblesView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.collections = newCollectionList()
    result.assets = initTable[string, AssetList]()
    result.isLoading = false
    result.setup

  proc getIsLoading*(self: CollectiblesView): QVariant {.slot.} = newQVariant(self.isLoading)

  proc isLoadingChanged*(self: CollectiblesView) {.signal.}

  QtProperty[QVariant] isLoading:
    read = getIsLoading
    notify = isLoadingChanged

  proc loadCollections*(self: CollectiblesView, account: WalletAccount) = 
    self.isLoading = true
    self.isLoadingChanged()
    self.assets = initTable[string, AssetList]()
    self.loadCollections("setCollectionsList", account.address)

  proc setCollectionsList(self: CollectiblesView, raw: string) {.slot.} =
    var newData: seq[OpenseaCollection] = @[]
    let collectionsJSON = parseJson(raw)
    if not collectionsJSON{"result"}.isNil and collectionsJSON{"result"}.kind != JNull:
      for jsonOpenseaCollection in collectionsJSON{"result"}:
        let collection = jsonOpenseaCollection.toOpenseaCollection()
        newData.add(collection)
        self.assets[collection.slug] = newAssetList()

    self.collections.setData(newData)
    self.isLoading = false
    self.isLoadingChanged()

  proc getCollectionsList(self: CollectiblesView): QVariant {.slot.} =
    return newQVariant(self.collections)
    
  QtProperty[QVariant] collections:
    read = getCollectionsList

  proc loadAssets*(self: CollectiblesView, address: string, collectionSlug: string) {.slot.} =
    self.loadAssets("setAssetsList", address, collectionSlug)

  proc setAssetsList(self: CollectiblesView, raw: string) {.slot.} =
    var newData: seq[OpenseaAsset] = @[]
    let assetsJSON = parseJson(raw)
    if not assetsJSON{"assets"}{"result"}.isNil and assetsJSON{"assets"}{"result"}.kind != JNull:
      for jsonOpenseaAsset in assetsJSON{"assets"}{"result"}:
        newData.add(jsonOpenseaAsset.toOpenseaAsset())

    self.assets[assetsJSON["collectionSlug"].getStr].setData(newData) 

  proc getAssetsList(self: CollectiblesView, collectionSlug: string): QObject {.slot.} =
    return self.assets[collectionSlug]