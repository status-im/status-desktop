import NimQml, chronicles

import io_interface
import view, controller
import app/core/eventemitter

import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/wallet_connect/service as wallet_connect_service
import app_service/service/keychain/service as keychain_service

export io_interface

logScope:
  topics = "wallet-connect-module"

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller

proc newModule*[T](delegate: T,
  uniqueIdentifier: string,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  walletConnectService: wallet_connect_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, walletAccountService, walletConnectService)

{.push warning[Deprecated]: off.}

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc init[T](self: Module[T], fullConnect = true) =
    self.controller.init()

method getModuleAsVariant*[T](self: Module[T]): QVariant =
  return self.viewVariant


{.pop.}
