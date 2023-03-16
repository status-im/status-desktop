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

proc refreshCollectibles*(self: Controller, chainId: int, address: string) =
  let collectibles = self.collectibleService.getOwnedCollectibles(chainId, address)
  self.delegate.refreshCollectibles(chainId, address, collectibles)

proc init*(self: Controller) =  
  self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED) do(e:Args):
    let args = OwnedCollectiblesUpdateArgs(e)
    self.refreshCollectibles(args.chainId, args.address)

proc getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc getNetwork*(self: Controller): network_service.NetworkDto =
  return self.networkService.getNetworkForCollectibles()

proc resetOwnedCollectibles*(self: Controller, chainId: int, address: string) =
  self.collectibleService.resetOwnedCollectibles(chainId, address)

proc fetchOwnedCollectibles*(self: Controller, chainId: int, address: string, limit: int) =
  self.collectibleService.fetchOwnedCollectibles(chainId, address, limit)

proc getCollectible*(self: Controller, chainId: int, id: UniqueID) : CollectibleDto =
  self.collectibleService.getCollectible(chainId, id)

proc getCollection*(self: Controller, chainId: int, slug: string) : CollectionDto =
  self.collectibleService.getCollection(chainId, slug)
