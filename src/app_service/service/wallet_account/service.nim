import NimQml, Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient
import net, strutils, os, times, algorithm, options
import web3/ethtypes

import app/global/global_singleton

import app_service/service/settings/service as settings_service
import app_service/service/accounts/service as accounts_service
import app_service/service/token/service as token_service
import app_service/service/network/service as network_service
import app_service/service/currency/service as currency_service
import app_service/common/[utils]

import dto/keypair_dto as keypair_dto
import dto/derived_address_dto as derived_address_dto

import app/core/eventemitter
import app/core/signals/types
import app/core/tasks/[qt, threadpool]
import backend/accounts as status_go_accounts
import backend/backend as backend
import backend/eth as status_go_eth
import backend/transactions as status_go_transactions
import constants as main_constants

export keypair_dto, derived_address_dto

logScope:
  topics = "wallet-account-service"

include signals_and_payloads
include utils
include async_tasks
include  ../../common/json_utils

QtObject:
  type Service* = ref object of QObject
    closingApp: bool
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service
    accountsService: accounts_service.Service
    tokenService: token_service.Service
    networkService: network_service.Service
    currencyService: currency_service.Service
    watchOnlyAccounts: Table[string, WalletAccountDto] ## [address, WalletAccountDto]
    keypairs: Table[string, KeypairDto] ## [keyUid, KeypairDto]
    accountsTokens*: Table[string, seq[WalletTokenDto]] ## [address, seq[WalletTokenDto]]

  # Forward declaration
  proc buildAllTokens(self: Service, accounts: seq[string], store: bool)
  proc checkRecentHistory*(self: Service, addresses: seq[string])
  proc handleWalletAccount(self: Service, account: WalletAccountDto, notify: bool = true)
  proc handleKeypair(self: Service, keypair: KeypairDto)
  proc updateAccountsPositions(self: Service)
  proc importPartiallyOperableAccounts(self: Service, keyUid: string, password: string)
  # All slots defined in included files have to be forward declared
  proc onAllTokensBuilt*(self: Service, response: string) {.slot.}
  proc onDerivedAddressesFetched*(self: Service, jsonString: string) {.slot.}
  proc onDerivedAddressesForMnemonicFetched*(self: Service, jsonString: string) {.slot.}
  proc onAddressDetailsFetched*(self: Service, jsonString: string) {.slot.}
  proc onKeycardAdded*(self: Service, response: string) {.slot.}
  proc onMigratedAccountsForKeycardRemoved*(self: Service, response: string) {.slot.}
  proc onFetchChainIdForUrl*(self: Service, jsonString: string) {.slot.}
  proc onNonProfileKeycardKeypairMigratedToApp*(self: Service, response: string) {.slot.}

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.Service,
    accountsService: accounts_service.Service,
    tokenService: token_service.Service,
    networkService: network_service.Service,
    currencyService: currency_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.closingApp = false
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.accountsService = accountsService
    result.tokenService = tokenService
    result.networkService = networkService
    result.currencyService = currencyService

  include service_account
  include service_token
  include service_keycard