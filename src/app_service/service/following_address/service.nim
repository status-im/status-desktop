import nimqml, chronicles, strutils, sequtils, json, tables

import dto

import backend/following_addresses as backend
import app/core/eventemitter
import app/core/signals/types
import app/core/[main]
import app/core/tasks/[qt, threadpool]
import app_service/service/network/service as network_service

export dto

include async_tasks

logScope:
  topics = "following-address-service"

# Signals which may be emitted by this service:
const SIGNAL_FOLLOWING_ADDRESSES_UPDATED* = "followingAddressesUpdated"

type
  FollowingAddressesArgs* = ref object of Args
    userAddress*: string
    addresses*: seq[FollowingAddressDto]

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    followingAddressesTable: Table[string, seq[FollowingAddressDto]]
    networkService: network_service.Service
    totalFollowingCount: int

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(threadpool: ThreadPool, events: EventEmitter, networkService: network_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.threadpool = threadpool
    result.events = events
    result.networkService = networkService
    result.followingAddressesTable = initTable[string, seq[FollowingAddressDto]]()
    result.totalFollowingCount = 0

  proc init*(self: Service) =
    discard

  # Forward declaration
  proc fetchFollowingStats*(self: Service, userAddress: string)

  proc getFollowingAddresses*(self: Service, userAddress: string): seq[FollowingAddressDto] =
    if self.followingAddressesTable.hasKey(userAddress):
      return self.followingAddressesTable[userAddress]
    return @[]

  proc fetchFollowingAddresses*(self: Service, userAddress: string, search: string = "", limit: int = 10, offset: int = 0) =
    # Fetch stats only when not searching (to get total count for pagination)
    if search.len == 0:
      self.fetchFollowingStats(userAddress)
    
    let arg = FetchFollowingAddressesTaskArg(
      tptr: fetchFollowingAddressesTask,
      vptr: cast[uint](self.vptr),
      slot: "onFollowingAddressesFetched",
      userAddress: userAddress,
      search: search,
      limit: limit,
      offset: offset
    )
    self.threadpool.start(arg)

  proc onFollowingAddressesFetched(self: Service, response: string) {.slot.} =
    try:
      let parsedJson = response.parseJson
      
      var errorString: string
      var userAddress: string
      var followingAddressesJson, followingResult: JsonNode
      discard parsedJson.getProp("followingAddresses", followingAddressesJson)
      discard parsedJson.getProp("userAddress", userAddress)
      discard parsedJson.getProp("error", errorString)

      if not errorString.isEmptyOrWhitespace:
        error "onFollowingAddressesFetched got error from backend", errorString = errorString
        let args = FollowingAddressesArgs(userAddress: userAddress, addresses: @[])
        self.events.emit(SIGNAL_FOLLOWING_ADDRESSES_UPDATED, args)
        return
      if followingAddressesJson.isNil or followingAddressesJson.kind == JNull:
        warn "onFollowingAddressesFetched: followingAddressesJson is nil or null"
        let args = FollowingAddressesArgs(userAddress: userAddress, addresses: @[])
        self.events.emit(SIGNAL_FOLLOWING_ADDRESSES_UPDATED, args)
        return

      discard followingAddressesJson.getProp("result", followingResult)
      if followingResult.isNil or followingResult.kind == JNull:
        warn "onFollowingAddressesFetched: followingResult is nil or null"
        let args = FollowingAddressesArgs(userAddress: userAddress, addresses: @[])
        self.events.emit(SIGNAL_FOLLOWING_ADDRESSES_UPDATED, args)
        return

      let addresses = followingResult.getElems().map(proc(x: JsonNode): FollowingAddressDto = x.toFollowingAddressDto())
      
      # Update cache with complete data (ENS names and avatars already included from API)
      self.followingAddressesTable[userAddress] = addresses
      
      # Emit signal to refresh UI - data is complete
      let args = FollowingAddressesArgs(userAddress: userAddress, addresses: addresses)
      self.events.emit(SIGNAL_FOLLOWING_ADDRESSES_UPDATED, args)
      
    except Exception as e:
      error "onFollowingAddressesFetched exception", msg = e.msg
      let args = FollowingAddressesArgs(userAddress: "", addresses: @[])
      self.events.emit(SIGNAL_FOLLOWING_ADDRESSES_UPDATED, args)

  proc getTotalFollowingCount*(self: Service): int =
    return self.totalFollowingCount

  proc fetchFollowingStats*(self: Service, userAddress: string) =
    try:
      let response = following_addresses.getFollowingStats(userAddress)
      if response.error.isNil:
        self.totalFollowingCount = response.result.getInt()
      else:
        error "fetchFollowingStats: error", error = response.error
    except Exception as e:
      error "fetchFollowingStats: exception", msg = e.msg
