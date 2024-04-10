import chronicles
import io_interface

import app/core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/wallet_connect/service as wallet_connect_service

logScope:
  topics = "wallet-connect-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    walletConnectService: wallet_connect_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  walletConnectService: wallet_connect_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.walletConnectService = walletConnectService

proc delete*(self: Controller) =
  self.disconnectAll()

proc init*(self: Controller) =
  discard