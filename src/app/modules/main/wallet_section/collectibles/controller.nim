import sequtils, Tables, sugar
import io_interface
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/network_connection/service as network_connection_service
import ../../../../../app_service/service/node/service as node_service
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    collectibleService: collectible_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    nodeService: node_service.Service
    networkConnectionService: network_connection_service.Service

  # Forward declaration
proc refetchOwnedCollectibles*(self: Controller, chainId: int, address: string)

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  nodeService: node_service.Service,
  networkConnectionService: network_connection_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.collectibleService = collectibleService
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.nodeService = nodeService
  result.networkConnectionService = networkConnectionService

proc delete*(self: Controller) =
  discard

proc resetCollectibles(self: Controller, chainId: int, address: string) =
  let data = self.collectibleService.getOwnedCollectibles(chainId, address)
  self.delegate.setCollectibles(chainId, address, data)

proc updateCollectibles(self: Controller, chainId: int, address: string) =
  let data = self.collectibleService.getOwnedCollectibles(chainId, address)
  self.delegate.appendCollectibles(chainId, address, data)

proc init*(self: Controller) =  
  self.events.on(SIGNAL_OWNED_COLLECTIBLES_REFETCH) do(e:Args):
    let args = OwnedCollectiblesUpdateArgs(e)
    self.resetCollectibles(args.chainId, args.address)

  self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_ERROR) do(e:Args):
    let args = OwnedCollectiblesUpdateArgs(e)
    self.updateCollectibles(args.chainId, args.address)

  self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_STARTED) do(e:Args):
    let args = OwnedCollectiblesUpdateArgs(e)
    self.delegate.onFetchStarted(args.chainId, args.address)

  self.events.on(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED) do(e:Args):
    let args = OwnedCollectiblesUpdateArgs(e)
    self.updateCollectibles(args.chainId, args.address)

  self.events.on(SIGNAL_REFRESH_COLLECTIBLES) do(e:Args):
    self.collectibleService.refetchAllOwnedCollectibles()

proc getWalletAccountByAddress*(self: Controller, address: string): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)

proc getNetwork*(self: Controller): network_service.NetworkDto =
  return self.networkService.getNetworkForCollectibles()

proc getOwnedCollectibles*(self: Controller, chainId: int, address: string): CollectiblesData =
  return self.collectibleService.getOwnedCollectibles(chainId, address)

proc refetchOwnedCollectibles*(self: Controller, chainId: int, address: string) =
  self.collectibleService.refetchOwnedCollectibles(chainId, address)

proc fetchOwnedCollectibles*(self: Controller, chainId: int, address: string) =
  self.collectibleService.fetchOwnedCollectibles(chainId, address)

proc getCollectible*(self: Controller, chainId: int, id: UniqueID) : CollectibleDto =
  self.collectibleService.getCollectible(chainId, id)

proc getCollection*(self: Controller, chainId: int, slug: string) : CollectionDto =
  self.collectibleService.getCollection(chainId, slug)

proc getHasCollectiblesCache*(self: Controller, address: string): bool  =
  return self.collectibleService.areCollectionsLoaded(address)