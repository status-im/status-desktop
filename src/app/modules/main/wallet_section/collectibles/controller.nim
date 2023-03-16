import sequtils, Tables, sugar
import io_interface
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    collectibleService: collectible_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.collectibleService = collectibleService
  result.walletAccountService = walletAccountService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc refreshCollections*(self: Controller, chainId: int, address: string) =
  let collections = self.collectibleService.getCollections(chainId, address)
  self.delegate.setCollections(collections)

proc refreshCollectibles*(self: Controller, chainId: int, address: string, collectionSlug: string) =
  let collection = self.collectibleService.getCollection(chainId, address, collectionSlug)
  self.delegate.updateCollection(collection)

proc init*(self: Controller) =
  self.events.on(SIGNAL_COLLECTIONS_UPDATED) do(e:Args):
    let args = CollectionsUpdateArgs(e)
    self.refreshCollections(args.chainId, args.address)
    self.collectibleService.fetchAllCollectibles(args.chainId, args.address)
  
  self.events.on(SIGNAL_COLLECTIBLES_UPDATED) do(e:Args):
    let args = CollectiblesUpdateArgs(e)
    self.refreshCollectibles(args.chainId, args.address, args.collectionSlug)

proc getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc getNetwork*(self: Controller): network_service.NetworkDto =
  return self.networkService.getNetworkForCollectibles()

proc fetchCollections*(self: Controller, chainId: int, address: string) =
  self.collectibleService.fetchCollections(chainId, address)

proc fetchCollectibles*(self: Controller, chainId: int, address: string, collectionSlug: string) =
  self.collectibleService.fetchCollectibles(chainId, address, collectionSlug)
